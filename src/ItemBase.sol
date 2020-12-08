pragma solidity ^0.6.7;

import "ds-math/math.sol";
import "ds-stop/stop.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/IObjectOwnership.sol";
import "./common/UQ112x112.sol";
import "./FurnaceSettingIds.sol";

contract Itembase is
	Initializable,
	DSStop,
	DSMath,
	IELIP002,
	FurnaceSettingIds
{
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

	// rate precision
	uint112 public constant RATE_DECIMALS = 10**8;

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

	function enchant(
		uint256 _index,
		uint256[] calldata _ids,
		uint256[] calldata _values
	) external override stoppable returns (uint256) {
		_dealMajor(_index, _ids);
		(uint16 prefer, uint112 rate, uint256[] memory amounts) =
			_dealMinor(_index, _values);
		return _enchanceItem(_index, prefer, rate, _ids, amounts, msg.sender);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids) internal {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , , bytes32[] memory majors, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Formula disable.");
		require(_ids.length == majors.length, "Invalid ids length.");
		for (uint256 i = 0; i < majors.length; i++) {
			bytes32 major = majors[i];
			uint256 id = _ids[i];
			(address majorAddress, uint16 majorClass, uint16 majorGrade) =
				IFormula(formula).getMajorInfo(major);
			(uint16 class, uint16 grade) =
				IMetaDataTeller(teller).getMetaData(majorAddress, id);
			require(class == majorClass, "Invalid Class.");
			require(grade == majorGrade, "Invalid Grade.");
			IERC721(majorAddress).transferFrom(msg.sender, address(this), id);
		}
	}

	function _dealMinor(uint256 _index, uint256[] memory _values)
		internal
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
		require(disable == false, "Formula disable.");
		require(_values.length == minors.length, "Invalid liquidities length.");
		uint16 prefer;
		//TODO: check rate calculate.
		uint112 rate = RATE_DECIMALS;
		uint256[] memory amounts = new uint256[](minors.length);
		for (uint256 i = 0; i < minors.length; i++) {
			bytes32 minor = minors[i];
			uint256 value = _values[i];
			(address minorAddress, uint112 minorMin, uint112 minorMax) =
				IFormula(formula).getMinorInfo(minor);
			require(minorMax >= minorMin, "Invalid limit.");
			uint256 element =
				IMetaDataTeller(teller).getPrefer(minor, minorAddress);
			prefer |= uint16(1 << element);
			require(value >= minorMin, "No enough value.");
			require(value <= uint128(-1), "Overflow.");
			uint112 numerator;
			uint112 denominator;
			if (value > minorMax) {
				numerator = minorMax - minorMin;
				IERC20(minorAddress).transferFrom(
					msg.sender,
					address(this),
					minorMax
				);
				amounts[i] = minorMax;
			} else {
				numerator = uint112(value - minorMin);
				IERC20(minorAddress).transferFrom(
					msg.sender,
					address(this),
					value
				);
				amounts[i] = value;
			}
			denominator = minorMin;
			uint112 enhanceRate =
				UQ112x112
					.encode(numerator)
					.uqdiv(denominator)
					.mul(RATE_DECIMALS)
					.decode();
			rate = mul112(rate, enhanceRate) / RATE_DECIMALS;
		}
		return (prefer, rate, amounts);
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint112 _rate,
		uint256[] memory _ids,
		uint256[] memory _amounts,
		address _to
	) internal returns (uint256) {
		lastItemObjectId += 1;
		require(lastItemObjectId <= uint128(-1), "Item: object id overflow.");

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
				.mintObject(_to, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		emit Enchanced(
			_to,
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

	function _disenchantItem(address to, uint256 tokenId) internal {
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
		IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).transferFrom(
			msg.sender,
			address(this),
			_id
		);
		_disenchant(_id, _depth);
	}

	function _disenchant(uint256 _tokenId, uint256 _depth)
		internal
		returns (uint256)
	{
		(
			uint16 class,
			bool canDisenchant,
			address[] memory majors,
			uint256[] memory ids,
			address[] memory pairs,
			uint256[] memory amounts
		) = this.getEnchantedInfo(_tokenId);
		require(_depth > 0, "Invalid Depth.");
		require(canDisenchant == true, "Can not disenchant.");
		require(class > 0, "Invalid class.");
		require(ids.length == majors.length, "Invalid majors length.");
		require(amounts.length == pairs.length, "Invalid pairs length.");
		_disenchantItem(address(this), _tokenId);
		for (uint256 i = 0; i < majors.length; i++) {
			address main = majors[i];
			uint256 id = ids[i];
			if (_depth == 1 || class == 0) {
				IERC721(main).transferFrom(address(this), msg.sender, id);
			} else {
				_disenchant(id, _depth - 1);
			}
		}
		for (uint256 i = 0; i < pairs.length; i++) {
			address pair = pairs[i];
			uint256 amount = amounts[i];
			IERC20(pair).transferFrom(address(this), msg.sender, amount);
		}
		emit Disenchanted(msg.sender, _tokenId, majors, ids, pairs, amounts);
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
				baseRate + mul112(item.rate, enhanceRate) / RATE_DECIMALS;
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

	function mul112(uint112 a, uint112 b) internal pure returns (uint112) {
		if (a == 0) {
			return 0;
		}

		uint112 c = a * b;
		require(c / a == b, "Multiplication overflow");

		return c;
	}
}
