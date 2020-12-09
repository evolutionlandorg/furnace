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

	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item

	struct Bar {
		address staker;
		address token;
		uint256 id;
		bool isPrivate;
	}

	ISettingsRegistry registry;
	uint256 public maxAmount;
	mapping(address => bool) public allowList;
	mapping(uint256 => mapping(uint256 => Bar)) public token2Bars;

	modifier onlyAuth(uint256 _tokenId, uint256 _index) virtual { _; }

	modifier updateMinerStrength(uint256 _tokenId) virtual { _; }

	constructor(address _registry, uint256 _maxAmount) internal {
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

	function getBarStaker(uint256 _tokenId, uint256 _index)
		public
		view
		returns (address)
	{
		Bar memory bar = token2Bars[_tokenId][_index];
		return bar.staker;
	}

	function batchEquip(
		uint256 _tokenId,
		uint256[] memory _indexes,
		address[] memory _tokens,
		uint256[] memory _ids
	) public updateMinerStrength(_tokenId) {
		require(
			_indexes.length <= maxAmount && _indexes.length > 0,
			"Invalid length."
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
		require(isAllowed(_token, _tokenId), "Not allow.");
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = token2Bars[_tokenId][_index];
		if (bar.token != address(0)) {
			address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
			(uint16 class, ) =
				IMetaDataTeller(teller).getMetaData(_token, _tokenId);

			(uint16 originClass, ) =
				IMetaDataTeller(teller).getMetaData(bar.token, bar.id);
			require(
				class > originClass,
				"Item class is less than origin class."
			);
			IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		}
		IERC721(_token).transferFrom(msg.sender, address(this), _id);

		bar.staker = msg.sender;
		bar.token = _token;
		bar.id = _id;
		emit Equip(_tokenId, _index, bar.staker, bar.token, bar.id);
	}

	function batchUnquip(uint256 _tokenId, uint256[] memory _indexes)
		public
		updateMinerStrength(_tokenId)
	{
		require(
			_indexes.length <= maxAmount && _indexes.length > 0,
			"Invalid length."
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
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = token2Bars[_tokenId][_index];
		require(bar.token != address(0), "Empty.");
		require(bar.staker == msg.sender, "Forbidden.");
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit Unequip(_tokenId, _index, bar.staker, bar.token, bar.id);
		bar.staker = address(0);
		bar.token = address(0);
		bar.id = 0;
	}

	function setMaxAmount(uint256 _maxAmount) public auth {
		maxAmount = _maxAmount;
	}

	function addSupportedToken(address _token) public auth {
		allowList[_token] = true;
	}

	function removeSupportedToken(address _token) public auth {
		allowList[_token] = false;
	}

	function isAllowed(address _token, uint256 _id) public view returns (bool) {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		if (_token == ownership) {
			address interstellarEncoder =
				registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
			uint8 objectClass =
				IInterstellarEncoder(interstellarEncoder).getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return true;
			} else {
				return false;
			}
		} else {
			return allowList[_token];
		}
	}

	function enhanceStrengthRateByindex(
		address _resourceToken,
		uint256 _tokenId,
		uint256 _index
	) public view returns (uint256) {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		Bar memory bar = token2Bars[_tokenId][_index];
		uint256 index =
			ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
				.resourceToken2RateAttrId(_resourceToken);
		return IMetaDataTeller(teller).getRate(bar.token, bar.id, index);
	}

	function enhanceStrengthRateOf(address _resourceToken, uint256 _tokenId)
		public
		view
		returns (uint256)
	{
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		uint256 index =
			ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
				.resourceToken2RateAttrId(_resourceToken);
		uint256 rate;
		for (uint256 i = 0; i < maxAmount; i++) {
			Bar memory bar = token2Bars[_tokenId][i];
			uint256 itemRate =
				IMetaDataTeller(teller).getRate(bar.token, bar.id, index);
			rate = add(rate, itemRate);
		}
		return rate;
	}
}
