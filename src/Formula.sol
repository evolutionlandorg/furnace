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
		uint112 baseRate,
		uint112 enhanceRate
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
		bytes calldata _meta,
		bytes32[] calldata _majors,
		address[] calldata _minors,
		uint256[] calldata _limits
	) external override auth {
		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				meta: _meta,
				majors: _majors,
				minors: _minors,
				limits: _limits,
				disable: false
			});
		formulas.push(formula);
		emit AddFormula(
			formulas.length - 1,
			formula.name,
			formula.meta,
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
		uint112 _baseRate,
		uint112 _enhanceRate
	) external auth {
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		Input.Data memory data = Input.from(formula.meta);
		uint16 class = data.decodeU16();
		uint16 grade = data.decodeU16();
		bool canDisenchant = data.decodeBool();
		formula.meta = abi.encodePacked(
			class,
			grade,
			_baseRate,
			_enhanceRate,
			canDisenchant
		);
		emit SetStrength(_index, _baseRate, _enhanceRate);
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

	function at(uint256 _index)
		external
		view
		override
		returns (
			bytes32,
			bytes memory,
			bytes32[] memory,
			address[] memory,
			uint256[] memory,
			bool
		)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry memory formula = formulas[_index];
		return (
			formula.name,
			formula.meta,
			formula.majors,
			formula.minors,
			formula.limits,
			formula.disable
		);
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

	function getMinorAddresses(uint256 _index)
		external
		view
		override
		returns (address[] memory)
	{
		return formulas[_index].minors;
	}

	function getMetaInfo(uint256 _index)
		external
		view
		override
		returns (
			bytes32,
			uint16,
			uint16,
			uint16,
			bool,
			uint128,
			uint128
		)
	{
		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry memory formula = formulas[_index];
		Input.Data memory data = Input.from(formula.meta);
		uint16 objectClassExt = data.decodeU16();
		uint16 class = data.decodeU16();
		uint16 grade = data.decodeU16();
		bool canDisenchant = data.decodeBool();
		uint128 base = data.decodeU128();
		uint128 enhance = data.decodeU128();
		return (
			formula.name,
			objectClassExt,
			class,
			grade,
			canDisenchant,
			base,
			enhance
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
