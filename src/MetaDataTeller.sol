pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IELIP002.sol";
import "./FurnaceSettingIds.sol";

contract MetaDataTeller is DSAuth, DSMath, FurnaceSettingIds {
	event AddLPToken(bytes32 _class, address _lpToken, uint8 _resourceId);
	event AddInternalTokenMeta(
		bytes32 indexed token,
		uint16 grade,
		uint256 trengthRate
	);
	event AddExternalTokenMeta(
		address indexed token,
		uint16 objectClassExt,
		uint16 grade,
		uint256 trengthRate
	);
	event RemoveLPToken(bytes32 _class, address _lpToken);
	event RemoveExternalTokenMeta(address indexed token);
	event RemoveInternalTokenMeta(bytes32 indexed token, uint16 grade);

	struct Meta {
		uint16 objectClassExt;
		mapping(uint16 => uint256) grade2StrengthRate;
	}

	uint16 internal constant _EXTERNAL_DEFAULT_CLASS = 0;
	uint16 internal constant _EXTERNAL_DEFAULT_GRADE = 1;

    bool private singletonLock = false;
	ISettingsRegistry public registry;
	/**
	 * @dev mapping from resource lptoken address to resource atrribute rate id.
	 * atrribute rate id starts from 1 to 15, NAN is 0.
	 * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
	 */
	// (ID => (LP_TOKENA_TOKENB => resourceId))
	mapping(bytes32 => mapping(address => uint8))
		public resourceLPToken2RateAttrId;
	mapping(address => Meta) public externalToken2Meta;
	mapping(bytes32 => mapping(uint16 => uint256)) public internalToken2Meta;

	modifier singletonLockCall() {
		require(!singletonLock, "Only can call once");
		_;
		singletonLock = true;
	}

	function initializeContract(address _registry) public singletonLockCall {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		// resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
		// 	registry.addressOf(CONTRACT_LP_GOLD_ERC20_TOKEN)
		// ] = 1;
		// resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
		// 	registry.addressOf(CONTRACT_LP_WOOD_ERC20_TOKEN)
		// ] = 2;
		// resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
		// 	registry.addressOf(CONTRACT_LP_WATER_ERC20_TOKEN)
		// ] = 3;
		// resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
		// 	registry.addressOf(CONTRACT_LP_FIRE_ERC20_TOKEN)
		// ] = 4;
		// resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
		// 	registry.addressOf(CONTRACT_LP_SOIL_ERC20_TOKEN)
		// ] = 5;
	}

	function addLPToken(
		bytes32 _id,
		address _lpToken,
		uint8 _resourceId
	) public auth {
		require(
			_resourceId > 0 && _resourceId < 6,
			"Furnace: INVALID_RESOURCEID"
		);
		resourceLPToken2RateAttrId[_id][_lpToken] = _resourceId;
		emit AddLPToken(_id, _lpToken, _resourceId);
	}

	function addInternalTokenMeta(
		bytes32 _token,
		uint16 _grade,
		uint256 _strengthRate
	) public auth {
		internalToken2Meta[_token][_grade] = _strengthRate;
		emit AddInternalTokenMeta(_token, _grade, _strengthRate);
	}

	function addExternalTokenMeta(
		address _token,
		uint16 _objectClassExt,
		uint16 _grade,
		uint256 _strengthRate
	) public auth {
		require(_objectClassExt > 0, "Furnace: INVALID_OBJCLASSEXT");
		externalToken2Meta[_token].objectClassExt = _objectClassExt;
		externalToken2Meta[_token].grade2StrengthRate[_grade] = _strengthRate;
		emit AddExternalTokenMeta(
			_token,
			_objectClassExt,
			_grade,
			_strengthRate
		);
	}

	function removeLPToken(bytes32 _id, address _lpToken) public auth {
		require(
			resourceLPToken2RateAttrId[_id][_lpToken] > 0,
			"Furnace: EMPTY"
		);
		delete resourceLPToken2RateAttrId[_id][_lpToken];
		emit RemoveLPToken(_id, _lpToken);
	}

	function removeExternalTokenMeta(address _token) public auth {
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: EMPTY"
		);
		delete externalToken2Meta[_token];
		emit RemoveExternalTokenMeta(_token);
	}

	function removeInternalTokenMeta(bytes32 _token, uint16 _grade)
		public
		auth
	{
		delete internalToken2Meta[_token][_grade];
		emit RemoveInternalTokenMeta(_token, _grade);
	}

	function getExternalObjectClassExt(address _token)
		public
		view
		returns (uint16)
	{
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: NOT_SUPPORT"
		);
		return externalToken2Meta[_token].objectClassExt;
	}

	function getExternalStrengthRate(address _token, uint16 _grade)
		public
		view
		returns (uint256)
	{
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: NOT_SUPPORT"
		);
		return uint256(externalToken2Meta[_token].grade2StrengthRate[_grade]);
	}

	function getInternalStrengthRate(bytes32 _token, uint16 _grade)
		public
		view
		returns (uint256)
	{
        require(internalToken2Meta[_token][_grade] > 0, "Furnace: NOT_SUPPORT");
		return uint256(internalToken2Meta[_token][_grade]);
	}

	function getMetaData(address _token, uint256 _id)
		public
		view
		returns (
			uint16,
			uint16,
			uint16
		)
	{
		if (_token == registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)) {
			uint8 objectClass =
				IInterstellarEncoder(
					registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)
				)
					.getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return
					IELIP002(registry.addressOf(CONTRACT_ITEM_BASE))
						.getBaseInfo(_id);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				return (
					objectClass,
					_EXTERNAL_DEFAULT_CLASS,
					getDrillGrade(_id)
				);
			} 
		}
		// external token
		return (
			getExternalObjectClassExt(_token),
			_EXTERNAL_DEFAULT_CLASS,
			_EXTERNAL_DEFAULT_GRADE
		);
	}

	function getDrillGrade(uint256 _tokenId) public pure returns (uint16) {
		uint128 objectId = uint128(_tokenId);
		return uint16(objectId >> 112);
	}

	function getPrefer(bytes32 _minor, address _token)
		external
		view
		returns (uint256)
	{
		if (_minor == CONTRACT_ELEMENT_TOKEN) {
			return
				ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
					.resourceToken2RateAttrId(_token);
		} else {
			return resourceLPToken2RateAttrId[_minor][_token];
		}
	}

	function getRate(
		address _token,
		uint256 _id,
		uint256 _element
	) external view returns (uint256) {
		if (_token == address(0)) {
			return 0;
		}
		if (_token == registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)) {
			uint8 objectClass =
				IInterstellarEncoder(
					registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)
				)
					.getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return
					IELIP002(registry.addressOf(CONTRACT_ITEM_BASE)).getRate(
						_id,
						_element
					);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				uint16 grade = getDrillGrade(_id);
				return getInternalStrengthRate(CONTRACT_DRILL_BASE, grade);
			} 
		}
		return getExternalStrengthRate(_token, _EXTERNAL_DEFAULT_GRADE);
	}
}
