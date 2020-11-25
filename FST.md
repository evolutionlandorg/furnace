# Furnace Standard Token/FST [draft] 

## Simple Summary
An extension of [ERC-721 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) to smelt a new NFT token from ERC721 tokens and ERC20 tokens. The new token can also disenchant to the origin ERC721 tokens and ERC20 tokens. Smelt rule is according to `Formula`. 

## Abstract
A FTS contract stores and keeps track of tokens which smelted from it. Can be disenchanted into origin ERC721 tokens and ERC20 tokens.

## Specification
FTS contracts must implement the [ERC-721 interface](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md).

**Smart contracts implementing the Furnace Standard MUST implement all of the functions in the `IFST` and `IFormula` interface.** 

```solidity
pragma solidity ^0.6.7;

interface IFST {
    /**
        @notice Caller must be owner of tokens to be smlted.
        @dev Smelt function, Smelt a new NFT token from ERC721 tokens and ERC20 tokens. Smelt rule is according to `Formula`.
        MUST revert if `_index` is not in `formula`.
        MUST revert if length of `_ids` is not the same as length of `formula` index rules.
        MUST revert if length of `_values` is not the same as length of `formula` index rules.
        MUST revert on any other error.        
        @param _ids     IDs of NFT tokens(order and length must match `formula` index rules).
        @param _values  Amounts of FT tokens(order and length must match `formula` index rules).
        @return         New Token ID of smelting.
    */
    function smelt(
        uint256 _index,
        uint256[] calldata _ids,
        uint256[] calldata _values
    ) external returns (uint256);

    // {
    // 	### smelt
    // 	1. check Formula rule by index
    //  2. transfer FTs and NFTs to address(this)
    // 	3. track FTs NFTs to new NFT
    // 	4. mint new NFT to caller
    // }

    /**
        @notice Caller must be owner of token id to be disenchated.
        @dev Disenchant function, A smelted NFT can be disenchanted into origin ERC721 tokens and ERC20 tokens recursively.
        MUST revert if  _depth is larger than the depth of _id token smleted.
        MUST revert on any other error.        
        @param _id     token ID to disenchant.
        @param _depth  recursion depth token disenchant.
    */
    function disenchat(uint256 _id, uint256 _depth) external;
    // {
    // 	### disenchant
    //  1. tranfer _id to address(this)
    // 	2. burn new NFT
    // 	3. delete track FTs NFTs to new NFT
    // 	4. transfer FNs NFTs to owner
    // }
}
```

```solidity
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
        // uint256 smeltTime;
        // uint256 disenchantTime;
        // uint256 loseRate;

        // major meterail of the Formula index
        address[] nfts;
        uint256[] class;
        uint256[] grade;
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
        @param _name    New smleted NFT name.
        @param _class    New smleted NFT class.
        @param _grade    New smleted NFT grade.
        @param _nfts    NFT token addresses of major meterail for smelting.
        @param _class   NFT token classes of major meterail for smelting(order and length must match `_nfts`).
        @param _grade   NFT token grades of major meterail for smelting(order and length must match `_nfts`).
        @param _fts     FT Token addresses of minor meterail for smelting.
        @param _mins    FT Token min amounts of minor meterail for smelting(order and length must match `_fts`).
        @param _maxs    FT Token max amounts of minor meterail for smelting(order and length must match `_fts`).
        @param _canDisenchant    New smleted NFT can disenchant or not.
    */
    function addFormula(
        string name,
        uint256 class,
        uint256 grade,
        address[] calldata _nfts,
        uint256[] calldata _class,
        uint256[] calldata _grade,
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
```
