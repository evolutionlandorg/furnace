pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-auth/auth.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IELIP002.sol";
import "./FurnaceSettingIds.sol";

contract MetaDataTeller is Initializable, DSAuth, DSMath, FurnaceSettingIds {
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
	event RemoveExternalTokenMeta(address indexed token);
	event RemoveInternalTokenMeta(bytes32 indexed token, uint16 grade);

	struct Meta {
		uint16 objectClassExt;
		mapping(uint16 => uint256) grade2StrengthRate;
	}

	uint16 internal constant _EXTERNAL_DEFAULT_CLASS = 0;
	uint16 internal constant _EXTERNAL_DEFAULT_GRADE = 1;

	ISettingsRegistry public registry;
	/**
	 * @dev mapping from resource lptoken address to resource atrribute rate id.
	 * atrribute rate id starts from 1 to 15, NAN is 0.
	 * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
	 */
	mapping(address => uint8) public resourceLPToken2RateAttrId;
	mapping(address => Meta) public externalToken2Meta;
	mapping(bytes32 => mapping(uint16 => uint256)) public internalToken2Meta;

	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		resourceLPToken2RateAttrId[
			registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN)
		] = 1;
		resourceLPToken2RateAttrId[
			registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN)
		] = 2;
		resourceLPToken2RateAttrId[
			registry.addressOf(CONTRACT_WATER_ERC20_TOKEN)
		] = 3;
		resourceLPToken2RateAttrId[
			registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN)
		] = 4;
		resourceLPToken2RateAttrId[
			registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN)
		] = 5;
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
		return uint256(internalToken2Meta[_token][_grade]);
	}

	function isAllowed(address _token, uint256 _id) public view returns (bool) {
		(uint16 objClassExt, , ) = getMetaData(_token, _id);
		return objClassExt > 0;
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
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		if (_token == ownership) {
			address interstellarEncoder =
				registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
			uint8 objectClass =
				IInterstellarEncoder(interstellarEncoder).getObjectClass(_id);
			address nftAddress =
				IInterstellarEncoder(interstellarEncoder).getContractAddress(
					_id
				);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return IELIP002(nftAddress).getBaseInfo(_id);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				return (
					objectClass,
					_EXTERNAL_DEFAULT_CLASS,
					getDrillGrade(_id)
				);
			} else if (objectClass == DARWINIA_OBJECT_CLASS) {
				//TODO:: check ONLY_AMBASSADOR
				require(isAmbassador(_id), "Furnace: ONLY_AMBASSADOR");
				return (
					objectClass,
					_EXTERNAL_DEFAULT_CLASS,
					getDarwiniaGrade(_id)
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

	function isAmbassador(uint256 _tokenId) public pure returns (bool) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}

	function getDarwiniaGrade(uint256 _tokenId) public pure returns (uint16) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0x3FF);
	}

	function getPrefer(address _token) external view returns (uint256) {
		return
			ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
				.resourceToken2RateAttrId(_token) > 0
				? ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
					.resourceToken2RateAttrId(_token)
				: resourceLPToken2RateAttrId[_token];
	}

	function getRate(
		address _token,
		uint256 _id,
		uint256 _element
	) external view returns (uint256) {
		if (_token == address(0)) {
			return 0;
		}
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		if (_token == ownership) {
			address interstellarEncoder =
				registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
			uint8 objectClass =
				IInterstellarEncoder(interstellarEncoder).getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return IELIP002(_token).getRate(_id, _element);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				uint16 grade = getDrillGrade(_id);
				return getInternalStrengthRate(CONTRACT_DRILL_BASE, grade);
			} else if (objectClass == DARWINIA_OBJECT_CLASS) {
				//TODO:: check ONLY_AMBASSADOR
				require(isAmbassador(_id), "Furnace: ONLY_AMBASSADOR");
				uint16 grade = getDarwiniaGrade(_id);
				return
					getInternalStrengthRate(CONTRACT_DARWINIA_ITO_BASE, grade);
			}
		}
		return getExternalStrengthRate(_token, _EXTERNAL_DEFAULT_GRADE);
	}
}
