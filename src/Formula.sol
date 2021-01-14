pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./common/Input.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, FurnaceSettingIds, IFormula {
	using Input for Input.Data;
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
		bytes32 _major,
		bytes32 _minor,
		uint256 _amount
	) external override auth {
		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				rate: _rate,
				objClassExt: _objClassExt,
				class: _class,
				grade: _grade,
				canDisenchant: _canDisenchant,
				major: _major,
				minor: _minor,
				amount: _amount,
				disable: false
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
			formula.major,
			formula.minor,
			formula.amount
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

	function getMajor(uint256 _index)
		external
		view
		override
		returns (bytes32)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].major;
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

	function getMajorAddress(uint256 _index)
		external
		view
		override
		returns (address)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		(address majorAddress, , , ) = getMajorInfo(formulas[_index].major);
		return majorAddress;
	}

	function getDisenchant(uint256 _index)
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

	function getMajorInfo(bytes32 _major)
		public
		pure
		override
		returns (
			address,
			uint16,
			uint16,
			uint16
		)
	{
		Input.Data memory data = Input.from(abi.encodePacked(_major));
		address majorAddress = address(data.decodeBytes20());
		uint16 objectClassExt = data.decodeU16();
		uint16 majorClass = data.decodeU16();
		uint16 majorGrade = data.decodeU16();
		return (majorAddress, objectClassExt, majorClass, majorGrade);
	}
}
