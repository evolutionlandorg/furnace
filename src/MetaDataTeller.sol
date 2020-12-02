pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IDrillBase.sol";

contract MetaDataTeller is DSMath {
	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	ISettingsRegistry public registry;

	constructor(address _registry) public {
		registry = ISettingsRegistry(_registry);
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
				objectClass == DARWINIA_OBJECT_CLASS
			) {
				return (0, IDrillBase(nftAddress).getGrade(_id));
			}
		}
		return (0, 1);
	}

	// ignore fee
	function getLiquidity(
		address pair,
		address token,
		uint256 amount
	) external view returns (uint256) {
		require(pair != address(0), "Invalid pair.");
		require(token != address(0), "Invalid pair.");
		uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
		if (token == IUniswapV2Pair(pair).token0()) {
			(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
			return mul(amount, totalSupply) / uint256(reserve0);
		} else if (token == IUniswapV2Pair(pair).token1()) {
			(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
			return mul(amount, totalSupply) / uint256(reserve1);
		} else {
			revert("Invalid token.");
		}
	}

	// ignore fee
	function getLiquidityValue(
		address pair,
		address token,
		uint256 liquidity
	) external view returns (uint256) {
		require(pair != address(0), "Invalid pair.");
		require(token != address(0), "Invalid pair.");
		uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
		if (token == IUniswapV2Pair(pair).token0()) {
			(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
			return mul(liquidity, uint256(reserve0)) / totalSupply;
		} else if (token == IUniswapV2Pair(pair).token1()) {
			(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
			return mul(liquidity, uint256(reserve1)) / totalSupply;
		} else {
			revert("Invalid token.");
		}
	}
}
