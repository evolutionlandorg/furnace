pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./common/Input.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, FurnaceSettingIds, IFormula {
	using Input for Input.Data;
	event SetStrength(
		uint256 indexed inde,
		uint128 baseRate,
		uint128 enhanceRate
	);

	event SetLimits(uint256 indexed index, uint256[] limits);

	/*** STORAGE ***/

	FormulaEntry[] public formulas;

	function initialize() public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
	}

	function insert(
		bytes32 _name,
		uint128 _base,
		uint128 _enhance,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32[] calldata _majors,
		bytes32[] calldata _minors,
		uint256[] calldata _limits
	) external override auth {
		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				base: _base,
				enhance: _enhance,
				objClassExt: _objClassExt,
				class: _class,
				grade: _grade,
				canDisenchant: _canDisenchant,
				majors: _majors,
				minors: _minors,
				limits: _limits,
				disable: false
			});
		formulas.push(formula);
		emit AddFormula(
			formulas.length - 1,
			formula.name,
			formula.base,
			formula.enhance,
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.canDisenchant,
			formula.majors,
			formula.minors,
			formula.limits
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

	function setStrengthRate(
		uint256 _index,
		uint128 _baseRate,
		uint128 _enhanceRate
	) external auth {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.base = _baseRate;
		formula.enhance = _enhanceRate;
		emit SetStrength(_index, formula.base, formula.enhance);
	}

	function setLimit(uint256 _index, uint256[] calldata _limits)
		external
		auth
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.limits = _limits;
		emit SetLimits(_index, formula.limits);
	}

	function length() external view override returns (uint256) {
		return formulas.length;
	}

	function isDisable(uint256 _index) external view override returns (bool) {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].disable;
	}

	function getMajors(uint256 _index)
		external
		view
		override
		returns (bytes32[] memory)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].majors;
	}

	function getMinors(uint256 _index)
		external
		view
		override
		returns (bytes32[] memory, uint256[] memory)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return (formulas[_index].minors, formulas[_index].limits);
	}

	function getMajorAddresses(uint256 _index)
		external
		view
		override
		returns (address[] memory)
	{
		FormulaEntry memory formula = formulas[_index];
		address[] memory majorAddresses = new address[](formula.majors.length);
		for (uint256 i = 0; i < formula.majors.length; i++) {
			(address majorAddress, , , ) = getMajorInfo(formula.majors[i]);
			majorAddresses[i] = majorAddress;
		}
		return majorAddresses;
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
			uint128,
			uint128
		)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		return (
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.base,
			formula.enhance
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

	function getLimit(uint256 _limit)
		public
		pure
		override
		returns (uint128, uint128)
	{
		return (uint128(_limit >> 128), uint128((_limit << 128) >> 128));
	}
}
