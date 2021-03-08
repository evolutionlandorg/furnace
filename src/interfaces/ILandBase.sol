pragma solidity ^0.6.7;

interface ILandBase { 
    function resourceToken2RateAttrId(address _resourceToken) external view returns (uint256);
}
