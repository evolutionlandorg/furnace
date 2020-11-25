pragma solidity ^0.6.7;

interface IInterstellarEncoder {
	function registerNewObjectClass(address _objectContract, uint8 objectClass)
		external;

	function encodeTokenId(
		address _tokenAddress,
		uint8 _objectClass,
		uint128 _objectIndex
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForObjectContract(
		address _tokenAddress,
		address _objectContract,
		uint128 _objectId
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForOuterObjectContract(
		address _objectContract,
		address nftAddress,
		address _originNftAddress,
		uint128 _objectId,
		uint16 _producerId,
		uint8 _convertType
	) external view returns (uint256);

	function getContractAddress(uint256 _tokenId)
		external
		view
		returns (address);

	function getObjectId(uint256 _tokenId)
		external
		view
		returns (uint128 _objectId);

	function getObjectClass(uint256 _tokenId) external view returns (uint8);

	function getObjectAddress(uint256 _tokenId) external view returns (address);

	function getProducerId(uint256 _tokenId) external view returns (uint16);

	function getOriginAddress(uint256 _tokenId) external view returns (address);
}
