pragma solidity ^0.6.7;

import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IELIP002.sol";

contract MetaDataTeller {

	bytes32 public constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";

	ISettingsRegistry public registry;

	constructor(address _registry) public {
		registry = ISettingsRegistry(_registry);	
	} 

	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16)
	{
		//TODO:: teller
		address itemBase = registry.addressOf(CONTRACT_ITEM_BASE); 
		if (_token == itemBase) {
			return IELIP002(itemBase).getBaseInfo(_id);
		} else {
			return (0, 1);
		}
	}
}
