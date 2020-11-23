pragma solidity ^0.6.7;

import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "ds-stop/stop.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IItemBase.sol";
import "./Formula.sol";
import "./FurnaceSettingIds.sol";

contract Furnace is DSStop, FurnaceSettingIds {
    event Smelt(
        address indexed user,
        uint256 indexed toekenId,
        uint256 index,
        uint256 major,
        address[] tokens,
        uint256[] amounts
    );
    event Disenchant(
        address indexed owner,
        uint256 indexed disenchantTokenId,
        uint256 tokenId,
        address[] tokens,
        uint256[] amounts
    );

    // 金, Evolution Land Gold
    // 木, Evolution Land Wood
    // 水, Evolution Land Water
    // 火, Evolution Land fire
    // 土, Evolution Land Silicon
    enum Element {NaN, GOLD, WOOD, WATER, FIRE, SOIL}

    ISettingsRegistry public registry;
    Formula public formula;
    IERC721 public ownership;
    IItemBase public itemBase;
    mapping(address => Element) public LPToken2element;

    constructor(address _registry) public {
        registry = ISettingsRegistry(_registry);
        formula = Formula(registry.addressOf(CONTRACT_FORMULA));
        ownership = IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
        itemBase = IItemBase(registry.addressOf(CONTRACT_ITEM_BASE));
        LPToken2element[registry.addressOf(
            CONTRACT_LP_GOLD_ERC20_TOKEN
        )] = Element.GOLD;
        LPToken2element[registry.addressOf(
            CONTRACT_LP_WOOD_ERC20_TOKEN
        )] = Element.WOOD;
        LPToken2element[registry.addressOf(
            CONTRACT_LP_WATER_ERC20_TOKEN
        )] = Element.WATER;
        LPToken2element[registry.addressOf(
            CONTRACT_LP_FIRE_ERC20_TOKEN
        )] = Element.FIRE;
        LPToken2element[registry.addressOf(
            CONTRACT_LP_SOIL_ERC20_TOKEN
        )] = Element.SOIL;
    }

    /**
     * @dev Smelt function, A NFT and FTs can be smelted into a new NFT.
     * @param _index - formula index.
     * @param _major - NFT token id of major meterail.
     * @param _tokens - token addresses of minor meterail.
     * @param _amounts - minor meterial token amountes.
     */
    function smelt(
        uint256 _index,
        uint256 _major,
        address[] memory _tokens,
        uint256[] memory _amounts
    ) public stoppable {
        _smelt(_index, _major, _tokens, _amounts);
    }

    function _smelt(
        uint256 _index,
        uint256 _major,
        address[] memory _tokens,
        uint256[] memory _amounts
    ) internal {
        require(_index > 0 && _index < formula.length(), "Invalid index.");
        require(_major > 0, "Invalid major token id.");
        require(
            msg.sender == ownership.ownerOf(_major),
            "Only owner can smelt."
        );
        (
            ,
            ,
            ,
            ,
            uint16 majorIndex,
            bytes32[] memory tokens,
            uint256[] memory mins,
            uint256[] memory maxs
        ) = formula.at(_index);
        uint256 tokensLength = tokens.length;
        require(_tokens.length == tokensLength, "Invalid tokens length.");
        require(_amounts.length == tokensLength, "Invalid token amounts.");
        require(majorIndex > 0, "Invalid formula index.");
        uint256[] memory amounts = new uint256[](tokensLength);
        uint256 prefer;
        {
            for (uint256 i = 0; i < tokensLength; i++) {
                uint256 amount;
                uint256 _amount = _amounts[i];
                address _token = _tokens[i];
                bytes32 token = tokens[i];
                uint256 min = mins[i];
                uint256 max = maxs[i];
                require(_amount >= min, "No enough token for smelting.");
                if (_amount <= max) {
                    amount = _amount;
                } else {
                    amount = max;
                }
                if (token == CONTRACT_ELEMENT_ERC20_TOKEN) {
                    uint256 element = uint256(LPToken2element[_token]);
                    require(
                        element > 0 && element < 6,
                        "Invalid LP-token element."
                    );
                    prefer |= 1 << element;
                } else {
                    require(
                        _token ==
                            registry.addressOf(CONTRACT_LP_RING_ERC20_TOKEN) ||
                            _token ==
                            registry.addressOf(CONTRACT_LP_KTON_ERC20_TOKEN),
                        "Not support LP-token address."
                    );
                }
                IERC20(_token).transferFrom(msg.sender, address(this), amount);
            }
        }
        ownership.safeTransferFrom(msg.sender, address(this), _major);
        //TODO: calculate rate
        uint256 rate;
        _smeltItem(_index, prefer, rate, _major, _tokens, amounts, msg.sender);
    }

    function _smeltItem(
        uint256 _index,
        uint256 _prefer,
        uint256 _rate,
        uint256 _major,
        address[] memory _tokens,
        uint256[] memory _amounts,
        address _owner
    ) internal {
        (, uint16 class, uint16 grade, bool canDisenchant, , , , ) = formula.at(
            _index
        );
        uint256 tokenId = itemBase.createItem(
            class,
            grade,
            uint16(_prefer),
            uint16(_index),
            uint16(_rate),
            canDisenchant,
            _major,
            _tokens,
            _amounts,
            _owner
        );
        emit Smelt(_owner, tokenId, _index, _major, _tokens, _amounts);
    }

    /**
     * @dev Disenchant function, A smelted NFT can be disenchanted into tokens.
     * @param _tokenId - token id to disenchant.
     * @param _depth - recursion depth token disenchant.
     * @return - token id remain.
     */
    function disenchant(uint256 _tokenId, uint256 _depth)
        public
        stoppable
        returns (uint256)
    {
        return _disenchant(_tokenId, _depth);
    }

    function _disenchant(uint256 _tokenId, uint256 _depth)
        internal
        returns (uint256)
    {
        require(
            msg.sender == ownership.ownerOf(_tokenId),
            "Only owner can disenchant."
        );
        (bool canDisenchant, uint16 class, , , ) = itemBase.getSmeltInfo(
            _tokenId
        );
        require(canDisenchant == true, "Token can not disenchant.");
        require(_depth <= class, "Depth too deep.");
        uint256 tokenId = _tokenId;
        for (uint256 i = 0; i < _depth; i++) {
            tokenId = _disenchantItem(msg.sender, tokenId);
        }
        return tokenId;
    }

    function _disenchantItem(address _owner, uint256 _tokenId)
        internal
        returns (uint256)
    {
        (
            bool canDisenchant,
            uint16 class,
            uint256 major,
            address[] memory tokens,
            uint256[] memory amounts
        ) = itemBase.getSmeltInfo(_tokenId);
        require(canDisenchant == true, "Item can not disenchant.");
        require(class > 0, "Invalid class.");
        require(major > 0, "Invalid major token id.");
        itemBase.destroyItem(_owner, _tokenId);
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            IERC20(token).transferFrom(address(this), _owner, amount);
        }
        ownership.safeTransferFrom(address(this), _owner, major);
        emit Disenchant(_owner, _tokenId, major, tokens, amounts);
        return major;
    }
}
