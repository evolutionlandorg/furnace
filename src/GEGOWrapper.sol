pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/ERC721Receiver.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IItemBase.sol";
import "./FurnaceSettingIds.sol";

contract GEGOWrapper is DSStop, ERC721Receiver, FurnaceSettingIds {
    event Wrapped(address indexed user, uint256 originId, uint256 wrapId);
    event Unwrapped(address indexed user, uint256 wrapId, uint256 originId);

    ISettingsRegistry public registry;
    address public GEGO;
    address public ownership;
    mapping(uint256 => uint256) wrapId2originId;

    constructor(address _registry) public {
        registry = ISettingsRegistry(_registry);
        GEGO = registry.addressOf(CONTRACT_GEGO_ERC721_TOKEN);
        ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
    }

    /**
     * @notice Handle the receipt of an NFT.
     * @dev ERC223 fallback function, wrap or unwrap GEGO NFT.
     * @param _from The sending address.
     * @param _tokenId The NFT identifier which is being transfered.
     * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
     */
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes calldata /* _data */
    ) external override stoppable returns (bytes4) {
        if (msg.sender == GEGO) {
            uint256 wrapId = wrapGEGOItem(_from);
            wrapId2originId[wrapId] = _tokenId;
            emit Wrapped(_from, _tokenId, wrapId);
        } else if (msg.sender == ownership) {
            address interstellarEncoder = registry.addressOf(
                CONTRACT_INTERSTELLAR_ENCODER
            );
            uint8 objectClass = IInterstellarEncoder(interstellarEncoder)
                .getObjectClass(_tokenId);
            require(
                objectClass == ITEM_OBJECT_CLASS,
                "Only item obejct can unwrap."
            );
            uint256 originId = unwrapGEGOItem(_tokenId);
            emit Unwrapped(_from, _tokenId, originId);
        } else {
            revert("Invalid token address.");
        }
        return ERC721_RECEIVED;
    }

    function batchWrapp(uint256[] calldata _tokenIds) external stoppable {
        require(_tokenIds.length > 0, "No token for wrapping.");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            IERC721(GEGO).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );
        }
    }

    function batchUnwrapp(uint256[] calldata _tokenIds) external stoppable {
        require(_tokenIds.length > 0, "No token for wrapping.");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            IERC721(ownership).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );
        }
    }

    function unwrapGEGOItem(uint256 _wrapId) internal returns (uint256) {
        uint256 originId = wrapId2originId[_wrapId];
        address item = registry.addressOf(CONTRACT_ITEM_BASE);
        IItemBase(item).destroyItem(address(this), _wrapId);
        IERC721(GEGO).safeTransferFrom(address(this), msg.sender, originId);
        delete wrapId2originId[_wrapId];
        return originId;
    }

    function wrapGEGOItem(address _owner) internal returns (uint256) {
        address item = registry.addressOf(CONTRACT_ITEM_BASE);
        return
            IItemBase(item).createItem(
                0,
                1,
                0,
                1,
                0,
                false,
                0,
                new address[](0),
                new uint256[](0),
                _owner
            );
    }
}
