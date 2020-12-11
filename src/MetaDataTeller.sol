pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IDrillBase.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IELIP002.sol";
import "./FurnaceSettingIds.sol";

contract MetaDataTeller is DSAuth, DSMath, FurnaceSettingIds {
	event AddTokenMeta(
		address indexed token,
		uint16 grade,
		uint112 trengthRate
	);
	event RemoveTokenMeta(address indexed token);
	// 金, Evolution Land Gold
	// 木, Evolution Land Wood
	// 水, Evolution Land Water
	// 火, Evolution Land fire
	// 土, Evolution Land Silicon
	enum Element { NaN, GOLD, WOOD, WATER, FIRE, SOIL }

	struct Meta {
		uint16 grade;
		uint112 strengthRate;
		bool isSupport;
	}

	ISettingsRegistry public registry;
	/**
	 * @dev mapping from resource lptoken address to resource atrribute rate id.
	 * atrribute rate id starts from 1 to 15, NAN is 0.
	 * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
	 */
	mapping(address => uint8) public resourceLPToken2RateAttrId;
	mapping(address => Meta) public token2Meta;

	constructor(address _registry) public {
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

	function addTokenMeta(
		address _token,
		uint16 _grade,
		uint112 _strengthRate
	) public auth {
		Meta memory meta =
			Meta({
				grade: _grade,
				strengthRate: _strengthRate,
				isSupport: true
			});
		token2Meta[_token] = meta;
		emit AddTokenMeta(_token, meta.grade, meta.strengthRate);
	}

	function removeTokenMeta(address _token) public auth {
		require(token2Meta[_token].isSupport == true, "Furnace: EMPTY");
		delete token2Meta[_token];
		emit RemoveTokenMeta(_token);
	}

	function getExternalGrade(address _token) public view returns (uint16) {
		require(token2Meta[_token].isSupport == true, "Furnace: NOT_SUPPORT");
		return token2Meta[_token].grade;
	}

	function getExternalStrengthRate(address _token)
		public
		view
		returns (uint256)
	{
		require(token2Meta[_token].isSupport == true, "Furnace: NOT_SUPPORT");
		return uint256(token2Meta[_token].strengthRate);
	}

	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16)
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
			} else if (
				//TODO:: internal token
				objectClass == DRILL_OBJECT_CLASS ||
				// TODO::grade decode change?
				objectClass == DARWINIA_OBJECT_CLASS
			) {
				return (0, IDrillBase(nftAddress).getGrade(_id));
			}
		}
		// external token
		return (0, getExternalGrade(_token));
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
		uint256 _index
	) external view returns (uint256) {
		if (_token == registry.addressOf(CONTRACT_ITEM_BASE)) {
			return IELIP002(_token).getRate(_id, _index);
		} else {
			return getExternalStrengthRate(_token);
		}
	}
}
