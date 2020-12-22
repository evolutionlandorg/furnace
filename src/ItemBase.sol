pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-stop/stop.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/IObjectOwnership.sol";
import "./common/UQ128x128.sol";

contract ItemBase is Initializable, DSStop, DSMath, IELIP002 {
	using UQ128x128 for uint256;
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		bool canDisenchant,
		uint256[] ids,
		uint256[] amounts,
		uint256 now
	);

	event Disenchanted(
		address indexed user,
		uint256 tokenId,
		address[] majors,
		uint256[] ids,
		address[] minors,
		uint256[] amounts
	);

	struct Item {
		uint256 index;
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		uint16 prefer;
		bool canDisenchant;
		uint256[] ids;
		uint256[] amounts;
	}

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f464f524d554c4100000000000000000000000000000000
	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// rate precision
	uint128 public constant RATE_PRECISION = 10**8;
	// save about 200 gas when contract create
	bytes4 private constant _SELECTOR =
		bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

	/*** STORAGE ***/

	uint128 public lastItemObjectId;
	ISettingsRegistry public registry;
	mapping(uint256 => Item) public tokenId2Item;
	mapping(uint256 => mapping(uint256 => uint256)) public tokenId2Rate;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		// trick test
		lastItemObjectId = 1000;
	}

	function _safeTransfer(
		address token,
		address from,
		address to,
		uint256 value
	) private {
		(bool success, bytes memory data) =
			token.call(abi.encodeWithSelector(_SELECTOR, from, to, value)); // solhint-disable-line
		require(
			success && (data.length == 0 || abi.decode(data, (bool))),
			"Furnace: TRANSFER_FAILED"
		);
	}

	function enchant(
		uint256 _index,
		uint256[] calldata _ids,
		uint256[] calldata _values
	) external override stoppable returns (uint256) {
		_dealMajor(_index, _ids);
		(uint16 prefer, uint128 rate, uint256[] memory amounts) =
			_dealMinor(_index, _values);
		return _enchanceItem(_index, prefer, rate, _ids, amounts);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids) private {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , bytes32[] memory majors, , , bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Furnace: FORMULA_DISABLE");
		require(_ids.length == majors.length, "Furnace: INVALID_LENGTH");
		for (uint256 i = 0; i < majors.length; i++) {
			bytes32 major = majors[i];
			uint256 id = _ids[i];
			(
				address majorAddress,
				uint16 majorObjClassExt,
				uint16 majorClass,
				uint16 majorGrade
			) = IFormula(formula).getMajorInfo(major);
			(uint16 objectClassExt, uint16 class, uint16 grade) =
				IMetaDataTeller(teller).getMetaData(majorAddress, id);
			//TODO:: check object class
			require(
				objectClassExt == majorObjClassExt,
				"Furnace: INVALID_OBJECTCLASSEXT"
			);
			require(class == majorClass, "Furnace: INVALID_CLASS");
			require(grade == majorGrade, "Furnace: INVALID_GRADE");
			_safeTransfer(majorAddress, msg.sender, address(this), id);
		}
	}

	function _dealMinor(uint256 _index, uint256[] memory _values)
		private
		returns (
			uint16,
			uint128,
			uint256[] memory
		)
	{
		address formula = registry.addressOf(CONTRACT_FORMULA);
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		(, , , address[] memory minors, uint256[] memory limits, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Furnace: FORMULA_DISABLE");
		require(
			_values.length == minors.length,
			"Furnace: INVALID_VALUES_LENGTH."
		);
		uint16 prefer;
		//TODO: check rate calculate.
		uint128 rate = RATE_PRECISION;
		uint256[] memory amounts = new uint256[](minors.length);
		for (uint256 i = 0; i < minors.length; i++) {
			address minorAddress = minors[i];
			uint256 limit = limits[i];
			uint256 value = _values[i];
			(uint128 minorMin, uint128 minorMax) =
				IFormula(formula).getLimit(limit);
			require(minorMax > minorMin, "Furnace: INVALID_LIMIT");
			uint256 element = IMetaDataTeller(teller).getPrefer(minorAddress);
			prefer |= uint16(1 << element);
			require(value >= minorMin, "Furnace: VALUE_INSUFFICIENT");
			require(value <= uint128(-1), "Furnace: VALUE_OVERFLOW");
			uint128 numerator;
			uint128 denominator;
			if (value > minorMax) {
				numerator = minorMax - minorMin;
				_safeTransfer(
					minorAddress,
					msg.sender,
					address(this),
					minorMax
				);
				amounts[i] = minorMax;
			} else {
				numerator = uint128(value) - minorMin;
				_safeTransfer(minorAddress, msg.sender, address(this), value);
				amounts[i] = value;
			}
			denominator = minorMax - minorMin;
			uint128 enhanceRate =
				UQ128x128
					.encode(numerator)
					.uqdiv(denominator)
					.uqmul(RATE_PRECISION)
					.decode();
			rate = UQ128x128.mul128(rate, enhanceRate) / RATE_PRECISION;
		}
		return (prefer, rate, amounts);
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint128 _rate,
		uint256[] memory _ids,
		uint256[] memory _amounts
	) private returns (uint256) {
		lastItemObjectId += 1;
		require(lastItemObjectId <= uint128(-1), "Furnace: OBJECTID_OVERFLOW");

		(
			,
			uint16 objClassExt,
			uint16 class,
			uint16 grade,
			bool canDisenchant,
			uint128 base,
			uint128 enhance
		) = IFormula(registry.addressOf(CONTRACT_FORMULA)).getMetaInfo(_index);

		Item memory item =
			Item({
				index: _index,
				objClassExt: objClassExt,
				class: class,
				grade: grade,
				prefer: _prefer,
				canDisenchant: canDisenchant,
				ids: _ids,
				amounts: _amounts
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(msg.sender, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		_calculteRate(tokenId, _prefer, _rate, base, enhance);
		emit Enchanced(
			msg.sender,
			tokenId,
			item.index,
			item.objClassExt,
			item.class,
			item.grade,
			item.prefer,
			item.canDisenchant,
			item.ids,
			item.amounts,
			now // solhint-disable-line
		);
		return tokenId;
	}

	function _calculteRate(uint256 _tokenId, uint16 _prefer, uint128 _rate, uint128 _base, uint128 _enhance)
		internal
	{
		tokenId2Rate[_tokenId][1] = _getRate(1, _prefer, _rate, _base, _enhance);	
		tokenId2Rate[_tokenId][2] = _getRate(2, _prefer, _rate, _base, _enhance);	
		tokenId2Rate[_tokenId][3] = _getRate(3, _prefer, _rate, _base, _enhance);	
		tokenId2Rate[_tokenId][4] = _getRate(4, _prefer, _rate, _base, _enhance);	
		tokenId2Rate[_tokenId][5] = _getRate(5, _prefer, _rate, _base, _enhance);	
	}

	function _getRate(uint256 _element, uint16 _prefer, uint128 _rate, uint128 _base, uint128 _enhance)
		internal	
		pure
		returns (uint256)
	{
		if (uint256(_prefer) & (1 << _element) > 0) {
			uint128 realEnhanceRate =
				_base +
					UQ128x128.mul128(_rate, _enhance) /
					RATE_PRECISION;
			return uint256(realEnhanceRate);
		}
		return uint256(_base / 2);
	}

	function _disenchantItem(address to, uint256 tokenId) private {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			to,
			tokenId
		);
	}

	function disenchant(uint256 _id, uint256 _depth)
		external
		override
		stoppable
	{
		_safeTransfer(
			registry.addressOf(CONTRACT_OBJECT_OWNERSHIP),
			msg.sender,
			address(this),
			_id
		);
		_disenchant(_id, _depth);
	}

	function _disenchant(uint256 _tokenId, uint256 _depth)
		private
		returns (uint256)
	{
		(
			uint16 class,
			bool canDisenchant,
			address[] memory majors,
			uint256[] memory ids,
			address[] memory minors,
			uint256[] memory amounts
		) = getEnchantedInfo(_tokenId);
		require(_depth > 0, "Furnace: INVALID_DEPTH");
		require(canDisenchant == true, "Furnace: DISENCHANT_DISABLE");
		require(class > 0, "Furnace: INVALID_CLASS");
		require(ids.length == majors.length, "Furnace: INVALID_MAJORS_LENGTH.");
		require(
			amounts.length == minors.length,
			"Furnace: INVALID_MINORS_LENGTH."
		);
		_disenchantItem(address(this), _tokenId);
		for (uint256 i = 0; i < majors.length; i++) {
			address major = majors[i];
			uint256 id = ids[i];
			if (_depth == 1 || class == 0) {
				_safeTransfer(major, address(this), msg.sender, id);
			} else {
				_disenchant(id, _depth - 1);
			}
		}
		for (uint256 i = 0; i < minors.length; i++) {
			address minor = minors[i];
			uint256 amount = amounts[i];
			_safeTransfer(minor, address(this), msg.sender, amount);
		}
		emit Disenchanted(msg.sender, _tokenId, majors, ids, minors, amounts);
	}

	// function getItem(uint256 _tokenId)
	// 	public
	// 	view
	// 	returns (
	// 		uint256,
	// 		uint16,
	// 		uint128,
	// 		uint256[] memory,
	// 		uint256[] memory
	// 	)
	// {
	// 	Item storage item = tokenId2Item[_tokenId];
	// 	return (item.index, item.prefer, item.rate, item.ids, item.amounts);
	// }

	function getRate(uint256 _tokenId, uint256 _element)
		public
		view
		override
		returns (uint256)
	{
		return tokenId2Rate[_tokenId][_element];
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

	function getEnchantedInfo(uint256 _tokenId)
		public
		view
		returns (
			uint16,
			bool,
			address[] memory,
			uint256[] memory,
			address[] memory,
			uint256[] memory
		)
	{
		Item storage item = tokenId2Item[_tokenId];
		address formula = registry.addressOf(CONTRACT_FORMULA);
		return (
			item.class,
			item.canDisenchant,
			IFormula(formula).getMajorAddresses(item.index),
			item.ids,
			IFormula(formula).getMinorAddresses(item.index),
			item.amounts
		);
	}
}
