// hevm: flattened sources of src/FormulaInit.sol
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

////// src/interfaces/IFormula.sol
/* pragma solidity ^0.6.7; */

/**
@title IFormula
@author echo.hu@itering.com
*/
interface IFormula {
	struct FormulaEntry {
		// item name
		bytes32 name;
		// strength rate
		uint128 rate;
		// extension of `ObjectClass`
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		bool canDisenchant;
		// if it is removed
		// uint256 enchantTime;
		// uint256 disenchantTime;
		// uint256 loseRate;

		bool disable;

		// minor material info
		bytes32 minor;
		uint256 amount;
		// major material info
		// [address token, uint16 objectClassExt, uint16 class, uint16 grade]
		address majorAddr;
		uint16 majorObjClassExt;
		uint16 majorClass;
		uint16 majorGrade;
	}

	event AddFormula(
		uint256 indexed index,
		bytes32 name,
		uint128 rate,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		bool canDisenchant,
		bytes32 minor,
		uint256 amount,
		address majorAddr,
		uint16 majorObjClassExt,
		uint16 majorClass,
		uint16 majorGrade
	);
	event DisableFormula(uint256 indexed index);
	event EnableFormula(uint256 indexed index);

	/**
        @notice Only governance can add `formula`.
        @dev Add a formula rule.
        MUST revert if length of `_majors` is not the same as length of `_class`.
        MUST revert if length of `_minors` is not the same as length of `_mins` and `_maxs.
        MUST revert on any other error.        
        @param _name         New enchanted NFT name.
        @param _rate         New enchanted NFT rate.
        @param _objClassExt  New enchanted NFT objectClassExt.
        @param _class        New enchanted NFT class.
        @param _grade        New enchanted NFT grade.
        @param _minor        FT Token address of minor meterail for enchanting.
        @param _amount       FT Token amount of minor meterail for enchanting.
        @param _majorAddr    FT token address of major meterail for enchanting.
        @param _majorObjClassExt   FT token objectClassExt of major meterail for enchanting.
        @param _majorClass   FT token class of major meterail for enchanting.
        @param _majorGrade   FT token grade of major meterail for enchanting.
    */
	function insert(
		bytes32 _name,
		uint128 _rate,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32 _minor,
		uint256 _amount,
		address _majorAddr,
		uint16 _majorObjClassExt,
		uint16 _majorClass,
		uint16 _majorGrade
	) external;

	/**
        @notice Only governance can enable `formula`.
        @dev Enable a formula rule.
        MUST revert on any other error.        
        @param _index  index of formula.
    */
	function disable(uint256 _index) external;

	/**
        @notice Only governance can disble `formula`.
        @dev Disble a formula rule.
        MUST revert on any other error.        
        @param _index  index of formula.
    */
	function enable(uint256 _index) external;

	/**
        @dev Returns the length of the formula.
	         0x1f7b6d32
     */
	function length() external view returns (uint256);

	/**
        @dev Returns the availability of the formula.
     */
	function isDisable(uint256 _index) external view returns (bool);

	/**
        @dev returns the minor material of the formula.
     */
	function getMinor(uint256 _index)
		external
		view
		returns (bytes32, uint256);

	/**
        @dev Decode major info of the major.
	         0x6ef2fd27
		@return {
			"token": "Major token address.",
			"objClassExt": "Major token objClassExt.",
			"class": "Major token class.",
			"grade": "Major token address."
		}
     */
	function getMajorInfo(uint256 _index)
		external
		view	
		returns (
			address,
			uint16,
			uint16,
			uint16
		);

	/**
        @dev Returns meta info of the item.
	         0x78533046
		@return {
			"objClassExt": "Major token objClassExt.",
			"class": "Major token class.",
			"grade": "Major token address.",
			"base":  "Base strength rate.",
			"enhance": "Enhance strength rate.",
		}
     */
	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint128
		);

	/**
        @dev returns canDisenchant of the formula.
     */
	function canDisenchant(uint256 _index) external view returns (bool);
}

////// src/interfaces/IMetaDataTeller.sol
/* pragma solidity ^0.6.7; */

interface IMetaDataTeller {
	function addTokenMeta(
		address _token,
		uint16 _grade,
		uint112 _strengthRate
	) external;

	function getObjClassExt(address _token, uint256 _id) external view returns (uint16 objClassExt);

	//0xf666196d
	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16, uint16);

    //0x7999a5cf
	function getPrefer(bytes32 _minor, address _token) external view returns (uint256);

	//0x33281815
	function getRate(
		address _token,
		uint256 _id,
		uint256 _index
	) external view returns (uint256);

	//0xf8350ed0
	function isAllowed(address _token, uint256 _id) external view returns (bool);
}

