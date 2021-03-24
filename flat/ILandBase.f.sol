// hevm: flattened sources of src/interfaces/ILandBase.sol
pragma solidity >=0.6.7 <0.7.0;

////// src/interfaces/ILandBase.sol
/* pragma solidity ^0.6.7; */

interface ILandBase { 
    function resourceToken2RateAttrId(address _resourceToken) external view returns (uint256);
}

