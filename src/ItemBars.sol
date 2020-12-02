pragma solidity ^0.6.7;

import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/ERC721Receiver.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";

abstract contract ItemBars is DSAuth, ERC721Receiver {
	struct Bar {
		address owner;
		address token;
		uint256 id;
	}

	ISettingsRegistry public registry;
	uint256 public maxAmount;
	uint256 public equippedNumber;
	bool public isPublic;
	mapping(uint256 => Bar) public index2Bar;
	mapping(address => bool) public allowList;

	constructor(
		address _registry,
		uint256 _maxAmount,
		bool _isPublic
	) internal {
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
		isPublic = _isPublic;
	}

	function equip(
		uint256 _index,
		address _token,
		uint256 _id,
	) external override stoppable returns (bytes4) {
		require(isAllowed(_tokenId, _id), "Not allow.");
		Bar storage bar = index2Bar[index];
		if (bar.token != address(0)) {
			address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
			(uint16 class, ) =
				IMetaDataTeller(teller).getMetaData(_from, _tokenId);

			(uint16 originClass, ) =
				IMetaDataTeller(teller).getMetaData(bar.token, bar.id);
			require(
				class > originClass,
				"Item class is less than origin class."
			);
			IERC721(bar.token).transferFrom(address(this), bar.owner, bar.id);
		}
		bar.owner = owner 
		bar.token = _from;
		bar.id = _tokenId;
		return ERC721_RECEIVED;
	}

	function addSupportedToken(address _token) public auth {
		allowList[_token] = true;
	}

	function removeSupportedToken(address _token) public auth {
		allowList[_token] = false;
	}

	function isAllowed(address _token, uint256 _id) public view returns (bool) {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		if (_token == ownership) {
			address interstellarEncoder =
				registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
			uint8 objectClass =
				IInterstellarEncoder(interstellarEncoder).getObjectClass(_id);
			address nftAddress =
				IInterstellarEncoder(interstellarEncoder).getContractAddress(
					_id
				);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return true;
			} else {
				return false;
			}
		} else {
			return supportedToken[_token];
		}
	}
}
