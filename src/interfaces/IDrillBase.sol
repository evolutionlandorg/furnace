pragma solidity ^0.6.7;

interface IDrillBase {
	function createDrill(uint16 grade, address to) external returns (uint256);

    function destroyDrill(address to, uint256 tokenId) external;

	function getGrade(uint256 tokenId) external pure returns (uint16);
}
