pragma solidity ^0.6.7;

interface ILandResource {

    function updateAllMinerStrengthWhenStart(uint256 _landTokenId) external;

    function updateAllMinerStrengthWhenStop(uint256 _landTokenId) external;
}
