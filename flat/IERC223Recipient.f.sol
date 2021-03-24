// hevm: flattened sources of src/interfaces/IERC223Recipient.sol
pragma solidity >=0.6.7 <0.7.0;

////// src/interfaces/IERC223Recipient.sol
/* pragma solidity ^0.6.7; */

 /*
 * Contract that is working with ERC223 tokens
 * https://github.com/ethereum/EIPs/issues/223
 */

/// @title IERC223Recipient - Standard contract implementation for compatibility with ERC223 tokens.
interface IERC223Recipient {

    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _from Transaction initiator, analogue of msg.sender
    /// @param _value Number of tokens to transfer.
    /// @param _data Data containig a function signature and/or parameters
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external;

}

