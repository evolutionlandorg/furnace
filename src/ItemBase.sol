pragma solidity ^0.6.7;

// import "zeppelin-solidity/introspection/SupportsInterfaceWithLookup.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IObjectOwnership.sol";
import "./FurnaceSettingIds.sol";

contract ItemBase is Initializable, DSAuth, FurnaceSettingIds {
	event Create(
		address indexed owner,
		uint256 indexed tokenId,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		uint16 formulaIndex,
		uint16 rate,
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
	}

	/*** STORAGE ***/
	uint128 public lastItemObjectId;

	ISettingsRegistry public registry;

	mapping(uint256 => Item) public tokenId2Item;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);

		registry = ISettingsRegistry(_registry);
		//TODO:: trick
		lastItemObjectId = 1000;
	}

	/**
	 * @dev create a Item.
	 * @param _class - Item class.
	 * @param _grade - Item grade.
	 * @param _prefer -  Item element prefer.
	 * @param _index - Item formula index.
	 * @param _rate - Item enhance strength rate.
	 * @param _owner - owner of the Item.
	 * @return Item - tokenId.
	 */
	function createItem(
		uint16 _class,
		uint16 _grade,
		uint16 _prefer,
		uint16 _index,
		uint16 _rate,
		address _owner
	) public auth returns (uint256) {
		return _createItem(_class, _grade, _prefer, _index, _rate, _owner);
	}

	function _createItem(
		uint16 _class,
		uint16 _grade,
		uint16 _prefer,
		uint16 _index,
		uint16 _rate,
		address _owner
	) internal returns (uint256) {
		lastItemObjectId += 1;
		require(
			lastItemObjectId <= 340282366920938463463374607431768211455,
			"Item: object id overflow."
		);

		Item memory item =
			Item({
				class: _class,
				grade: _grade,
				prefer: _prefer,
				index: _index,
				rate: _rate
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
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
			now // solhint-disable-line
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
		delete tokenId2Item[_tokenId];
		emit Destroy(_to, _tokenId);
	}

	function getBaseInfo(uint256 _tokenId)
		public
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint16,
			uint16
		)
	{
		Item memory item = tokenId2Item[_tokenId];
		return (item.class, item.grade, item.prefer, item.index, item.rate);
	}
}
