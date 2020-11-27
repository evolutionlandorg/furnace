pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";

// contract FurnaceBase is Initializable, DSAuth, IELIP002, IFormula {
	
//     /*** STORAGE ***/

//     ISettingsRegistry public registry;

//     uint128 public lastItemObjectId;

//     /**
//      * @dev Same with constructor, but is used and called by storage proxy as logic contract.
//      */
//     function initialize(address _registry) public initializer {
//         // Ownable constructor
//         owner = msg.sender;
//         emit LogSetOwner(msg.sender);

//         registry = ISettingsRegistry(_registry);
//     }
// }
