pragma solidity ^0.6.7;

import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "ds-stop/stop.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IObjectOwnership.sol";
import "./interfaces/IItemBase.sol";
import "./Formula.sol"
import "./FurnaceSettingIds.sol";

contract Furnace is DSStop, FurnaceSettingIds {
	event Smelt(address indexed user, uint256 indexed toekenId, uint256 index, uint256 major, address[] tokens, uint256[] amounts);
    // 金, Evolution Land Gold
    // 木, Evolution Land Wood
    // 水, Evolution Land Water
    // 火, Evolution Land fire
    // 土, Evolution Land Silicon
	enum Element {
		NONE,
		GOLD,
		WOOD,
		WATER,
		FIRE,
		SOIL
	}

    ISettingsRegistry public registry;
	Formula public formula;
	IObjectOwnership objectOwnerShio;
	ItemBase itemBase;
    mapping (address => uint8) public LPToken2element;

    constructor(
        address _registry,
		address _formula,
		address 
    ) public {
        registry = ISettingsRegistry(_registry);
		formula = Formula(_formula);
        objectOwnership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
        itemBase = registry.addressOf(CONTRACT_ITEM_BASE);
		LPToken2element[registry.addressOf(CONTRACT_LP_GOLD_ERC20_TOKEN)] = Element.GOLD;
		LPToken2element[registry.addressOf(CONTRACT_LP_WOOD_ERC20_TOKEN)] = Element.WOOD;
		LPToken2element[registry.addressOf(CONTRACT_LP_WATER_ERC20_TOKEN)] = Element.WATER;
		LPToken2element[registry.addressOf(CONTRACT_LP_FIRE_ERC20_TOKEN)] = Element.FIRE;
		LPToken2element[registry.addressOf(CONTRACT_LP_SOIL_ERC20_TOKEN)] = Element.SOIL;
    }

    /**
     * @dev Smelt function, A NFT and FTs can be smelted into a new NFT.
     * @param _index - formula index.
     * @param _major - NFT token id of major meterail.
     * @param _tokens - token addresses of minor meterail.
     * @param _amounts - minor meterial token amountes.
     */
	function smelt(uint256 _index, uint256 _major, address[] memory _tokens, uint256[] memory _amounts) public stoppable {
		require(_index > 0  && _index < formula.length(), "Invalid index.");
		require(_major > 0, "Invalid major token id.")
		require(msg.sender == IERC721(objectOwnership).ownerOf(_major));
		FormulaEntry memory formulaEntry = formula.formulas[_index];
        (string memory name, uint16 class, uint16 grade, bool canDisenchant, uint16 majorIndex, bytes32[] memory tokens, uint256[] memory mins, uint256[] memory maxs) = formula.at(_index);
		require(majorIndex > 0, "Invalid formula index.");
		uint256 tokensLength = tokens.length; 
		require(_tokens.length == tokensLength, "Invalid tokens length.");
		require(_amounts.length == tokensLength, "Invalid token amounts.");
		uint256[] memory amounts = new uint256[](tokensLength);
		uint16 prefer;
		for (uint256 i = 0; i < tokensLength; i++) {
			uint256 amount;
			uint256 _amount = _amounts[i];
			uint256 _token = _tokens[i];
			bytes32 token = tokens[i];
			uint256 min = mins[i];
			uint256 max = maxs[i];
			require(_amount >= min, 'No enough token for smelting.')
			if (_amount <= max) {
				amount = _amount;
			} else {
				amount = max;
			}
			if (token == CONTRACT_ELEMENT_ERC20_TOKEN) {
				uint256 element = uint(LPToken2element[_token]);
				require(element > 0 && element < 6, "Invalid LP-token element.");
				prefer |= uint16(1 << uint(element));
			} else {
				require(_token == registry.addressOf(CONTRACT_LP_RING_ERC20_TOKEN) ||
					    _token == registry.addressOf(CONTRACT_LP_KTON_ERC20_TOKEN), "Not support LP-token address.")
			}	
			IERC20(_token).transferFrom(msg.sender, address(this), amount);	
		}
		IERC721(objectOwnership).safeTransferFrom(msg.sender, address(this), _major);
		//TODO: calculate rate
		uint256 tokenId = itemBase.createItem(class, grade, prefer, _index, 0, canDisenchant, _major, _tokens, amounts, msg.sender);
		emit Smelt(msg.sender, toekenId, _index, _major, _tokens, amounts);
	}	
}
