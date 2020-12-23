pragma solidity ^0.6.7;

interface ILandResource {

    function updateMinerStrengthWhenStart(uint256 _apostleTokenId) external;

    function updateMinerStrengthWhenStop(uint256 _apostleTokenId) external;

    function updateAllMinerStrengthWhenStart(uint256 _landTokenId) external;

    function updateAllMinerStrengthWhenStop(uint256 _landTokenId) external;

    function landWorkingOn(uint256 _apostleTokenId) external view returns (uint256);
}
