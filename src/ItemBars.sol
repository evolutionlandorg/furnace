pragma solidity ^0.6.7;

import "ds-auth/auth.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ERC721Receiver.sol";
import "./interfaces/IMetaDataTeller.sol";

abstract contract ItemBars is DSAuth {
	event Equip(uint256 indexed landTokenId, uint256  index, address staker, address token, uint256 id);
	event Unequip(uint256 indexed landTokenId, uint256  index, address staker, address token, uint256 id);
	event ForceUnequip(uint256 indexed landTokenId, uint256  index, address staker, address token, uint256 id);

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item

	struct Bar {
		address staker;
		address token;
		uint256 id;
		bool isPrivate;
	}

	ISettingsRegistry registry;
	uint256 public maxAmount;
	mapping(address => bool) public allowList;
	mapping(uint256 => mapping (uint256 => Bar)) public land2Bars;
	mapping(uint256 => uint256) public land2EquippedNumber;

    modifier onlyLander(uint256 _landTokenId) {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(IERC721(ownership).ownerOf(_landTokenId) == msg.sender, "Forbidden." );
        _;
    }

    constructor(
            address _registry,
            uint256 _maxAmount
    ) internal {
            registry = ISettingsRegistry(_registry);
            maxAmount = _maxAmount;
    }

	function equip(
		uint256 _landTokenId,
		uint256 _index,
		address _token,
		uint256 _tokenId
	) public {
		require(isAllowed(_token, _tokenId), "Not allow.");
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = land2Bars[_landTokenId][_index];
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(bar.isPrivate == false || IERC721(ownership).ownerOf(_landTokenId) == msg.sender, "Forbidden." );
		if (bar.token != address(0)) {
			address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
			(uint16 class, ) =
				IMetaDataTeller(teller).getMetaData(_token, _tokenId);

			(uint16 originClass, ) =
				IMetaDataTeller(teller).getMetaData(bar.token, bar.id);
			require(
				class > originClass,
				"Item class is less than origin class."
			);
			IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		}
		IERC721(_token).transferFrom(msg.sender, address(this), _tokenId);
		bar.staker = msg.sender; 
		bar.token = _token;
		bar.id = _tokenId;
		emit Equip(_landTokenId, _index, bar.staker, bar.token, bar.id);
	}

	function unequip(
		uint256 _landTokenId,
		uint256 _index
	) public {
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = land2Bars[_landTokenId][_index];
		require(bar.token != address(0), "Empty.");
		require(bar.staker == msg.sender, "Forbidden.");
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit Unequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		bar.staker = address(0);
		bar.token = address(0);
		bar.id = 0;
	}

	function forceUneqiup(uint256 _landTokenId, uint256 _index) internal {
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = land2Bars[_landTokenId][_index];
		if (bar.token == address(0)) return;
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit ForceUnequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		bar.staker = address(0);
		bar.token = address(0);
		bar.id = 0;
	}

	function setPrivate(uint256 _landTokenId, uint256[] calldata _indexs) external onlyLander(_landTokenId) {
		require(_indexs.length > 0, "Length is zero.");
		for (uint256 i = 0; i < _indexs.length; i++) {
			Bar storage bar = land2Bars[_landTokenId][_indexs[i]];
			bar.isPrivate = true;
			if (bar.staker != msg.sender) {
				forceUneqiup(_landTokenId, _indexs[i]);
			}
		}
	}

	function setPublic(uint256 _landTokenId, uint256[] calldata _indexs) external onlyLander(_landTokenId) {
		require(_indexs.length > 0, "Length is zero.");
		for (uint256 i = 0; i < _indexs.length; i++) {
			Bar storage bar = land2Bars[_landTokenId][_indexs[i]];
			bar.isPrivate = false;
		}
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
			if (objectClass == ITEM_OBJECT_CLASS) {
				return true;
			} else {
				return false;
			}
		} else {
			return allowList[_token];
		}
	}
}
