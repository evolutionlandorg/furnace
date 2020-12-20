pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "./ItemBar.sol";

contract ApostleItemBar is Initializable, ItemBar(address(0), 0) {

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

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

	function isAllowed(uint256 _apostleTokenId, address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
        require(IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectClass(_apostleTokenId) == 1, "Funace: ONLY_APOSTEL");
		return IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER)).isAllowed(_token, _id);
	}

	function isAmbassador(uint256 _tokenId) public pure returns (bool) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}
}
