pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-stop/stop.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/IObjectOwnership.sol";
import "./common/UQ112x112.sol";

contract ItemBase is Initializable, DSStop, DSMath, IELIP002 {
	using UQ112x112 for uint224;
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint16 prefer,
		uint112 rate,
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
		uint16 prefer;
		uint112 rate;
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
	uint112 public constant RATE_DECIMALS = 10**8;
	// save about 200 gas when contract create
	bytes4 private constant SELECTOR =
		bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

	/*** STORAGE ***/

	uint128 public lastItemObjectId;
	ISettingsRegistry public registry;
	mapping(uint256 => Item) public tokenId2Item;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
	}

	function _safeTransfer(
		address token,
		address from,
		address to,
		uint256 value
	) private {
		(bool success, bytes memory data) =
			token.call(abi.encodeWithSelector(SELECTOR, from, to, value));
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
		(uint16 prefer, uint112 rate, uint256[] memory amounts) =
			_dealMinor(_index, _values);
		return _enchanceItem(_index, prefer, rate, _ids, amounts);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids) private {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , bytes32[] memory majors, , bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Furnace: FORMULA_DISABLE");
		require(_ids.length == majors.length, "Furnace: INVALID_IDS_LENGTH");
		for (uint256 i = 0; i < majors.length; i++) {
			bytes32 major = majors[i];
			uint256 id = _ids[i];
			(address majorAddress, uint16 majorClass, uint16 majorGrade) =
				IFormula(formula).getMajorInfo(major);
			(uint16 class, uint16 grade) =
				IMetaDataTeller(teller).getMetaData(majorAddress, id);
			require(class == majorClass, "Furnace: INVALID_CLASS");
			require(grade == majorGrade, "Furnace: INVALID_GRADE");
			_safeTransfer(majorAddress, msg.sender, address(this), id);
		}
	}

	function _dealMinor(uint256 _index, uint256[] memory _values)
		private
		returns (
			uint16,
			uint112,
			uint256[] memory
		)
	{
		address formula = registry.addressOf(CONTRACT_FORMULA);
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		(, , , bytes32[] memory minors, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Furnace: FORMULA_DISABLE");
		require(
			_values.length == minors.length,
			"Furnace: INVALID_VALUES_LENGTH."
		);
		uint16 prefer;
		//TODO: check rate calculate.
		uint112 rate = RATE_DECIMALS;
		uint256[] memory amounts = new uint256[](minors.length);
		for (uint256 i = 0; i < minors.length; i++) {
			bytes32 minor = minors[i];
			uint256 value = _values[i];
			(address minorAddress, uint112 minorMin, uint112 minorMax) =
				IFormula(formula).getMinorInfo(minor);
			require(minorMax >= minorMin, "Furnace: INVALID_LIMIT");
			uint256 element =
				IMetaDataTeller(teller).getPrefer(minor, minorAddress);
			prefer |= uint16(1 << element);
			require(value >= minorMin, "Furnace: VALUE_INSUFFICIENT");
			require(value <= uint128(-1), "Furnace: VALUE_OVERFLOW");
			uint112 numerator;
			uint112 denominator;
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
				numerator = uint112(value - minorMin);
				_safeTransfer(minorAddress, msg.sender, address(this), value);
				amounts[i] = value;
			}
			denominator = minorMin;
			uint112 enhanceRate =
				UQ112x112
					.encode(numerator)
					.uqdiv(denominator)
					.mul(RATE_DECIMALS)
					.decode();
			rate = UQ112x112.mul112(rate, enhanceRate) / RATE_DECIMALS;
		}
		return (prefer, rate, amounts);
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint112 _rate,
		uint256[] memory _ids,
		uint256[] memory _amounts
	) private returns (uint256) {
		lastItemObjectId += 1;
		require(lastItemObjectId <= uint128(-1), "Furnace: OBJECTID_OVERFLOW");

		Item memory item =
			Item({
				index: _index,
				prefer: _prefer,
				rate: _rate,
				ids: _ids,
				amounts: _amounts
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(msg.sender, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		emit Enchanced(
			msg.sender,
			tokenId,
			item.index,
			item.prefer,
			item.rate,
			item.ids,
			item.amounts,
			now // solhint-disable-line
		);
		return tokenId;
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

	function getRate(uint256 _tokenId, uint256 _index)
		public
		view
		override
		returns (uint256)
	{
		Item memory item = tokenId2Item[_tokenId];
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , , uint112 baseRate, uint112 enhanceRate, ) =
			IFormula(formula).getMetaInfo(item.index);
		if (uint256(item.prefer) & (~(1 << _index)) > 0) {
			uint112 realEnhanceRate =
				baseRate +
					UQ112x112.mul112(item.rate, enhanceRate) /
					RATE_DECIMALS;
			return uint256(realEnhanceRate);
		}
		return uint256(baseRate);
	}

	function getBaseInfo(uint256 _tokenId)
		public
		view
		override
		returns (uint16, uint16)
	{
		Item memory item = tokenId2Item[_tokenId];
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, uint16 class, uint16 grade, , , ) =
			IFormula(formula).getMetaInfo(item.index);
		return (class, grade);
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
		Item memory item = tokenId2Item[_tokenId];
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, uint16 class, , , , bool canDisenchant) =
			IFormula(formula).getMetaInfo(item.index);
		(address[] memory majorAddresses, address[] memory minorAddresses) =
			IFormula(formula).getAddresses(item.index);
		return (
			class,
			canDisenchant,
			majorAddresses,
			item.ids,
			minorAddresses,
			item.amounts
		);
	}
}
