// hevm: flattened sources of src/FurnaceSettingIds.sol
pragma solidity >=0.6.7 <0.7.0;

////// src/FurnaceSettingIds.sol
/* pragma solidity ^0.6.7; */

contract FurnaceSettingIds {
	uint256 public constant PREFER_GOLD = 1 << 1;
	uint256 public constant PREFER_WOOD = 1 << 2;
	uint256 public constant PREFER_WATER = 1 << 3;
	uint256 public constant PREFER_FIRE = 1 << 4;
	uint256 public constant PREFER_SOIL = 1 << 5;

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	//0x4655524e4143455f415050000000000000000000000000000000000000000000
	bytes32 public constant FURNACE_APP = "FURNACE_APP";

	//0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000
	bytes32 public constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";

	uint128 public constant RATE_PRECISION = 10**8;

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4c414e445f4954454d5f42415200000000000000000000
	bytes32 public constant CONTRACT_LAND_ITEM_BAR = "CONTRACT_LAND_ITEM_BAR";

	// 0x434f4e54524143545f41504f53544c455f4954454d5f42415200000000000000
	bytes32 public constant CONTRACT_APOSTLE_ITEM_BAR =
		"CONTRACT_APOSTLE_ITEM_BAR";

	// 0x434f4e54524143545f4954454d5f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";

	// 0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000
	bytes32 public constant CONTRACT_DRILL_BASE = "CONTRACT_DRILL_BASE";

	// 0x434f4e54524143545f44415257494e49415f49544f5f42415345000000000000
	bytes32 public constant CONTRACT_DARWINIA_ITO_BASE = "CONTRACT_DARWINIA_ITO_BASE";

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f4552433732315f4745474f000000000000000000000000
	bytes32 public constant CONTRACT_ERC721_GEGO = "CONTRACT_ERC721_GEGO";

	// 0x434f4e54524143545f464f524d554c4100000000000000000000000000000000
	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	//0x434f4e54524143545f4c505f52494e475f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_RING_ERC20_TOKEN =
		"CONTRACT_LP_RING_ERC20_TOKEN";

	//0x434f4e54524143545f4c505f4b544f4e5f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_KTON_ERC20_TOKEN =
		"CONTRACT_LP_KTON_ERC20_TOKEN";

	//0x434f4e54524143545f4c505f454c454d454e545f544f4b454e00000000000000
	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN = 
		"CONTRACT_LP_ELEMENT_TOKEN";

	// 0x434f4e54524143545f4c505f474f4c445f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_GOLD_ERC20_TOKEN =
		"CONTRACT_LP_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f574f4f445f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_WOOD_ERC20_TOKEN =
		"CONTRACT_LP_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f57415445525f45524332305f544f4b454e000000
	bytes32 public constant CONTRACT_LP_WATER_ERC20_TOKEN =
		"CONTRACT_LP_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f464952455f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_FIRE_ERC20_TOKEN =
		"CONTRACT_LP_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f534f494c5f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_SOIL_ERC20_TOKEN =
		"CONTRACT_LP_SOIL_ERC20_TOKEN";

	// 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_RING_ERC20_TOKEN =
		"CONTRACT_RING_ERC20_TOKEN";

	// 0x434f4e54524143545f4b544f4e5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_KTON_ERC20_TOKEN =
		"CONTRACT_KTON_ERC20_TOKEN";

	//0x434f4e54524143545f454c454d454e545f544f4b454e00000000000000000000
	bytes32 public constant CONTRACT_ELEMENT_TOKEN = 
		"CONTRACT_ELEMENT_TOKEN";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";
}
