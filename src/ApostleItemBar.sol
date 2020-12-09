pragma solidity ^0.6.7;

import "./ItemBar.sol";

contract ApostleItemBar is ItemBar {
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
		ILandResource(landResource).updateMinerStrengthWhenStop(_apostleTokenId);
		_;
		ILandResource(landResource).updateMinerStrengthWhenStart(_apostleTokenId);
	}
}
