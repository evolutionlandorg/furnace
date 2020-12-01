pragma solidity ^0.6.7;

interface IMetaDataTeller {
	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16);
}
