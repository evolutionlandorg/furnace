pragma solidity ^0.6.7;

import "./ItemBar.sol";

contract LandItemBar is ItemBar {
	event ForceUnequip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);

	mapping(address => bool) public allowList;
	mapping(uint256 => bool) public land2IsPrivate;

	constructor(address _registry, uint256 _maxAmount)
		public
		ItemBar(_registry, _maxAmount)
	{}

	modifier onlyLander(uint256 _landTokenId) {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(
			IERC721(ownership).ownerOf(_landTokenId) == msg.sender,
			"Forbidden."
		);
		_;
	}

	modifier onlyAuth(uint256 _landTokenId, uint256 _index) override {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(
			land2IsPrivate[_landTokenId] == false ||
				IERC721(ownership).ownerOf(_landTokenId) == msg.sender,
			"Forbidden."
		);
		_;
	}

	modifier updateMinerStrength(uint256 _landTokenId) override {
		address landResource = registry.addressOf(CONTRACT_LAND_RESOURCE);
		ILandResource(landResource).updateAllMinerStrengthWhenStop(
			_landTokenId
		);
		_;
		ILandResource(landResource).updateAllMinerStrengthWhenStart(
			_landTokenId
		);
	}

	function forceUneqiup(uint256 _landTokenId, uint256 _index)
		internal
		updateMinerStrength(_landTokenId)
	{
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = token2Bars[_landTokenId][_index];
		if (bar.token == address(0)) return;
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit ForceUnequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		delete token2Bars[_landTokenId][_index];
	}

	function setPrivate(uint256 _landTokenId)
		external
		onlyLander(_landTokenId)
	{
		require(land2IsPrivate[_landTokenId] == false, "Already is private.");
		land2IsPrivate[_landTokenId] = true;
		for (uint256 i = 0; i < maxAmount; i++) {
			Bar storage bar = token2Bars[_landTokenId][i];
			if (bar.staker != msg.sender) {
				forceUneqiup(_landTokenId, i);
			}
		}
	}

	function setPublic(uint256 _landTokenId) external onlyLander(_landTokenId) {
		require(land2IsPrivate[_landTokenId] == true, "Already is public.");
		land2IsPrivate[_landTokenId] = false;
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
