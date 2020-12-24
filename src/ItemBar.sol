pragma solidity ^0.6.7;

import "ds-auth/auth.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ERC721Receiver.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/ILandResource.sol";

abstract contract ItemBar is DSAuth, DSMath {
	event Equip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);
	event Unequip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f4c414e445f5245534f5552434500000000000000000000
	bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	struct Bar {
		address staker;
		address token;
		uint256 id;
		mapping(address => uint256) rates;
	}

	struct Status {
		address staker;
		uint256 tokenId;
		uint256 index;
	}

	ISettingsRegistry public registry;
	uint256 public maxAmount;
	mapping(uint256 => mapping(uint256 => Bar)) public tokenId2Bars;
	mapping(address => mapping(uint256 => Status)) public itemId2Index;

	IMetaDataTeller public teller;
	address public gold;
	address public wood;
	address public water;
	address public fire;
	address public soil;


	modifier onlyAuth(uint256 _tokenId, uint256 _index) virtual { _; }

	modifier updateMinerStrength(uint256 _tokenId) virtual { _; }

	function isAllowed(
		uint256 _tokenId,
		address _token,
		uint256 _id
	) public view virtual returns (bool);

	constructor(address _registry, uint256 _maxAmount) internal {
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

	function refresh() public virtual auth {
		teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));

		gold = registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		wood = registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		water = registry.addressOf(CONTRACT_WATER_ERC20_TOKEN);
		fire = registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		soil = registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN);
	}

	function getTokenIdByItem(address _item, uint256 _itemId)
		public
		view
		returns (address, uint256)
	{
		return (
			itemId2Index[_item][_itemId].staker,
			itemId2Index[_item][_itemId].tokenId
		);
	}

	function getBarStaker(uint256 _tokenId, uint256 _index)
		public
		view
		returns (address)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN.");
		return tokenId2Bars[_tokenId][_index].staker;
	}

	function getBarItem(uint256 _tokenId, uint256 _index)
		public
		view
		returns (address, uint256)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN.");
		return (
			tokenId2Bars[_tokenId][_index].token,
			tokenId2Bars[_tokenId][_index].id
		);
	}

	function batchEquip(
		uint256 _tokenId,
		uint256[] calldata _indexes,
		address[] calldata _tokens,
		uint256[] calldata _ids
	) external updateMinerStrength(_tokenId) {
		require(
			_indexes.length <= maxAmount &&
				_indexes.length > 0 &&
				_indexes.length == _tokens.length &&
				_indexes.length == _ids.length,
			"Furnace: INVALID_LENGTH."
		);
		for (uint256 i = 0; i < _indexes.length; i++) {
			_equip(_tokenId, _indexes[i], _tokens[i], _ids[i]);
		}
	}

	function equip(
		uint256 _tokenId,
		uint256 _index,
		address _token,
		uint256 _id
	) public updateMinerStrength(_tokenId) {
		_equip(_tokenId, _index, _token, _id);
	}

	function _equip(
		uint256 _tokenId,
		uint256 _index,
		address _token,
		uint256 _id
	) internal onlyAuth(_tokenId, _index) {
		require(isAllowed(_tokenId, _token, _id), "Furnace: PERMISSION");
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token != address(0)) {
			(, uint16 class, ) = teller.getMetaData(_token, _id);

			(, uint16 originClass, ) = teller.getMetaData(bar.token, bar.id);
			require(class > originClass, "Furnace: INVALID_CLASS");
			IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		}
		IERC721(_token).transferFrom(msg.sender, address(this), _id);

		bar.staker = msg.sender;
		bar.token = _token;
		bar.id = _id;
		bar.rates[gold] = teller.getRate(bar.token, bar.id, 1);
		bar.rates[wood] = teller.getRate(bar.token, bar.id, 2);
		bar.rates[water] = teller.getRate(bar.token, bar.id, 3);
		bar.rates[fire] = teller.getRate(bar.token, bar.id, 4);
		bar.rates[soil] = teller.getRate(bar.token, bar.id, 5);
		itemId2Index[bar.token][bar.id] = Status({
			staker: bar.staker,
			tokenId: _tokenId,
			index: _index
		});
		emit Equip(_tokenId, _index, bar.staker, bar.token, bar.id);
	}

	function batchUnquip(uint256 _tokenId, uint256[] calldata _indexes)
		external
		updateMinerStrength(_tokenId)
	{
		require(
			_indexes.length <= maxAmount && _indexes.length > 0,
			"Furnace: INVALID_LENGTH"
		);
		for (uint256 i = 0; i < _indexes.length; i++) {
			_unequip(_tokenId, _indexes[i]);
		}
	}

	function unequip(uint256 _tokenId, uint256 _index)
		public
		updateMinerStrength(_tokenId)
	{
		_unequip(_tokenId, _index);
	}

	function _unequip(uint256 _tokenId, uint256 _index) internal {
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		require(bar.token != address(0), "Furnace: EMPTY");
		require(bar.staker == msg.sender, "Furnace: FORBIDDEN");
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit Unequip(_tokenId, _index, bar.staker, bar.token, bar.id);
		//TODO: check
		delete bar.rates[gold];
		delete bar.rates[wood];
		delete bar.rates[water];
		delete bar.rates[fire];
		delete bar.rates[soil];
		delete itemId2Index[bar.token][bar.id];
		delete tokenId2Bars[_tokenId][_index];
	}

	function setMaxAmount(uint256 _maxAmount) public auth {
		require(_maxAmount > maxAmount, "Furnace: INVALID_MAXAMOUNT");
		maxAmount = _maxAmount;
	}

	function enhanceStrengthRateByIndex(
		address _resource,
		uint256 _tokenId,
		uint256 _index
	) external view returns (uint256) {
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token == address(0)) {
			return 0;
		}
		return bar.rates[_resource];
	}

	function enhanceStrengthRateOf(address _resource, uint256 _tokenId)
		external
		view
		returns (uint256)
	{
		uint256 rate;
		for (uint256 i = 0; i < maxAmount; i++) {
			Bar storage bar = tokenId2Bars[_tokenId][i];
			if (bar.token == address(0)) {
				continue;
			}
			rate = add(rate, bar.rates[_resource]);
		}
		return rate;
	}
}
