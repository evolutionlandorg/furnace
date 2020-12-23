pragma solidity ^0.6.7;

interface IFormula {
	struct FormulaEntry {
		// Item parameter
		bytes32 name;
		uint128 base;
		uint128 enhance;
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		bool canDisenchant;
		// if it is removed
		// uint256 enchantTime;
		// uint256 disenchantTime;
		// uint256 loseRate;

		// major meterail info
		// [address token, uint16 objectClassExt, uint16 class, uint16 grade]
		bytes32[] majors;
		// minor meterail info
		bytes32[] minors;
		// [uint128 min, uint128 max]
		uint256[] limits;
		bool disable;
	}

	event AddFormula(
		uint256 indexed index,
		bytes32 name,
		uint128 base,
		uint128 enhance,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		bool canDisenchant,
		bytes32[] majors,
		bytes32[] minors,
		uint256[] limits
	);
	event DisableFormula(uint256 indexed index);
	event EnableFormula(uint256 indexed index);

	/**
        @notice Only governance can add `formula`.
        @dev Add a formula rule.
        MUST revert if length of `_majors` is not the same as length of `_class`.
        MUST revert if length of `_minors` is not the same as length of `_mins` and `_maxs.
        MUST revert on any other error.        
        @param _name     New enchanted NFT name.
        @param _majors   FT token addresses of major meterail for enchanting.
        @param _minors   FT Token addresses of minor meterail for enchanting.
        @param _limits   FT Token limits of minor meterail for enchanting.
    */
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
	) external;

	/**
        @notice Only governance can disble `formula`.
        @dev Disble a formula rule.
        MUST revert on any other error.        
        @param _index    Disble the formule of index.
    */
	function disable(uint256 _index) external;

	function enable(uint256 _index) external;

	//0x1f7b6d32
	function length() external view returns (uint256);

	function isDisable(uint256 _index)
		external
		view
		returns (bool);

	function getMajors(uint256 _index)
		external
		view
		returns (bytes32[] memory);

	function getMinors(uint256 _index)
		external
		view
		returns (bytes32[] memory, uint256[] memory);

	//0x6ef2fd27
	function getMajorInfo(bytes32 _major)
		external
		pure
		returns (
			address,
			uint16,
			uint16,
			uint16
		);

	//0x827d6320
	function getLimit(uint256 _limit)
		external
		pure
		returns (
			uint128,
			uint128
		);

	//0x78533046
	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint128,
			uint128
		);

	//0x762b8a4d
	function getMajorAddresses(uint256 _index)
		external
		view
		returns (address[] memory);

	function getDisenchant(uint256 _index)
		external
		view
		returns (bool);
}
