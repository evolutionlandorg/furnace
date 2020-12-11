pragma solidity ^0.6.7;

interface IFormula {
	struct FormulaEntry {
		// Item parameter
		bytes32 name;
		// [uint16 class, uint16 grade, bool canDisenchant, uint128 base, uint128 enhance] 
		bytes meta;
		// if it is removed
		// uint256 enchantTime;
		// uint256 disenchantTime;
		// uint256 loseRate;

		// major meterail info
		// [address token, uint16 class, uint16 grade]
		bytes32[] majors;
		// minor meterail info
		address[] minors;
		// [uint128 min, uint128 max]
		uint256[] limits;
		bool disable;
	}

	/**
        @notice Only governance can add `formula`.
        @dev Add a formula rule.
        MUST revert if length of `_majors` is not the same as length of `_class`.
        MUST revert if length of `_minors` is not the same as length of `_mins` and `_maxs.
        MUST revert on any other error.        
        @param _name    New enchanted NFT name.
        @param _meta    Metadata of new enchanted NFT.
        @param _majors    NFT token addresses of major meterail for enchanting.
        @param _minors     FT Token addresses of minor meterail for enchanting.
        @param _limits     FT Token limits of minor meterail for enchanting.
    */
	function insert(
		bytes32 _name,
		bytes calldata _meta,
		bytes32[] calldata _majors,
		address[] calldata _minors,
		uint256[] calldata _limits
	) external;

	/**
        @notice Only governance can remove `formula`.
        @dev Remove a formula rule.
        MUST revert on any other error.        
        @param _index    Disble the formule of index.
    */
	function remove(uint256 _index) external;

	function length() external view returns (uint256);

	function at(uint256 _index)
		external
		view
		returns (
			bytes32,
			bytes memory,
			bytes32[] memory,
			address[] memory,
			uint256[] memory,
			bool
		);

	function getMajorInfo(bytes32 _major)
		external
		pure
		returns (
			address,
			uint16,
			uint16
		);

	function getLimit(uint256 _limit)
		external
		pure
		returns (
			uint128,
			uint128
		);

	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			bytes32,
			uint16,
			uint16,
			bool,
			uint128,
			uint128
		);

	function getMajorAddresses(uint256 _index)
		external
		view
		returns (address[] memory);

	function getMinorAddresses(uint256 _index)
		external
		view
		returns (address[] memory);
}
