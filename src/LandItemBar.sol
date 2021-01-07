pragma solidity ^0.6.7;

import "ds-auth/auth.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ERC721Receiver.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/ILandResource.sol";

contract LandItemBar is Initializable, DSAuth, DSMath {
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
	event ForceUnequip(
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

	// 0x55494e545f4954454d4241525f50524f544543545f504552494f440000000000
	bytes32 public constant UINT_ITEMBAR_PROTECT_PERIOD =
		"UINT_ITEMBAR_PROTECT_PERIOD";

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
	mapping(address => mapping(uint256 => uint256)) public protectPeriod;

	IERC721 public ownership;
	ILandResource public landResource;
	IInterstellarEncoder public interstellarEncoder; 
	IMetaDataTeller public teller;
	address public gold;
	address public wood;
	address public water;
	address public fire;
	address public soil;

	modifier updateMinerStrength(uint256 _landTokenId) {
		landResource.updateAllMinerStrengthWhenStop(
			_landTokenId
		);
		_;
		landResource.updateAllMinerStrengthWhenStart(
			_landTokenId
		);
	}

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;

		refresh();
	}

	function refresh() public virtual auth {
		ownership = IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
		landResource = ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE));
		interstellarEncoder = IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER));
		teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));

		gold = registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		wood = registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		water = registry.addressOf(CONTRACT_WATER_ERC20_TOKEN);
		fire = registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		soil = registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN);
	}

	function isLander(uint256 _landTokenId) 
		public
		view
		returns (bool)
	{
		return ownership.ownerOf(_landTokenId) == msg.sender;
	}

	function isAllowed(uint256 _landTokenId, address _token, uint256 _id)
		public
		view
		returns (bool)
	{
        require(interstellarEncoder.getObjectClass(_landTokenId) == 1, "Funace: ONLY_LAND");
		return teller.isAllowed(_token, _id);
	}

	function isNotProtect(address _token, uint256 _id)
		public
		view
		returns (bool)
	{
		return protectPeriod[_token][_id] < now;	
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

	/**
        @dev Equip function, A NFT can equip to EVO Bar (LandBar or ApostleBar).
        @param _tokenId Token Id which to be quiped.
        @param _index   Index of the Bar.
        @param _token   Token address which to quip.
        @param _id      Token Id which to quip.
    */
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
	) internal {
		require(isAllowed(_tokenId, _token, _id), "Furnace: PERMISSION");
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token != address(0) && isNotProtect(bar.token, bar.id)) {
			(, uint16 class, ) = teller.getMetaData(_token, _id);
			(, uint16 originClass, ) = teller.getMetaData(bar.token, bar.id);
			require(class > originClass || isLander(_tokenId), "Furnace: FORBIDDEN");
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
		if (isNotProtect(bar.token, bar.id)) {
			protectPeriod[bar.token][bar.id] = add(calculateProtectPeriod(bar.token, bar.id), now);
		}
		emit Equip(_tokenId, _index, bar.staker, bar.token, bar.id);
	}

	function calculateProtectPeriod(address _token, uint256 _id) internal view returns (uint256)  {
		(, uint16 class, ) = teller.getMetaData(_token, _id);
		uint256 baseProtectPeriod = registry.uintOf(UINT_ITEMBAR_PROTECT_PERIOD);
		return add(baseProtectPeriod, mul(uint256(class), baseProtectPeriod));
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

	/**
        @dev Unequip function, A NFT can unequip from EVO Bar (LandBar or ApostleBar).
        @param _tokenId Token Id which to be unquiped.
        @param _index   Index of the Bar.
    */
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

	function _forceUneqiup(uint256 _landTokenId, uint256 _index)
		internal
		updateMinerStrength(_landTokenId)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		Bar storage bar = tokenId2Bars[_landTokenId][_index];
		if (bar.token == address(0)) return;
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit ForceUnequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		delete bar.rates[gold];
		delete bar.rates[wood];
		delete bar.rates[water];
		delete bar.rates[fire];
		delete bar.rates[soil];
		delete itemId2Index[bar.token][bar.id];
		delete tokenId2Bars[_landTokenId][_index];
	}

	function isAmbassador(uint256 _landTokenId) public pure returns (bool) {
		uint128 objectId = uint128(_landTokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
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
