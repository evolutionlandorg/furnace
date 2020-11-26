pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IObjectOwnership.sol";
import "./FurnaceSettingIds.sol";

contract DrillBase is Initializable, DSAuth, FurnaceSettingIds {
	event Create(
		address indexed owner,
		uint256 indexed tokenId,
		uint16 grade,
		uint256 createTime
	);
	event Destroy(address indexed owner, uint256 indexed tokenId);

	uint256 internal constant _CLEAR_HIGH =
		0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

	/*** STORAGE ***/
	uint128 public lastDrillObjectId;

	ISettingsRegistry public registry;

	// counter for per grade
	mapping(uint16 => uint256) public grade2count;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);

		registry = ISettingsRegistry(_registry);
	}

	/**
	 * @dev create a Drill.
	 * @param grade - Drill grade.
	 * @param to - owner of the Drill.
	 * @return       - tokenId.
	 */
	function createDrill(uint16 grade, address to)
		public
		auth
		returns (uint256)
	{
		return _createDrill(grade, to);
	}

	function _createDrill(uint16 grade, address to) internal returns (uint256) {
		lastDrillObjectId += 1;
		require(
			lastDrillObjectId < 5192296858534827628530496329220095,
			"Drill: object id overflow."
		);

		uint128 objectId = (uint128(grade) << 112) | lastDrillObjectId;

		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(to, objectId);
		grade2count[grade] += 1;
		emit Create(
			to,
			tokenId,
			grade,
			now // solhint-disable-line
		);
		return tokenId;
	}

	/**
	 * @dev destroy a Drill.
	 * @param to owner of the drill.
	 * @param tokenId tokenId of the drill.
	 */
	function destroyDrill(address to, uint256 tokenId) public auth {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			to,
			tokenId
		);
		emit Destroy(to, tokenId);
	}

	function getGrade(uint256 tokenId) public pure returns (uint16) {
		uint128 objectId = uint128(tokenId & _CLEAR_HIGH);
		return uint16(objectId >> 112);
	}
}
