pragma solidity ^0.6.7;

interface ILandResource {
	function updateMinerStrengthWhenStart(uint256 _apostleTokenId) external;

	function updateMinerStrengthWhenStop(uint256 _apostleTokenId) external;

	function afterLandItemBarEquiped(
		uint256 _landTokenId,
		uint256 _landId,
		address _resource
	) external;

	function afterLandItemBarUnequiped(
		uint256 _landTokenId,
		uint256 _landId,
		address _resource
	) external;

	function landWorkingOn(uint256 _apostleTokenId)
		external
		view
		returns (uint256);

	function mine(uint256 _landTokenId) external;

	function getLandMiningStrength(uint256 _landId, address _resource)
		external
		view
		returns (uint256);
}
