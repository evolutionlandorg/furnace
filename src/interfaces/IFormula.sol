pragma solidity ^0.6.7;

interface IFormula {
    struct FormulaEntry {
		// Item parameter
        string name;
        uint256 class;
        uint256 grade;
        bool canDisenchant;
        // if it is removed
        bool disable;
        // uint256 enchantTime;
        // uint256 disenchantTime;
        // uint256 loseRate;

        // major meterail of the Formula index
        address[] nfts;
        uint256[] classes;
        uint256[] grades;
        // minor meterail info
        address[] fts;
        uint256[] mins;
        uint256[] maxs;
    }

    /**
        @notice Only governance can add `formula`.
        @dev Add a formula rule.
        MUST revert if length of `_nfts` is not the same as length of `_class`.
        MUST revert if length of `_fts` is not the same as length of `_mins` and `_maxs.
        MUST revert on any other error.        
        @param _name    New enchanted NFT name.
        @param _class   New enchanted NFT class.
        @param _grade   New enchanted NFT grade.
        @param _canDisenchant    New enchanted NFT can disenchant or not.
        @param _nfts    NFT token addresses of major meterail for enchanting.
        @param _classes   NFT token classes of major meterail for enchanting(order and length must match `_nfts`).
        @param _grades   NFT token grades of major meterail for enchanting(order and length must match `_nfts`).
        @param _fts     FT Token addresses of minor meterail for enchanting.
        @param _mins    FT Token min amounts of minor meterail for enchanting(order and length must match `_fts`).
        @param _maxs    FT Token max amounts of minor meterail for enchanting(order and length must match `_fts`).
    */
    function addFormula(
        string calldata _name,
        uint256 _class,
        uint256 _grade,
        bool _canDisenchant
        address[] calldata _nfts,
        uint256[] calldata _classes,
        uint256[] calldata _grades,
        address[] calldata _fts,
        uint256[] calldata _mins,
        uint256[] calldata _maxs
    ) external;

    /**
        @notice Only governance can remove `formula`.
        @dev Remove a formula rule.
        MUST revert on any other error.        
        @param _index    Disble the formule of index.
    */
    function removeFormula(uint256 _index) external;
}