////// src/interfaces/ISettingsRegistry.sol
/* pragma solidity ^0.6.7; */

interface ISettingsRegistry {
    function uintOf(bytes32 _propertyName) external view returns (uint256);

    function stringOf(bytes32 _propertyName) external view returns (string memory);

    function addressOf(bytes32 _propertyName) external view returns (address);

    function bytesOf(bytes32 _propertyName) external view returns (bytes memory);

    function boolOf(bytes32 _propertyName) external view returns (bool);

    function intOf(bytes32 _propertyName) external view returns (int);

    function setUintProperty(bytes32 _propertyName, uint _value) external;

    function setStringProperty(bytes32 _propertyName, string calldata _value) external;

    function setAddressProperty(bytes32 _propertyName, address _value) external;

    function setBytesProperty(bytes32 _propertyName, bytes calldata _value) external;

    function setBoolProperty(bytes32 _propertyName, bool _value) external;

    function setIntProperty(bytes32 _propertyName, int _value) external;

    function getValueTypeOf(bytes32 _propertyName) external view returns (uint /* SettingsValueTypes */ );

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}

////// src/FormulaInit.sol
/* pragma solidity ^0.6.7; */

/* import "./interfaces/IFormula.sol"; */
/* import "./interfaces/ISettingsRegistry.sol"; */
/* import "./interfaces/IMetaDataTeller.sol"; */
/* import "./FurnaceSettingIds.sol"; */

