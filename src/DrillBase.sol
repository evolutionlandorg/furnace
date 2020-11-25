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
		uint16 class,
		uint16 grade,
		uint16 prefer,
		uint16 formulaIndex,
		uint16 rate,
		uint256 createTime
	);
	event Destroy(address indexed owner, uint256 indexed tokenId);

	struct Drill {
		uint16 class;
		uint16 grade;
		// which element the Drill prefer.
		uint16 prefer;
		// index of the formula.
		uint16 index;
		// enchance rate
		uint16 rate;
	}

	/*** STORAGE ***/
	uint128 public lastDrillObjectId;

	ISettingsRegistry public registry;

	mapping(uint256 => Drill) public tokenId2Drill;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);

		registry = ISettingsRegistry(_registry);
		//TODO:: trick
		lastDrillObjectId = 1000;
	}

	/**
	 * @dev create a Drill.
	 * @param _class - Drill class.
	 * @param _grade - Drill grade.
	 * @param _prefer -  Drill element prefer.
	 * @param _index - Drill formula index.
	 * @param _rate - Drill enhance strength rate.
	 * @param _owner - owner of the Drill.
	 * @return Drill - tokenId.
	 */
	function createDrill(
		uint16 _class,
		uint16 _grade,
		uint16 _prefer,
		uint16 _index,
		uint16 _rate,
		address _owner
	) public auth returns (uint256) {
		return _createDrill(_class, _grade, _prefer, _index, _rate, _owner);
	}

	function _createDrill(
		uint16 _class,
		uint16 _grade,
		uint16 _prefer,
		uint16 _index,
		uint16 _rate,
		address _owner
	) internal returns (uint256) {
		lastDrillObjectId += 1;
		require(
			lastDrillObjectId <= 340282366920938463463374607431768211455,
			"Drill: object id overflow."
		);

		Drill memory drill =
			Drill({
				class: _class,
				grade: _grade,
				prefer: _prefer,
				index: _index,
				rate: _rate
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(_owner, uint128(lastDrillObjectId));
		tokenId2Drill[tokenId] = drill;
		emit Create(
			_owner,
			tokenId,
			drill.class,
			drill.grade,
			drill.prefer,
			drill.index,
			drill.rate,
			now // solhint-disable-line
		);
		return tokenId;
	}

	/**
	 * @dev destroy a Drill.
	 * @param _to owner of the drill.
	 * @param _tokenId tokenId of the drill.
	 */
	function destroyDrill(address _to, uint256 _tokenId) public auth {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			_to,
			_tokenId
		);
		delete tokenId2Drill[_tokenId];
		emit Destroy(_to, _tokenId);
	}

	function getBaseInfo(uint256 _tokenId)
		public
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint16,
			uint16
		)
	{
		Drill memory drill = tokenId2Drill[_tokenId];
		return (drill.class, drill.grade, drill.prefer, drill.index, drill.rate);
	}
}
