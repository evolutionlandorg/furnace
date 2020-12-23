pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "./ItemBar.sol";

contract ApostleItemBar is Initializable, ItemBar(address(0), 0) {

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

		teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));
		ownership = IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
		landResource = ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE));
		interstellarEncoder = IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER));
	}

	modifier onlyAuth(uint256 _apostleTokenId, uint256 _index) override {
		require(
			ownership.ownerOf(_apostleTokenId) == msg.sender,
			"Furnace: FORBIDDEN"
		);
		_;
	}

	modifier updateMinerStrength(uint256 _apostleTokenId) override {
		if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
			landResource.updateMinerStrengthWhenStop(
				_apostleTokenId
			);
		}
		_;
		if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
			landResource.updateMinerStrengthWhenStart(
				_apostleTokenId
			);
		}
	}

	function isAllowed(uint256 _apostleTokenId, address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
        require(interstellarEncoder.getObjectClass(_apostleTokenId) == 2, "Funace: ONLY_APOSTEL");
		return teller.isAllowed(_token, _id);
	}

	function isAmbassador(uint256 _tokenId) public pure returns (bool) {
		uint128 objectId = uint128(_tokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}
}
