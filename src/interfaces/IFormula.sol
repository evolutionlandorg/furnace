pragma solidity ^0.6.7;

interface IFormula {
    struct FormulaEntry {
        string name;
        uint256 class;
        uint256 grade;
        bool canDisenchant;
        // if it is removed
        bool disable;
        // counter
        uint256 total;
        // uint256 enchantTime;
        // uint256 disenchantTime;
        // uint256 loseRate;

        // major meterail of the Formula index
        uint256[] majorIndexes;
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
        @param _majorIndexes    Formula indexes of major meterail for enchanting.
        @param _fts     FT Token addresses of minor meterail for enchanting.
        @param _mins    FT Token min amounts of minor meterail for enchanting(order and length must match `_fts`).
        @param _maxs    FT Token max amounts of minor meterail for enchanting(order and length must match `_fts`).
        @param _canDisenchant    New enchanted NFT can disenchant or not.
    */
    function addFormula(
        string calldata _name,
        uint256 _class,
        uint256 _grade,
        uint256[] calldata _majorIndexes,
        address[] calldata _fts,
        uint256[] calldata _mins,
        uint256[] calldata _maxs,
        bool _canDisenchant
    ) external;

    /**
        @notice Only governance can remove `formula`.
        @dev Remove a formula rule.
        MUST revert on any other error.        
        @param _index    Disble the formule of index.
    */
    function removeFormula(uint256 _index) external;
}
