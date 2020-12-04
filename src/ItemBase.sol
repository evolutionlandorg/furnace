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
		bytes32 name,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		uint16 rate,
		bool canDisenchant,
		address[] mains,
		uint256[] ids,
		address[] pairs,
		uint256[] amounts,
		uint256 now
	);

	event Disenchanted(
		address indexed user,
		uint256 tokenId,
		address[] mains,
		uint256[] ids,
		address[] pairs,
		uint256[] amounts
	);

	// 金, Evolution Land Gold
	// 木, Evolution Land Wood
	// 水, Evolution Land Water
	// 火, Evolution Land fire
	// 土, Evolution Land Silicon
	enum Element { NaN, GOLD, WOOD, WATER, FIRE, SOIL }

	struct Item {
		bytes32 name;
		uint16 class;
		uint16 grade;
		uint16 prefer;
		uint16 rate;
		bool canDisenchant;
		address[] mains;
		uint256[] ids;
		address[] pairs;
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
		address[] memory mains = _dealMajor(_index, _ids);
		(
			uint16 prefer,
			uint16 rate,
			address[] memory pairs,
			uint256[] memory amounts
		) = _dealMinor(_index, _liquidities);
		return
			_enchanceItem(
				_index,
				prefer,
				rate,
				mains,
				_ids,
				pairs,
				amounts,
				msg.sender
			);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids)
		internal
		returns (address[] memory)
	{
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(, , , bytes32[] memory majors, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Formula disable.");
		require(_ids.length == majors.length, "Invalid ids length.");
		address[] memory mains = new address[](majors.length);
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
			mains[i] = majorAddress;
		}
		return mains;
	}

	function _dealMinor(uint256 _index, uint256[] memory _liquidities)
		internal
		returns (
			uint16,
			uint16,
			address[] memory,
			uint256[] memory
		)
	{
		address formula = registry.addressOf(CONTRACT_FORMULA);
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		(, , , bytes32[] memory minors, bool disable) =
			IFormula(formula).at(_index);
		require(disable == false, "Formula disable.");
		require(
			_liquidities.length == minors.length,
			"Invalid liquidities length."
		);
		uint16 prefer;
		//TODO: calculate rate.
		uint16 rate;
		uint256[] memory amounts = new uint256[](minors.length);
		address[] memory pairs = new address[](minors.length);
		for (uint256 i = 0; i < minors.length; i++) {
			bytes32 minor = minors[i];
			uint256 liquidity = _liquidities[i];
			(address pair, uint256 minorMin, uint256 minorMax) =
				IFormula(formula).getMinorInfo(minor);
			pairs[i] = pair;
			// TODO: element is allowed
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
			uint256 value =
				IMetaDataTeller(teller).getLiquidityValue(
					pair,
					token,
					liquidity
				);
			require(value >= minorMin, "No enough value.");
			if (value > minorMax) {
				uint256 amount =
					IMetaDataTeller(teller).getLiquidity(pair, token, minorMax);
				IERC20(pair).transferFrom(msg.sender, address(this), amount);
				amounts[i] = amount;
			} else {
				IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
				amounts[i] = liquidity;
			}
		}
		return (prefer, rate, pairs, amounts);
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint16 _rate,
		address[] memory _mains,
		uint256[] memory _ids,
		address[] memory _pairs,
		uint256[] memory _amounts,
		address _to
	) internal returns (uint256) {
		address formula = registry.addressOf(CONTRACT_FORMULA);
		(bytes32 name, uint16 class, uint16 grade, bool canDisenchant) =
			IFormula(formula).getMetaInfo(_index);
		lastItemObjectId += 1;
		require(
			lastItemObjectId < 5192296858534827628530496329220095,
			"Item: object id overflow."
		);

		Item memory item =
			Item({
				name: name,
				class: class,
				grade: grade,
				prefer: _prefer,
				rate: _rate,
				canDisenchant: canDisenchant,
				mains: _mains,
				ids: _ids,
				pairs: _pairs,
				amounts: _amounts
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(_to, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		emit Enchanced(
			_to,
			tokenId,
			item.name,
			item.class,
			item.grade,
			item.prefer,
			item.rate,
			item.canDisenchant,
			item.mains,
			item.ids,
			item.pairs,
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
			address[] memory mains,
			uint256[] memory ids,
			address[] memory pairs,
			uint256[] memory amounts
		) = this.getEnchantedInfo(_tokenId);
		require(_depth > 0, "Invalid Depth.");
		require(canDisenchant == true, "Can not disenchant.");
		require(class > 0, "Invalid class.");
		require(ids.length == mains.length, "Invalid mains length.");
		require(amounts.length == pairs.length, "Invalid pairs length.");
		_disenchantItem(address(this), _tokenId);
		for (uint256 i = 0; i < mains.length; i++) {
			address main = mains[i];
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
		emit Disenchanted(msg.sender, _tokenId, mains, ids, pairs, amounts);
	}

	function getBaseInfo(uint256 _tokenId)
		public	
		view
		override
		returns (uint16, uint16)
	{
		Item memory item = tokenId2Item[_tokenId];
		return (item.class, item.grade);
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
		return (
			item.class,
			item.canDisenchant,
			item.mains,
			item.ids,
			item.pairs,
			item.amounts
		);
	}
}
