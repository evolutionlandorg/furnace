pragma solidity ^0.6.7;

/**
@title IELIP002
@dev See https://github.com/evolutionlandorg/furnace/blob/main/elip-002.md
@author echo.hu@itering.com
*/
interface IELIP002 {
	struct Item {
		// index of `Formula`
		uint256 index;
		//  strength rate
		uint128 rate;
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		// element prefer
		uint16 prefer;
		//  major material
		address major;
		uint256 id;
		// amount of minor material
		address minor;
		uint256 amount;
	}

	/**
        @dev `Enchanted` MUST emit when item is enchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the enchant (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is enchanted.
        The `index` argument MUST be index of the `Formula`.
        The `rate` argument MUST be rate of minor material.
        The `objClassExt` argument MUST be extension of `ObjectClass`.
        The `class` argument MUST be class of the item.
        The `grade` argument MUST be grade of the item.
        The `prefer` argument MUST be prefer of the item.
        The `major` argument MUST be token address of major material.
        The `id` argument MUST be token id of major material.
        The `minor` argument MUST be token address of minor material.
        The `amount` argument MUST be token amount of minor material.
        The `now` argument MUST be timestamp of enchant.
    */
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint128 rate,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		address major,
		uint256 id,
		address minor,
		uint256 amount,
		uint256 now
	);

	/**
        @dev `Disenchanted` MUST emit when item is disenchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the disenchanted (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is disenchated.
        The `majors` argument MUST be major token addresses of major material.
        The `ids` argument MUST be token ids of major material.
        The `minors` argument MUST be token addresses of minor material.
        The `amounts` argument MUST be token amounts of minor material.
    */
	event Disenchanted(
		address indexed user,
		uint256 tokenId,
		address major,
		uint256 id,
		address minor,
		uint256 amount
	);

	/**
        @notice Caller must be owner of tokens to enchant.
        @dev Enchant function, Enchant a new NFT token from ERC721 tokens and ERC20 tokens. Enchant rule is according to `Formula`.
        MUST revert if `_index` is not in `formula`.
        MUST revert if length of `_ids` is not the same as length of `formula` index rules.
        MUST revert if length of `_values` is not the same as length of `formula` index rules.
        MUST revert on any other error.        
        @param _id     ID of NFT tokens(order and length must match `formula` index rules).
        @param _token  Address of FT tokens(order and length must match `formula` index rules).
		@return {
			"tokenId": "New Token ID of Enchanting."
		}
    */
	function enchant(
		uint256 _index,
		uint256 _id,
		address _token
	) external returns (uint256);

	// {
	// 	### smelt
	// 	1. check Formula rule by index
	//  2. transfer FT and NFT to address(this)
	// 	3. track FTs NFT to new NFT
	// 	4. mint new NFT to caller
	// }

	/**
        @notice Caller must be owner of token id to disenchat.
        @dev Disenchant function, A enchanted NFT can be disenchanted into origin ERC721 tokens and ERC20 tokens recursively.
        MUST revert on any other error.        
        @param _id     Token ID to disenchant.
        @param _depth   Depth of disenchanting recursively.
    */
	function disenchant(uint256 _id, uint256 _depth) external;

	// {
	// 	### disenchant
	//  1. tranfer _id to address(this)
	// 	2. burn new NFT
	// 	3. delete track FTs NFTs to new NFT
	// 	4. transfer FNs NFTs to owner
	// }

	/**
        @dev Get base info of item.
        @param _tokenId Token id of item.
		@return {
			"objClassExt": "Extension of `ObjectClass`.",
			"class": "Class of the item.",
			"grade": "Grade of the item."
		}
    */
	function getBaseInfo(uint256 _tokenId)
		external
		view
		returns (
			uint16,
			uint16,
			uint16
		);

	/**
        @dev Get rate of item.
        @param _tokenId Token id of item.
        @param _element Element item prefer.
		@return {
			"rate": "strength rate of item."
		}
    */
	function getRate(uint256 _tokenId, uint256 _element)
		external
		view
		returns (uint256);

	function getPrefer(uint256 _tokenId)
		external
		view
		returns (uint16);

	function getObjectClassExt(uint256 _tokenId) 
		external	
		view
		returns (uint16);
}
