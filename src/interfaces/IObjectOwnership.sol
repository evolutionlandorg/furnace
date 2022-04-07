pragma solidity ^0.6.7;

interface IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) external returns (uint256 _tokenId);
    function burn(address _to, uint256 _tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
}
