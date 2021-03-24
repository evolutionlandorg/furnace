pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, IFormula {
	event SetStrength(uint256 indexed inde, uint128 rate);

	event SetAmount(uint256 indexed index, uint256 amount);

	// 0x434f4e54524143545f4552433732315f4745474f000000000000000000000000
	bytes32 public constant CONTRACT_ERC721_GEGO = "CONTRACT_ERC721_GEGO";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	//0x434f4e54524143545f454c454d454e545f544f4b454e00000000000000000000
	bytes32 public constant CONTRACT_ELEMENT_TOKEN = 
		"CONTRACT_ELEMENT_TOKEN";

	//0x434f4e54524143545f4c505f454c454d454e545f544f4b454e00000000000000
	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN = 
		"CONTRACT_LP_ELEMENT_TOKEN";

	uint128 public constant RATE_DECIMALS = 10 ** 6;
	uint256 public constant UNIT = 10 ** 18;

	/*** STORAGE ***/

	ISettingsRegistry public registry;
	FormulaEntry[] public formulas;

	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		_init();
	}

	function _init() internal {
		address gego = registry.addressOf(CONTRACT_ERC721_GEGO); 
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		// 0
		insert("合金镐", uint128(5 * RATE_DECIMALS), uint16(256), uint16(1), uint16(1), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, gego, 256, 0, 1);

		// 1
		insert("人力铸铁钻机", uint128(5 * RATE_DECIMALS), uint16(4), uint16(1), uint16(1), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 1);

		// 2
		insert("人力镍钢钻机", uint128(12 * RATE_DECIMALS), uint16(4), uint16(1), uint16(2), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 2);

		// 3
		insert("人力金刚钻机", uint128(25 * RATE_DECIMALS), uint16(4), uint16(1), uint16(3), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 3);

		// 4
		insert("高级合金镐", uint128(28 * RATE_DECIMALS), uint16(256), uint16(2), uint16(1), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 256, 1, 1);

		// 5
		insert("燃油铸铁钻机", uint128(28 * RATE_DECIMALS), uint16(4), uint16(2), uint16(1), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 1);

		// 6
		insert("燃油钨钢钻机", uint128(68 * RATE_DECIMALS), uint16(4), uint16(2), uint16(2), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 2);

		// 7
		insert("燃油金刚钻机", uint128(120 * RATE_DECIMALS), uint16(4), uint16(2), uint16(3), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 3);
	}

	function insert(
		bytes32 _name,
		uint128 _rate,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32 _minor,
		uint256 _amount,
		address _majorAddr,
		uint16 _majorObjClassExt,
		uint16 _majorClass,
		uint16 _majorGrade
	) public override auth {
		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				rate: _rate,
				objClassExt: _objClassExt,
				disable: false,
				class: _class,
				grade: _grade,
				canDisenchant: _canDisenchant,
				minor: _minor,
				amount: _amount,
				majorAddr: _majorAddr,
		        majorObjClassExt: _majorObjClassExt,
		        majorClass: _majorClass,
		        majorGrade:_majorGrade
			});
		formulas.push(formula);
		emit AddFormula(
			formulas.length - 1,
			formula.name,
			formula.rate,
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.canDisenchant,
			formula.minor,
			formula.amount,
			formula.majorAddr,
			formula.majorObjClassExt,
			formula.majorClass,
			formula.majorGrade
		);
	}

	function disable(uint256 _index) external override auth {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		formulas[_index].disable = true;
		emit DisableFormula(_index);
	}

	function enable(uint256 _index) external override auth {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		formulas[_index].disable = false;
		emit EnableFormula(_index);
	}

	function setStrengthRate(uint256 _index, uint128 _rate) external auth {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.rate = _rate;
		emit SetStrength(_index, formula.rate);
	}

	function setAmount(uint256 _index, uint256 _amount)
		external
		auth
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.amount = _amount;
		emit SetAmount(_index, formula.amount);
	}

	function length() external view override returns (uint256) {
		return formulas.length;
	}

	function isDisable(uint256 _index) external view override returns (bool) {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].disable;
	}

	function getMinor(uint256 _index)
		external
		view
		override
		returns (bytes32, uint256)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return (formulas[_index].minor, formulas[_index].amount);
	}

	function canDisenchant(uint256 _index)
		external
		view
		override
		returns (bool)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].canDisenchant;
	}

	function getMetaInfo(uint256 _index)
		external
		view
		override
		returns (
			uint16,
			uint16,
			uint16,
			uint128
		)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		return (
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.rate
		);
	}

	function getMajorInfo(uint256 _index)
		public
		view	
		override
		returns (
			address,
			uint16,
			uint16,
			uint16
		)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		return (
			formula.majorAddr,
			formula.majorObjClassExt,
			formula.majorClass,
			formula.majorGrade
		);
	}
}
