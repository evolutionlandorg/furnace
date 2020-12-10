pragma solidity ^0.6.7;

import "./ItemBar.sol";

contract ApostleItemBar is ItemBar {
	mapping(address => bool) public allowList;

	constructor(address _registry, uint256 _maxAmount)
		public
		ItemBar(_registry, _maxAmount)
	{}

	modifier onlyAuth(uint256 _apostleTokenId, uint256 _index) override {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(
			IERC721(ownership).ownerOf(_apostleTokenId) == msg.sender,
			"Forbidden."
		);
		_;
	}

	modifier updateMinerStrength(uint256 _apostleTokenId) override {
		address landResource = registry.addressOf(CONTRACT_LAND_RESOURCE);
		ILandResource(landResource).updateMinerStrengthWhenStop(
			_apostleTokenId
		);
		_;
		ILandResource(landResource).updateMinerStrengthWhenStart(
			_apostleTokenId
		);
	}

	function isAllowed(address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		if (_token == ownership) {
			address interstellarEncoder =
				registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
			uint8 objectClass =
				IInterstellarEncoder(interstellarEncoder).getObjectClass(_id);
			if (
				//TODO:: internal token
				objectClass == ITEM_OBJECT_CLASS ||
				objectClass == DRILL_OBJECT_CLASS ||
				objectClass == DARWINIA_OBJECT_CLASS
			) {
				return true;
			} else {
				return false;
			}
		} else {
			return allowList[_token];
		}
	}

	function addSupportedToken(address _token) public auth {
		allowList[_token] = true;
	}

	function removeSupportedToken(address _token) public auth {
		allowList[_token] = false;
	}
}