contract FormulaInit is FurnaceSettingIds {

	uint128 public constant RATE_DECIMALS = 10 ** 6;
	// uint256 public constant UNIT = 10 ** 18;
	uint256 public constant UNIT = 10 ** 14;

	bool public isInit;
	ISettingsRegistry public registry;
	address formula;
	
	constructor(address _registry) public {
		registry = ISettingsRegistry(_registry);
		formula = registry.addressOf(CONTRACT_FORMULA);
	}

	function initFormula() public {
		require(isInit == false, "Furnace: ALREADY_INITED");
		_initFormula0(CONTRACT_ELEMENT_TOKEN);
		_initFormula1(CONTRACT_ELEMENT_TOKEN);
		_initFormula2(CONTRACT_ELEMENT_TOKEN);
		_initFormula3(CONTRACT_ELEMENT_TOKEN);

		_initFormula4(CONTRACT_LP_ELEMENT_TOKEN);
		_initFormula5(CONTRACT_LP_ELEMENT_TOKEN);
		_initFormula6(CONTRACT_LP_ELEMENT_TOKEN);
		_initFormula7(CONTRACT_LP_ELEMENT_TOKEN);

		// _initFormula8(CONTRACT_LP_KTON_ERC20_TOKEN);
		// _initFormula9(CONTRACT_LP_KTON_ERC20_TOKEN);
		// _initFormula10(CONTRACT_LP_RING_ERC20_TOKEN);
		// _initFormula11(CONTRACT_LP_RING_ERC20_TOKEN);
		// _initFormula12(CONTRACT_LP_KTON_ERC20_TOKEN);
		isInit = true;
	}

	function _initFormula0(bytes32 token) private {
		bytes32 name = "合金镐";	
		bytes32 minor = token;
		uint256 limit = 200 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_ERC721_GEGO);
		uint16 objClassExt = 256;
		uint16 class = 0;
		uint16 grade = 1;
		IFormula(formula).insert(name, uint128(4 * RATE_DECIMALS), uint16(256), uint16(1), uint16(1), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula1(bytes32 token) private {
		bytes32 name = "人力铸铁钻机";	
		bytes32 minor = token;
		uint256 limit = 200 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt =  4;
		uint16 class = 0;
		uint16 grade = 1;
		IFormula(formula).insert(name, uint128(4 * RATE_DECIMALS), uint16(4), uint16(1), uint16(1), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula2(bytes32 token) private {
		bytes32 name = "人力钨钢钻机";	
		bytes32 minor = token;
		uint256 limit = 300 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 4;
		uint16 class = 0;
		uint16 grade = 2;
		IFormula(formula).insert(name, uint128(7 * RATE_DECIMALS), uint16(4), uint16(1), uint16(2), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula3(bytes32 token) private {
		bytes32 name = "人力金刚钻机";	
		bytes32 minor = token;
		uint256 limit = 800 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 16;
		uint16 class = 0;
		uint16 grade = 3;
		IFormula(formula).insert(name, uint128(30 * RATE_DECIMALS), uint16(4), uint16(1), uint16(3), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula4(bytes32 token) private {
		bytes32 name = "高级合金镐";	
		bytes32 minor = token;
		uint256 limit = 200 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 256;
		uint16 class = 1;
		uint16 grade = 1;
		IFormula(formula).insert(name, uint128(13 * RATE_DECIMALS), uint16(256), uint16(2), uint16(1), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula5(bytes32 token) private {
		bytes32 name = "燃油铸铁钻机";	
		bytes32 minor = token;
		uint256 limit = 200 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 4;
		uint16 class = 1;
		uint16 grade = 1;
		IFormula(formula).insert(name, uint128(13 * RATE_DECIMALS), uint16(4), uint16(2), uint16(1), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula6(bytes32 token) private {
		bytes32 name = "燃油钨钢钻机";	
		bytes32 minor = token;
		uint256 limit = 300 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 4;
		uint16 class = 1;
		uint16 grade = 2;
		IFormula(formula).insert(name, uint128(22 * RATE_DECIMALS), uint16(4), uint16(2), uint16(2), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	function _initFormula7(bytes32 token) private {
		bytes32 name = "燃油金刚钻机";	
		bytes32 minor = token;
		uint256 limit = 800 * UNIT;
		address majorAddr = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		uint16 objClassExt = 4;
		uint16 class = 1;
		uint16 grade = 3;
		IFormula(formula).insert(name, uint128(80 * RATE_DECIMALS), uint16(4), uint16(2), uint16(3), true, minor, limit, majorAddr, objClassExt, class, grade);
	}

	// function _initFormula8(bytes32 token1) private {
	// 	bytes32 name = "超级合金镐";	
	// 	bytes32 majors;
	// 	bytes32 minors;
	// 	uint256 limits;
	// 	bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(256), uint16(2), uint16(1), bytes6(0)); 
	// 	majors = abi.decode(majorData, (bytes32));
	// 	minors = token1;
	// 	limits = 150 * UNIT;
	// 	IFormula(formula).insert(name, uint128(26 * RATE_DECIMALS), uint16(256), uint16(3), uint16(1), true, majors, minors, limits);
	// }

	// function _initFormula9(bytes32 token1) private {
	// 	bytes32 name = "铸铁挖掘机";	
	// 	bytes32 majors;
	// 	bytes32 minors;
	// 	uint256 limits;
	// 	bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(1), bytes6(0)); 
	// 	majors = abi.decode(majorData, (bytes32));
	// 	minors = token1;
	// 	limits = 150 * UNIT;
	// 	IFormula(formula).insert(name, uint128(26 * RATE_DECIMALS), uint16(4), uint16(3), uint16(1), true, majors, minors, limits);
	// }

	// function _initFormula10(bytes32 token1) private {
	// 	bytes32 name = "钨钢挖掘机";	
	// 	bytes32 majors;
	// 	bytes32 minors;
	// 	uint256 limits;
	// 	bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(2), bytes6(0)); 
	// 	majors = abi.decode(majorData, (bytes32));
	// 	minors = token1;
	// 	limits = 230 * UNIT;
	// 	IFormula(formula).insert(name, uint128(44 * RATE_DECIMALS), uint16(4), uint16(3), uint16(2), true, majors, minors, limits);
	// }

	// function _initFormula11(bytes32 token1) private {
	// 	bytes32 name = "金刚挖掘机";	
	// 	bytes32 majors;
	// 	bytes32 minors;
	// 	uint256 limits;
	// 	bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(3), bytes6(0)); 
	// 	majors = abi.decode(majorData, (bytes32));
	// 	minors = token1;
	// 	limits = 800 * UNIT;
	// 	IFormula(formula).insert(name, uint128(180 * RATE_DECIMALS), uint16(4), uint16(3), uint16(3), true, majors, minors, limits);
	// }

	// function _initFormula12(bytes32 token1, bytes32 token2) private {
	// 	bytes32 name = "蓝翔挖掘机";	
	// 	bytes32 majors;
	// 	bytes32 minors;
	// 	uint256 limits;
	// 	bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(3), bytes6(0)); 
	// 	majors = abi.decode(majorData, (bytes32));
	// 	minors = token1;
	// 	limits = 900 * UNIT;
	// 	IFormula(formula).insert(name, uint128(220 * RATE_DECIMALS), uint16(4), uint16(3), uint16(3), true, majors, minors, limits);
	// }
}

