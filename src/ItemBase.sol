pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";

// contract Itembase is Initializable, DSAuth, IELIP002 {
	
//     /*** STORAGE ***/

//     ISettingsRegistry public registry;

// 	IFormula public formula;

//     uint128 public lastItemObjectId;

//     /**
//      * @dev Same with constructor, but is used and called by storage proxy as logic contract.
//      */
//     function initialize(address _registry, address _formula) public initializer {
//         // Ownable constructor
//         owner = msg.sender;
//         emit LogSetOwner(msg.sender);

//         registry = ISettingsRegistry(_registry);
// 		formula = _formula;
//     }

// 	// if formula do not use proxy
// 	// function changeFormula(address _formula) public auth {
// 	// 	formula = _formula;
// 	// }
// }
