pragma solidity ^0.6.7;

interface IMetaDataTeller {
	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16);

	function getPrefer(bytes32 _name, address _token)
		external
		view
		returns (uint256);

	function getRate(
		address _token,
		uint256 _id,
		uint256 _index
	) external view returns (uint256);

	// function getLiquidity(
	// 	address pair,
	// 	address token,
	// 	uint256 amount
	// ) external view returns (uint256);

	// function getLiquidityValue(
	// 	address pair,
	// 	address token,
	// 	uint256 liquidity
	// ) external view returns (uint256);
}
