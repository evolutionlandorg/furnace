pragma solidity ^0.6.7;

import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, FurnaceSettingIds, IFormula {
	event AddFormula(
		uint256 indexed index,
		bytes32 name,
		bytes32 meta,
		bytes32[] majors,
		bytes32[] minors
	);
	event RemoveFormula(uint256 indexed index);
	event SetFurnaceStrength(
		uint256 indexed objectClass,
		uint16 class,
		uint16 grade,
		uint128 base,
		uint128 enhance
	);

	struct Strength {
		uint128 base;
		uint128 enhance;
	}

	uint256 public constant DECIMALS = 10**10;

	/*** STORAGE ***/

	FormulaEntry[] public formulas;
	mapping(bytes32 => Strength) public strengths;

	function initialize() public initializer {
		// FormulaEntry memory f0 =
		// 	FormulaEntry({
		// 		name: "",
		// 		class: 0,
		// 		grade: 0,
		// 		canDisenchant: false,
		// 		disable: true,
		// 		majorIndex: new uint16[](0),
		// 		tokens: new bytes32[](0),
		// 		mins: new uint256[](0),
		// 		maxs: new uint256[](0)
		// 	});
		// formulas.push(f0);
		// // setFurnaceStrength(0, 0, 0);
	}

	function insert(
		bytes32 _name,
		bytes32 _meta,
		bytes32[] calldata _majors,
		bytes32[] calldata _minors
	) external override auth {
		// require(_majors.length == _classes.length && _majors.length == _grades.length, "majors length invalid");
		// require(_minors.length == _mins.length && _minors.length == _maxs.length, "minors length invalid");
		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				meta: _meta,
				majors: _majors,
				minors: _minors,
				disable: false
			});
		formulas.push(formula);
		emit AddFormula(
			formulas.length - 1,
			formula.name,
			formula.meta,
			formula.majors,
			formula.minors
		);
	}

	function remove(uint256 index) external override auth {
		require(index < formulas.length, "Formula: out of range");
		formulas[index].disable = true;
		emit RemoveFormula(index);
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
			bytes32,
			bytes32[] memory,
			bytes32[] memory,
			bool
		)
	{
		require(_index < formulas.length, "Formula: out of range");
		FormulaEntry memory formula = formulas[_index];
		return (
			formula.name,
			formula.meta,
			formula.majors,
			formula.minors,
			formula.disable
		);
	}

	function getMetaInfo(uint256 _index)
		external
		view
		override
		returns (
			bytes32,
			uint16,
			uint16,
			bool
		)
	{
		require(_index < formulas.length, "Formula: out of range");
		FormulaEntry memory formula = formulas[_index];
		(uint16 class, uint16 grade, bool canDisenchant) =
			abi.decode(_toBytes(formula.meta), (uint16, uint16, bool));
		return (formula.name, class, grade, canDisenchant);
	}

	function getMajorInfo(bytes32 _major)
		external
		pure
		override
		returns (
			address,
			uint16,
			uint16
		)
	{
		(address majorAddress, uint16 majorClass, uint16 majorGrade) =
			abi.decode(_toBytes(_major), (address, uint16, uint16));
		return (majorAddress, majorClass, majorGrade);
	}

	function getMinorInfo(bytes32 _minor)
		external
		pure
		override
		returns (
			address,
			uint256,
			uint256
		)
	{
		(address minorAddress, uint48 minorMin, uint48 minorMax) =
			abi.decode(_toBytes(_minor), (address, uint48, uint48));
		// * never overflows
		return (minorAddress, minorMin * DECIMALS, minorMax * DECIMALS);
	}

	// util to get key based on object class + formula index + appkey
	function _getKey(
		uint8 _objectClass,
		uint16 _class,
		uint16 _grade,
		bytes32 _appKey
	) internal pure returns (bytes32) {
		return
			keccak256(abi.encodePacked(_objectClass, _class, _grade, _appKey));
	}

	function getFurnaceStrength(uint16 _class, uint16 _grade)
		public
		view
		returns (uint128, uint128)
	{
		bytes32 key = _getKey(ITEM_OBJECT_CLASS, _class, _grade , FURNACE_APP);
		Strength memory s = strengths[key];
		return (s.base, s.enhance);
	}

	function setFurnaceStrength(
		uint16 _class,
		uint16 _grade,
		uint128 _base,
		uint128 _enhance
	) public auth {
		bytes32 key = _getKey(ITEM_OBJECT_CLASS, _class, _grade, FURNACE_APP);
		Strength memory s = Strength({ base: _base, enhance: _enhance });
		strengths[key] = s;
		emit SetFurnaceStrength(
			DRILL_OBJECT_CLASS,
			_class,
			_grade,
			_base,
			_enhance
		);
	}

	function _toBytes(bytes32 self) internal pure returns (bytes memory bts) {
		bts = new bytes(32);
		assembly {
			mstore(
				add(
					bts,
					/*BYTES_HEADER_SIZE*/
					32
				),
				self
			)
		}
	}
}
