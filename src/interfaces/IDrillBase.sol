pragma solidity ^0.6.7;

interface IDrillBase {
	function createDrill(uint16 _class, uint16 _grade, uint16 _prefer, uint16 _index, uint16 _rate, address _owner) external returns (uint256);

    function destroyDrill(address _to, uint256 _tokenId) external;
}
