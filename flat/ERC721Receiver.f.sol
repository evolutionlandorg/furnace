// hevm: flattened sources of src/interfaces/ERC721Receiver.sol
pragma solidity >=0.6.7 <0.7.0;

////// src/interfaces/ERC721Receiver.sol
/* pragma solidity ^0.6.7; */

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
abstract contract ERC721Receiver {
	/**
	 * @dev Magic value to be returned upon successful reception of an NFT
	 *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
	 *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
	 */
	bytes4 internal constant _ERC721_RECEIVED = 0xf0b9e5ba;

	/**
	 * @notice Handle the receipt of an NFT
	 * @dev The ERC721 smart contract calls this function on the recipient
	 * after a `safetransfer`. This function MAY throw to revert and reject the
	 * transfer. This function MUST use 50,000 gas or less. Return of other
	 * than the magic value MUST result in the transaction being reverted.
	 * Note: the contract address is always the message sender.
	 * @param _from The sending address
	 * @param _tokenId The NFT identifier which is being transfered
	 * @param _data Additional data with no specified format
	 * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
	 */
	function onERC721Received(
		address _from,
		uint256 _tokenId,
		bytes calldata _data
	) external virtual returns (bytes4);
}

