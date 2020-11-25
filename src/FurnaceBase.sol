pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "zeppelin-solidity/token/ERC721/ERC721.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFST.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";

contract FurnaceBase is Initializable, DSAuth, ERC721("Furnace Standard Token","FST"), IFST, IFormula {
	
    /*** STORAGE ***/

	IFormula public formula;
    ISettingsRegistry public registry;

    /**
     * @dev Same with constructor, but is used and called by storage proxy as logic contract.
     */
    function initialize(address _registry) public initializer {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        // register support for ERC165 
        _registerInterface(_INTERFACE_ID_ERC165);
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);

        // ERC721 constructor
        name_ = "Furnace Standard Token";
        symbol_ = "FST";    // Furnace Standard Token
        registry = ISettingsRegistry(_registry);
    }
}
