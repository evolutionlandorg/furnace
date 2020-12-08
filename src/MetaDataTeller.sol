pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IDrillBase.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IELIP002.sol";
import "./FurnaceSettingIds.sol";

contract MetaDataTeller is DSMath, FurnaceSettingIds {
	// 金, Evolution Land Gold
	// 木, Evolution Land Wood
	// 水, Evolution Land Water
	// 火, Evolution Land fire
	// 土, Evolution Land Silicon
	enum Element { NaN, GOLD, WOOD, WATER, FIRE, SOIL }

	ISettingsRegistry public registry;

	/**
	 * @dev mapping from resource lptoken address to resource atrribute rate id.
	 * atrribute rate id starts from 1 to 16, NAN is 0.
	 * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
	 */
	mapping(address => uint8) public resourceLPToken2RateAttrId;

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

	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16)
	{
		//TODO:: teller
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
				objectClass == DRILL_OBJECT_CLASS ||
				// TODO::grade decode change?
				objectClass == DARWINIA_OBJECT_CLASS
			) {
				return (0, IDrillBase(nftAddress).getGrade(_id));
			}
		}
		return (0, 1);
	}

	function getPrefer(bytes32 _name, address _token)
		external
		view
		returns (uint256)
	{
		if (
			_name == CONTRACT_ELEMENT_ERC20_TOKEN ||
			_name == CONTRACT_LP_ELEMENT_ERC20_TOKEN
		) {
			uint256 index =
				ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
					.resourceToken2RateAttrId(_token) > 0
					? ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
						.resourceToken2RateAttrId(_token)
					: resourceLPToken2RateAttrId[_token];
			require(index > 0 && index < 6, "Not support minor token address.");
			return index;
		} else {
			require(
				_token == registry.addressOf(CONTRACT_LP_RING_ERC20_TOKEN) ||
					_token == registry.addressOf(CONTRACT_LP_KTON_ERC20_TOKEN),
				"Not support LP-token address."
			);
		}
		return 0;
	}

	function getRate(
		address _token,
		uint256 _id,
		uint256 _index
	) external view returns (uint256) {
		if (_token == registry.addressOf(CONTRACT_ITEM_BASE)) {
			return IELIP002(_token).getRate(_id, _index);
		} else {
			return 0;
		}
	}

	// ignore fee
	// function getLiquidity(
	// 	address pair,
	// 	address token,
	// 	uint256 amount
	// ) external view returns (uint256) {
	// 	require(pair != address(0), "Invalid pair.");
	// 	require(token != address(0), "Invalid pair.");
	// 	uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
	// 	if (token == IUniswapV2Pair(pair).token0()) {
	// 		(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
	// 		return mul(amount, totalSupply) / uint256(reserve0);
	// 	} else if (token == IUniswapV2Pair(pair).token1()) {
	// 		(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
	// 		return mul(amount, totalSupply) / uint256(reserve1);
	// 	} else {
	// 		revert("Invalid token.");
	// 	}
	// }

	// ignore fee
	// function getLiquidityValue(
	// 	address pair,
	// 	address token,
	// 	uint256 liquidity
	// ) external view returns (uint256) {
	// 	require(pair != address(0), "Invalid pair.");
	// 	require(token != address(0), "Invalid pair.");
	// 	uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
	// 	if (token == IUniswapV2Pair(pair).token0()) {
	// 		(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
	// 		return mul(liquidity, uint256(reserve0)) / totalSupply;
	// 	} else if (token == IUniswapV2Pair(pair).token1()) {
	// 		(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
	// 		return mul(liquidity, uint256(reserve1)) / totalSupply;
	// 	} else {
	// 		revert("Invalid token.");
	// 	}
	// }
}
