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
		bytes meta,
		bytes32[] majors,
		bytes32[] minors
	);
	event RemoveFormula(uint256 indexed index);

	event SetStrength(
		uint256 indexed inde,
		uint112 baseRate,
		uint112 enhanceRate
	);

	uint256 public constant DECIMALS = 10**10;

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
		bytes32[] calldata _minors
	) external override auth {
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

	function remove(uint256 _index) external override auth {
		require(_index < formulas.length, "Formula: out of range");
		formulas[_index].disable = true;
		emit RemoveFormula(_index);
	}

	function setStrengthRate(
		uint256 _index,
		uint112 _baseRate,
		uint112 _enhanceRate
	) external auth {
		require(_index < formulas.length, "Formula: out of range");
		FormulaEntry storage formula = formulas[_index];
		(uint16 class, uint16 grade, , , bool canDisenchant) =
			abi.decode(formula.meta, (uint16, uint16, uint112, uint112, bool));
		formula.meta = abi.encodePacked(
			class,
			grade,
			_baseRate,
			_enhanceRate,
			canDisenchant
		);
		emit SetStrength(_index, _baseRate, _enhanceRate);
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

	function getAddresses(uint256 _index)
		external
		view
		override
		returns (address[] memory, address[] memory)
	{
		FormulaEntry memory formula = formulas[_index];
		address[] memory majorAddresses = new address[](formula.majors.length);
		for (uint256 i = 0; i < formula.majors.length; i++) {
			(address majorAddress, , ) = getMajorInfo(formula.majors[i]);
			majorAddresses[i] = majorAddress;
		}
		address[] memory minorAddresses = new address[](formula.minors.length);
		for (uint256 i = 0; i < formula.minors.length; i++) {
			(address minorAddress, , ) = getMinorInfo(formula.majors[i]);
			minorAddresses[i] = minorAddress;
		}
		return (majorAddresses, minorAddresses);
	}

	function getMetaInfo(uint256 _index)
		external
		view
		override
		returns (
			bytes32,
			uint16,
			uint16,
			uint112,
			uint112,
			bool
		)
	{
		require(_index < formulas.length, "Formula: out of range");
		FormulaEntry memory formula = formulas[_index];
		(
			uint16 class,
			uint16 grade,
			uint112 base,
			uint112 enhance,
			bool canDisenchant
		) = abi.decode(formula.meta, (uint16, uint16, uint112, uint112, bool));
		return (formula.name, class, grade, base, enhance, canDisenchant);
	}

	function getMajorInfo(bytes32 _major)
		public
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
		public
		pure
		override
		returns (
			address,
			uint112,
			uint112
		)
	{
		// range: [10**10, 2**48 * 10**10]
		(address minorAddress, uint48 minorMin, uint48 minorMax) =
			abi.decode(_toBytes(_minor), (address, uint48, uint48));
		// * never overflows
		return (
			minorAddress,
			uint112(minorMin * DECIMALS),
			uint112(minorMax * DECIMALS)
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
