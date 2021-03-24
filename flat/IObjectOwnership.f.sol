// hevm: flattened sources of src/interfaces/IObjectOwnership.sol
pragma solidity >=0.6.7 <0.7.0;

////// src/interfaces/IObjectOwnership.sol
/* pragma solidity ^0.6.7; */

interface IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) external returns (uint256 _tokenId);
	
    function burn(address _to, uint256 _tokenId) external;
}

