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
		address resource,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);
	event Unequip(
		uint256 indexed tokenId,
		address resource,
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
	}

	struct Status {
		address staker;
		uint256 tokenId;
		address resource;
		uint256 index;
	}

	ISettingsRegistry public registry;
	uint256 public maxAmount;
	mapping(uint256 => mapping(uint256 => Bar)) public tokenId2Bars;
	mapping(address => mapping(uint256 => Status)) public itemId2Index;
	mapping(address => mapping(uint256 => uint256)) public protectPeriod;

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

	function isLander(uint256 _landTokenId) 
		public
		view
		returns (bool)
	{
		return IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_landTokenId) == msg.sender;
	}

	function isAllowed(uint256 _landTokenId, address _token, uint256 _id)
		public
		view
		returns (bool)
	{
        require(IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectClass(_landTokenId) == 1, "Funace: ONLY_LAND");
		return IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER)).isAllowed(_token, _id);
	}

	function isNotProtect(address _token, uint256 _id)
		public
		view
		returns (bool)
	{
		return protectPeriod[_token][_id] < now;	
	}

	function getStatusByItem(address _item, uint256 _itemId)
		public
		view
		returns (address, uint256, address, uint256)
	{
		return (
			itemId2Index[_item][_itemId].staker,
			itemId2Index[_item][_itemId].tokenId,
			itemId2Index[_item][_itemId].resource,
			itemId2Index[_item][_itemId].index
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
		returns (address, uint256, address)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN.");
		address token = tokenId2Bars[_tokenId][_index].token; 
		uint256 id = tokenId2Bars[_tokenId][_index].id;
		return (
			token,
			id,
			itemId2Index[token][id].resource
		);
	}

	/**
        @dev Equip function, A NFT can equip to EVO Bar (LandBar or ApostleBar).
        @param _tokenId  Token Id which to be quiped.
        @param _resource Which resouce appply to.
        @param _index    Index of the Bar.
        @param _token    Token address which to quip.
        @param _id       Token Id which to quip.
    */
	function equip(
		uint256 _tokenId,
		address _resource,
		uint256 _index,
		address _token,
		uint256 _id
	) public {
		_equip(_tokenId, _resource, _index, _token, _id);
	}

	function _equip(
		uint256 _tokenId,
		address _resource,
		uint256 _index,
		address _token,
		uint256 _id
	) internal {
		uint256 resourceId = ILandBase(registry.addressOf(CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resource);
		require(resourceId > 0 && resourceId < 6, "Furnace: INVALID_RESOURCE");
		require(isAllowed(_tokenId, _token, _id), "Furnace: PERMISSION");
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		IMetaDataTeller teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token != address(0) && isNotProtect(bar.token, bar.id)) {
			(, uint16 class, ) = teller.getMetaData(_token, _id);
			(, uint16 originClass, ) = teller.getMetaData(bar.token, bar.id);
			require(class >= originClass || isLander(_tokenId), "Furnace: FORBIDDEN");
			IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		}
		IERC721(_token).transferFrom(msg.sender, address(this), _id);

		bar.staker = msg.sender;
		bar.token = _token;
		bar.id = _id;
		itemId2Index[bar.token][bar.id] = Status({
			staker: bar.staker,
			tokenId: _tokenId,
			resource: _resource,
			index: _index
		});
		if (isNotProtect(bar.token, bar.id)) {
			protectPeriod[bar.token][bar.id] = add(calculateProtectPeriod(bar.token, bar.id), now);
		}
		afterEquiped(_index, _tokenId, _resource);
		emit Equip(_tokenId, _resource, _index, bar.staker, bar.token, bar.id);
	}

	function calculateProtectPeriod(address _token, uint256 _id) internal view returns (uint256)  {
		(, uint16 class, ) = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER)).getMetaData(_token, _id);
		uint256 baseProtectPeriod = registry.uintOf(UINT_ITEMBAR_PROTECT_PERIOD);
		return add(baseProtectPeriod, mul(uint256(class), baseProtectPeriod));
	}

	function afterEquiped(uint256 _index, uint256 _landTokenId, address _resource) internal {
		ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE)).afterLandItemBarEquiped(
			_index,
			_landTokenId,
			_resource
		);
	}

	function afterUnequiped(uint256 _index, uint256 _landTokenId, address _resource) internal {
		ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE)).afterLandItemBarUnequiped(
			_index,
			_landTokenId,
			_resource
		);
	}

	/**
        @dev Unequip function, A NFT can unequip from EVO Bar (LandBar or ApostleBar).
        @param _tokenId Token Id which to be unquiped.
        @param _index   Index of the Bar.
    */
	function unequip(uint256 _tokenId, uint256 _index)
		public
	{
		_unequip(_tokenId, _index);
	}

	function _unequip(uint256 _tokenId, uint256 _index) internal {
		Bar memory bar = tokenId2Bars[_tokenId][_index];
		require(bar.token != address(0), "Furnace: EMPTY");
		require(bar.staker == msg.sender, "Furnace: FORBIDDEN");
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		//TODO: check
		address resource = itemId2Index[bar.token][bar.id].resource;
		afterUnequiped(_index, _tokenId, resource);
		//clean
		delete itemId2Index[bar.token][bar.id];
		delete tokenId2Bars[_tokenId][_index];
		require(resource != address(0), "Furnace: REMOVED");
		emit Unequip(_tokenId, resource, _index, bar.staker, bar.token, bar.id);
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
		IMetaDataTeller teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));
		uint256 resourceId = ILandBase(registry.addressOf(CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resource);
		return teller.getRate(bar.token, bar.id, resourceId);
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
			IMetaDataTeller teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));
			uint256 resourceId = ILandBase(registry.addressOf(CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resource);
			rate = add(rate, teller.getRate(bar.token, bar.id, resourceId));
		}
		return rate;
	}
}
