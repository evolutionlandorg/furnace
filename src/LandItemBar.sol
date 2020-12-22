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

	mapping(uint256 => mapping(uint256 => bool)) public land2IsPrivate;
	IERC721 public ownership;
	ILandResource public landResource;
	IInterstellarEncoder public interstellarEncoder; 

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;

		refresh();
	}

	function refresh() public auth override {
		super.refresh();

		ownership = IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
		landResource = ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE));
		interstellarEncoder = IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER));
	}

	modifier onlyLander(uint256 _landTokenId) {
		require(
			ownership.ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
		);
		_;
	}

	modifier onlyAuth(uint256 _landTokenId, uint256 _index) override {
		require(
			land2IsPrivate[_landTokenId][_index] == false ||
				ownership.ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
		);
		_;
	}

	modifier updateMinerStrength(uint256 _landTokenId) override {
		landResource.updateAllMinerStrengthWhenStop(
			_landTokenId
		);
		_;
		landResource.updateAllMinerStrengthWhenStart(
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

	function setPrivate(uint256 _landTokenId, uint256 _index)
		external
		onlyLander(_landTokenId)
	{
		require(land2IsPrivate[_landTokenId][_index] == false, "Already is private.");
		land2IsPrivate[_landTokenId][_index] = true;
		Bar storage bar = tokenId2Bars[_landTokenId][_index];
		if (bar.staker != msg.sender) {
			_forceUneqiup(_landTokenId, _index);
		}
	}

	function setPublic(uint256 _landTokenId, uint256 _index) external onlyLander(_landTokenId) {
		require(land2IsPrivate[_landTokenId][_index] == true, "Already is public.");
		land2IsPrivate[_landTokenId][_index] = false;
	}

	function isAllowed(uint256 _landTokenId, address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
        require(interstellarEncoder.getObjectClass(_landTokenId) == 1, "Funace: ONLY_LAND");
		return teller.isAllowed(_token, _id);
	}

	function isAmbassador(uint256 _tokenId) public pure returns (bool) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}
}
