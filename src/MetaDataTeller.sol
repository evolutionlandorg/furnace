pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IELIP002.sol";

contract MetaDataTeller is DSMath {

	bytes32 public constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";

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
		address itemBase = registry.addressOf(CONTRACT_ITEM_BASE); 
		if (_token == itemBase) {
			return IELIP002(itemBase).getBaseInfo(_id);
		} else {
			return (0, 1);
		}
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
