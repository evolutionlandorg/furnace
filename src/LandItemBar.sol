pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "./ItemBar.sol";

contract LandItemBar is Initializable, ItemBar(address(0), 0) {
	event ForceUnequip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);

	mapping(uint256 => bool) public land2IsPrivate;

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

	modifier onlyLander(uint256 _landTokenId) {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(
			IERC721(ownership).ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
		);
		_;
	}

	modifier onlyAuth(uint256 _landTokenId, uint256 _index) override {
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(
			land2IsPrivate[_landTokenId] == false ||
				IERC721(ownership).ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
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

	function _forceUneqiup(uint256 _landTokenId, uint256 _index)
		internal
		updateMinerStrength(_landTokenId)
	{
		require(_index < maxAmount, "Index Forbidden.");
		Bar storage bar = tokenId2Bars[_landTokenId][_index];
		if (bar.token == address(0)) return;
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit ForceUnequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		delete tokenId2Bars[_landTokenId][_index];
	}

	function setPrivate(uint256 _landTokenId)
		external
		onlyLander(_landTokenId)
	{
		require(land2IsPrivate[_landTokenId] == false, "Already is private.");
		land2IsPrivate[_landTokenId] = true;
		for (uint256 i = 0; i < maxAmount; i++) {
			Bar storage bar = tokenId2Bars[_landTokenId][i];
			if (bar.staker != msg.sender) {
				_forceUneqiup(_landTokenId, i);
			}
		}
	}

	function setPublic(uint256 _landTokenId) external onlyLander(_landTokenId) {
		require(land2IsPrivate[_landTokenId] == true, "Already is public.");
		land2IsPrivate[_landTokenId] = false;
	}

	function isAllowed(uint256 _landTokenId, address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
        require(IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectClass(_landTokenId) == 1, "Funace: ONLY_LAND");
		return IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER)).isAllowed(_token, _id);
	}

	function isAmbassador(uint256 _tokenId) public pure returns (bool) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}
}
