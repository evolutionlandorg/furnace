pragma solidity ^0.6.7;

interface IFormula {
	struct FormulaEntry {
		// Item parameter
		string name;
		bytes32 meta;
		// if it is removed
		// uint256 enchantTime;
		// uint256 disenchantTime;
		// uint256 loseRate;

		// major meterail info
		bytes32[] majors;
		// minor meterail info
		bytes32[] minors;
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
    */
	function addFormula(
		string calldata _name,
		bytes32 _meta,
		bytes32[] calldata _majors,
		bytes32[] calldata _minors
	) external;

	/**
        @notice Only governance can remove `formula`.
        @dev Remove a formula rule.
        MUST revert on any other error.        
        @param _index    Disble the formule of index.
    */
	function removeFormula(uint256 _index) external;

	function length() external view returns (uint256);

	function at(uint256 _index)
		external
		view
		returns (
			string memory,
			bytes32,
			bytes32[] memory,
			bytes32[] memory,
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

	function getMinorInfo(bytes32 _minor)
		external
		pure
		returns (
			address,
			uint256,
			uint256
		);

	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			string memory,
			uint16,
			uint16,
			bool
		);
}
