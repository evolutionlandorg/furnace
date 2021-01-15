pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, FurnaceSettingIds, IFormula {
	event SetStrength(uint256 indexed inde, uint128 rate);

	event SetAmount(uint256 indexed index, uint256 amount);

	/*** STORAGE ***/

	FormulaEntry[] public formulas;

	function initialize() public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
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
	) external override auth {
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
