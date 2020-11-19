pragma solidity ^0.6.7;

// import "zeppelin-solidity/introspection/SupportsInterfaceWithLookup.sol";

import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IObjectOwnership.sol";
import "./FurnanceSettingIds.sol";

contract ItemBase is DSAuth, FurnanceSettingIds {
    event Create(
        address indexed owner,
        uint256 indexed tokenId,
        uint16 class,
        uint16 grade,
        uint16 prefer,
        uint16 formulaIndex,
        uint16 rate,
        bool canDisenchant,
        uint256 major,
        address[] tokens,
        uint256[] amounts,
        uint256 createTime
    );
    event Destroy(address indexed owner, uint256 indexed tokenId);

    struct Item {
        uint16 class;
        uint16 grade;
        // which element the Item prefer.
        uint16 prefer;
        // index of the formula.
        uint16 index;
        // enchance rate
        uint16 rate;
        bool canDisenchant;
        // tokenId of the major meterail.
        uint256 major;
        // minor meterail of the Item.
        address[] tokens;
        uint256[] amounts;
    }

    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    /*** STORAGE ***/
    bool private singletonLock = false;

    uint128 public lastItemObjectId;

    ISettingsRegistry public registry;

    mapping(uint256 => Item) public tokenId2Item;

    /**
     * @dev Same with constructor, but is used and called by storage proxy as logic contract.
     */
    function initializeContract(address _registry) public singletonLockCall {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    /**
     * @dev create a Item.
     * @param _class the Item class.
     * @param ...
     * @return Item tokenId.
     */
    function createItem(
        uint16 _class,
        uint16 _grade,
        uint16 _prefer,
        uint16 _index,
        uint16 _rate,
        bool _canDisenchant,
        uint256 _major,
        address[] memory _tokens,
        uint256[] memory _amounts,
        address _owner
    ) public auth returns (uint256) {
        return
            _createItem(
                _class,
                _grade,
                _prefer,
                _index,
                _rate,
                _canDisenchant,
                _major,
                _tokens,
                _amounts,
                _owner
            );
    }

    function _createItem(
        uint16 _class,
        uint16 _grade,
        uint16 _prefer,
        uint16 _index,
        uint16 _rate,
        bool _canDisenchant,
        uint256 _major,
        address[] memory _tokens,
        uint256[] memory _amounts,
        address _owner
    ) internal returns (uint256) {
        require(
            _tokens.length == _amounts.length,
            "Item: invalid token or amount length"
        );

        lastItemObjectId += 1;
        require(
            lastItemObjectId <= 340282366920938463463374607431768211455,
            "Item: object id overflow."
        );

        Item memory item = Item({
            class: _class,
            grade: _grade,
            prefer: _prefer,
            index: _index,
            rate: _rate,
            canDisenchant: _canDisenchant,
            major: _major,
            tokens: _tokens,
            amounts: _amounts
        });
        uint256 tokenId = IObjectOwnership(
            registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)
        )
            .mintObject(_owner, uint128(lastItemObjectId));
        tokenId2Item[tokenId] = item;
        emit Create(
            _owner,
            tokenId,
            item.class,
            item.grade,
            item.prefer,
            item.index,
            item.rate,
            item.canDisenchant,
            item.major,
            item.tokens,
            item.amounts,
            now
        );
        return tokenId;
    }

    /**
     * @dev destroy a Item.
     * @param _to owner of the item.
     * @param _tokenId tokenId of the item.
     */
    function destroyItem(address _to, uint256 _tokenId) public auth {
        IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
            _to,
            _tokenId
        );
        emit Destroy(_to, _tokenId);
    }
}
