pragma solidity ^0.6.7;

interface IItemBase {
	function createItem(uint16 _class, uint16 _grade, uint16 _prefer, uint16 _index, uint16 _rate, bool _canDisenchant, uint256 _major, address[] calldata _tokens, uint256[] calldata _amounts, address _owner) external returns (uint256);

    function destroyItem(address _to, uint256 _tokenId) external;

	function getSmeltInfo(uint256 _tokenId) external view returns (bool, uint16, uint256, address[] memory, uint256[] memory); 
}
