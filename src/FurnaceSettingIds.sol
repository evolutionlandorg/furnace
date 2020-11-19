pragma solidity ^0.6.7;
 
contract FurnaceSettingIds {

	uint256 internal constant PREFER_GOLD = 1 << 0;
	uint256 internal constant PREFER_WOOD = 1 << 1;
	uint256 internal constant PREFER_WATER = 1 << 2;
	uint256 internal constant PREFER_FIRE = 1 << 3;
	uint256 internal constant PREFER_SOIL = 1 << 4;

    uint8 internal constant ITEM_OBJECT_CLASS = 100; // Item

    // 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
    bytes32 internal constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    // 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
    bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f4954454d5f424153450000000000000000000000000000
    bytes32 internal constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";
}
