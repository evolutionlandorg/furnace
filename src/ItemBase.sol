pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "zeppelin-solidity/token/ERC721/IERC721.sol";
import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces/IELIP002.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IObjectOwnership.sol";
import "./FurnaceSettingIds.sol";

contract Itembase is
	Initializable,
	DSStop,
	DSMath,
	IELIP002,
	FurnaceSettingIds
{
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		uint16 rate,
		bool canDisenchant,
		uint256[] ids,
		uint256[] amounts,
		uint256 now
	);

	// 金, Evolution Land Gold
	// 木, Evolution Land Wood
	// 水, Evolution Land Water
	// 火, Evolution Land fire
	// 土, Evolution Land Silicon
	enum Element { NaN, GOLD, WOOD, WATER, FIRE, SOIL }

	struct Item {
		uint256 index;
		uint16 class;
		uint16 grade;
		uint16 prefer;
		uint16 rate;
		bool canDisenchant;
		uint256[] ids;
		uint256[] amounts;
	}

	/*** STORAGE ***/

	uint128 public lastItemObjectId;
	ISettingsRegistry public registry;
	mapping(uint256 => Item) public tokenId2Item;
	mapping(address => Element) public LPToken2element;
	mapping(address => address) public LPToken2token;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		// Ownable constructor
		owner = msg.sender;
		emit LogSetOwner(msg.sender);

		registry = ISettingsRegistry(_registry);
		LPToken2element[
			registry.addressOf(CONTRACT_LP_GOLD_ERC20_TOKEN)
		] = Element.GOLD;
		LPToken2element[
			registry.addressOf(CONTRACT_LP_WOOD_ERC20_TOKEN)
		] = Element.WOOD;
		LPToken2element[
			registry.addressOf(CONTRACT_LP_WATER_ERC20_TOKEN)
		] = Element.WATER;
		LPToken2element[
			registry.addressOf(CONTRACT_LP_FIRE_ERC20_TOKEN)
		] = Element.FIRE;
		LPToken2element[
			registry.addressOf(CONTRACT_LP_SOIL_ERC20_TOKEN)
		] = Element.SOIL;

		LPToken2token[
			registry.addressOf(CONTRACT_LP_RING_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_KTON_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_KTON_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_GOLD_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_WOOD_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_WATER_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_WATER_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_FIRE_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		LPToken2token[
			registry.addressOf(CONTRACT_LP_SOIL_ERC20_TOKEN)
		] = registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN);
	}

	function enchant(
		uint256 _index,
		uint256[] calldata _ids,
		uint256[] calldata _liquidities
	) external override stoppable returns (uint256) {
		address formula = registry.addressOf(CONTRACT_FORMULA);
		require(
			_index > 0 && _index < IFormula(formula).length(),
			"Invalid index."
		);
		(, , bytes32[] memory majors, bytes32[] memory minors, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Formula disable.");
		require(_ids.length == majors.length, "Invalid ids length.");
		require(
			_liquidities.length == minors.length,
			"Invalid liquidities length."
		);
		_dealMajor(_index, _ids);
		//TODO: calculate rate.
		(uint16 prefer, uint16 rate, uint256[] memory amounts) =
			_dealMinor(_index, _liquidities);
		_enchanceItem(_index, prefer, rate, _ids, amounts, msg.sender);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids) internal {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , , bytes32[] memory majors, ) = IFormula(formula).at(_index);
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

	function _dealMinor(uint256 _index, uint256[] memory _liquidities)
		internal
		returns (
			uint16,
			uint16,
			uint256[] memory
		)
	{
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , , bytes32[] memory minors, ) = IFormula(formula).at(_index);
		uint256[] memory amounts = new uint256[](minors.length);
		uint16 prefer;
		uint16 rate;
		for (uint256 i = 0; i < minors.length; i++) {
			bytes32 minor = minors[i];
			uint256 liquidity = _liquidities[i];
			(address pair, uint256 minorMin, uint256 minorMax) =
				IFormula(formula).getMinorInfo(minor);
			if (minor == CONTRACT_ELEMENT_ERC20_TOKEN) {
				uint256 element = uint256(LPToken2element[pair]);
				require(
					element > 0 && element < 6,
					"Invalid LP-token element."
				);
				prefer |= uint16(1 << element);
			} else {
				require(
					pair == registry.addressOf(CONTRACT_LP_RING_ERC20_TOKEN) ||
						pair ==
						registry.addressOf(CONTRACT_LP_KTON_ERC20_TOKEN),
					"Not support LP-token address."
				);
			}
			address token = LPToken2token[pair];
			uint256 value = getLiquidityValue(pair, token, liquidity);
			require(value >= minorMin, "No enough value.");
			if (value > minorMax) {
				uint256 amount = getLiquidity(pair, token, minorMax);
				IUniswapV2Pair(pair).transferFrom(
					msg.sender,
					address(this),
					amount
				);
				amounts[i] = amount;
			} else {
				IUniswapV2Pair(pair).transferFrom(
					msg.sender,
					address(this),
					liquidity
				);
				amounts[i] = liquidity;
			}
		}
		return (prefer, rate, amounts);
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint16 _rate,
		uint256[] memory _ids,
		uint256[] memory _amounts,
		address _to
	) internal {
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, uint16 class, uint16 grade, bool canDisenchant) =
			IFormula(formula).getMetaInfo(_index);
		lastItemObjectId += 1;
		require(
			lastItemObjectId < 5192296858534827628530496329220095,
			"Item: object id overflow."
		);

		Item memory item =
			Item({
				index: _index,
				class: class,
				grade: grade,
				prefer: _prefer,
				rate: _rate,
				canDisenchant: canDisenchant,
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
			item.class,
			item.grade,
			item.prefer,
			item.rate,
			item.canDisenchant,
			item.ids,
			item.amounts,
			now // solhint-disable-line
		);
	}

	function getBaseInfo(uint256 _tokenId)
		external
		view
		override
		returns (uint16, uint16)
	{
		Item memory item = tokenId2Item[_tokenId];
		return (item.class, item.grade);
	}

	function getLiquidity(
		address pair,
		address token,
		uint256 amount
	) public view returns (uint256) {
		require(pair != address(0), "Invalid pair.");
		require(token != address(0), "Invalid pair.");
		uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
		if (token == IUniswapV2Pair(pair).token0()) {
			(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
			return mul(amount, totalSupply) / uint256(reserve0);
		} else if (token == IUniswapV2Pair(pair).token1()) {
			(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
			return mul(amount, totalSupply) / uint256(reserve1);
		} else {
			revert("Invalid token.");
		}
	}

	// ignore fee
	function getLiquidityValue(
		address pair,
		address token,
		uint256 liquidity
	) public view returns (uint256) {
		require(pair != address(0), "Invalid pair.");
		require(token != address(0), "Invalid pair.");
		uint256 totalSupply = IUniswapV2Pair(pair).totalSupply();
		if (token == IUniswapV2Pair(pair).token0()) {
			(uint112 reserve0, , ) = IUniswapV2Pair(pair).getReserves();
			return mul(liquidity, uint256(reserve0)) / totalSupply;
		} else if (token == IUniswapV2Pair(pair).token1()) {
			(, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
			return mul(liquidity, uint256(reserve1)) / totalSupply;
		} else {
			revert("Invalid token.");
		}
	}

	function disenchant(uint256 _id, uint256 _depth) external override {}
}
