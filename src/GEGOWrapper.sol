pragma solidity ^0.6.7;

import "zeppelin-solidity/token/ERC721/IERC721Receiver.sol";
import "ds-stop/stop.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./FurnaceSettingIds.sol";

contract GEGOWrapper is DSStop, IERC721Receiver, FurnaceSettingIds {

    constructor(
        // address _registry
    ) public {
	}

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {

	}
	
}
