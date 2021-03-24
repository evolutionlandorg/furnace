pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-stop/stop.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/IObjectOwnership.sol";

contract ItemBase is Initializable, DSStop, DSMath, IELIP002 {
	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f464f524d554c4100000000000000000000000000000000
	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	//0x434f4e54524143545f4c505f454c454d454e545f544f4b454e00000000000000
	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN =
		"CONTRACT_LP_ELEMENT_TOKEN";

	//0x434f4e54524143545f454c454d454e545f544f4b454e00000000000000000000
	bytes32 public constant CONTRACT_ELEMENT_TOKEN = "CONTRACT_ELEMENT_TOKEN";

	// rate precision
	uint128 public constant RATE_PRECISION = 10**8;
	// save about 200 gas when contract create
	bytes4 private constant _SELECTOR_TRANSFERFROM =
		bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

    bytes4 private constant _SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

	/*** STORAGE ***/

	uint128 public lastItemObjectId;
	ISettingsRegistry public registry;
	mapping(uint256 => Item) public tokenId2Item;

	// mapping(uint256 => mapping(uint256 => uint256)) public tokenId2Rate;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		// trick test
		// lastItemObjectId = 1000000;
	}

	function _safeTransferFrom(
		address token,
		address from,
		address to,
		uint256 value
	) private {
		(bool success, bytes memory data) =
			token.call(abi.encodeWithSelector(_SELECTOR_TRANSFERFROM, from, to, value)); // solhint-disable-line
		require(
			success && (data.length == 0 || abi.decode(data, (bool))),
			"Furnace: TRANSFERFROM_FAILED"
		);
	}

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(_SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Furnace: TRANSFER_FAILED');
    }

	function enchant(
		uint256 _index,
		uint256 _id,
		address _token
	) external override stoppable returns (uint256) {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		require(
			IFormula(formula).isDisable(_index) == false,
			"Furnace: FORMULA_DISABLE"
		);
		(address majorAddr, uint16 originClass, uint16 originPrefer) =
			_dealMajor(teller, formula, _index, _id);
		(uint16 prefer, uint256 amount) =
			_dealMinor(teller, formula, _index, _token);
		if (originClass > 0) {
			require(prefer == originPrefer, "Furnace: INVALID_PREFER");
		}
		return _enchanceItem(formula, _index, prefer, majorAddr, _id, _token, amount);
	}

	function _dealMajor(
		address teller,
		address formula,
		uint256 _index,
		uint256 _id
	) private returns (address, uint16, uint16) {
		(
			address majorAddress,
			uint16 majorObjClassExt,
			uint16 majorClass,
			uint16 majorGrade
		) = IFormula(formula).getMajorInfo(_index);
		(uint16 objectClassExt, uint16 class, uint16 grade) =
			IMetaDataTeller(teller).getMetaData(majorAddress, _id);
		require(
			objectClassExt == majorObjClassExt,
			"Furnace: INVALID_OBJECTCLASSEXT"
		);
		require(class == majorClass, "Furnace: INVALID_CLASS");
		require(grade == majorGrade, "Furnace: INVALID_GRADE");
		_safeTransferFrom(majorAddress, msg.sender, address(this), _id);
		uint16 prefer = 0;
		if (class > 0) {
			prefer = getPrefer(_id);
		}
		return (majorAddress, class, prefer);
	}

	function _dealMinor(
		address teller,
		address formula,
		uint256 _index,
		address _token
	) private returns (uint16, uint256) {
		(bytes32 minor, uint256 amount) = IFormula(formula).getMinor(_index);
		uint16 prefer = 0;
		uint256 element = IMetaDataTeller(teller).getPrefer(minor, _token);
		require(element > 0 && element < 6, "Furnace: INVALID_MINOR");
		prefer |= uint16(1 << element);
		require(amount <= uint128(-1), "Furnace: VALUE_OVERFLOW");
		_safeTransferFrom(_token, msg.sender, address(this), amount);
		return (prefer, amount);
	}

	function _enchanceItem(
		address formula,
		uint256 _index,
		uint16 _prefer,
		address _major,
		uint256 _id,
		address _minor,
		uint256 _amount
	) private returns (uint256) {
		lastItemObjectId += 1;
		require(lastItemObjectId <= uint128(-1), "Furnace: OBJECTID_OVERFLOW");
		(uint16 objClassExt, uint16 class, uint16 grade, uint128 rate) =
			IFormula(formula).getMetaInfo(_index);
		Item memory item =
			Item({
				index: _index,
				rate: rate,
				objClassExt: objClassExt,
				class: class,
				grade: grade,
				prefer: _prefer,
				major: _major,
				id: _id,
				minor: _minor,
				amount: _amount
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(msg.sender, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		emit Enchanced(
			msg.sender,
			tokenId,
			item.index,
			item.rate,
			item.objClassExt,
			item.class,
			item.grade,
			item.prefer,
			item.major,
			item.id,
			item.minor,
			item.amount,
			now // solhint-disable-line
		);
		return tokenId;
	}

	function _disenchantItem(address to, uint256 tokenId) private {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			to,
			tokenId
		);
        delete tokenId2Item[tokenId];
	}

	function disenchant(uint256 _id, uint256 _depth)
		external
		override
		stoppable
	{
		_safeTransferFrom(
			registry.addressOf(CONTRACT_OBJECT_OWNERSHIP),
			msg.sender,
			address(this),
			_id
		);

		_disenchant(_id, _depth);
	}

	function _disenchant(uint256 _tokenId, uint256 _depth)
		private
	{
		(
			uint16 class,
			bool canDisenchant,
			address major,
			uint256 id,
			address minor,
			uint256 amount
		) = getEnchantedInfo(_tokenId);
		require(_depth > 0, "Furnace: INVALID_DEPTH");
		require(canDisenchant == true, "Furnace: DISENCHANT_DISABLE");
		require(class > 0, "Furnace: INVALID_CLASS");
		_disenchantItem(address(this), _tokenId);
		if (_depth == 1 || class == 0) {
			_safeTransferFrom(major, address(this), msg.sender, id);
		} else {
			_disenchant(id, _depth - 1);
		}
		_safeTransfer(minor, msg.sender, amount);
		emit Disenchanted(msg.sender, _tokenId, major, id, minor, amount);
	}

	function getRate(uint256 _tokenId, uint256 _element)
		public
		view
		override
		returns (uint256)
	{
		Item storage item = tokenId2Item[_tokenId];
		if (uint256(item.prefer) & (1 << _element) > 0) {
			return uint256(item.rate);
		}
		return uint256(item.rate / 2);
	}

	function getBaseInfo(uint256 _tokenId)
		public
		view
		override
		returns (
			uint16,
			uint16,
			uint16
		)
	{
		Item storage item = tokenId2Item[_tokenId];
		return (item.objClassExt, item.class, item.grade);
	}

	function getPrefer(uint256 _tokenId) public view override returns (uint16) {
		return tokenId2Item[_tokenId].prefer;
	}

	function getObjectClassExt(uint256 _tokenId)
		public
		view
		override
		returns (uint16)
	{
		return tokenId2Item[_tokenId].objClassExt;
	}

	function getEnchantedInfo(uint256 _tokenId)
		public
		view
		returns (
			uint16,
			bool,
			address,
			uint256,
			address,
			uint256
		)
	{
		Item storage item = tokenId2Item[_tokenId];
		return (
			item.class,
			IFormula(registry.addressOf(CONTRACT_FORMULA)).canDisenchant(item.index),
			item.major,
			item.id,
			item.minor,
			item.amount
		);
	}
}
