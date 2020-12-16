pragma solidity ^0.6.7;

import "./interfaces/IFormula.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./FurnaceSettingIds.sol";

contract FormulaInit is FurnaceSettingIds {

	uint128 public constant RATE_DECIMALS = 10 ** 6;
	// uint256 public constant UINT = 10 ** 18;
	uint256 public constant UINT = 10 ** 14;

	bool public isInit;
	ISettingsRegistry public registry;
	
	constructor(address _registry) public {
		registry = ISettingsRegistry(_registry);
	}

	function initFormula() public {
		require(isInit == false, "Furnace: ALREADY_INITED");
		initFormula0(registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN));
		initFormula0(registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN));
		initFormula0(registry.addressOf(CONTRACT_WATER_ERC20_TOKEN));
		initFormula0(registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN));
		initFormula0(registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN));

		initFormula5(registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN));
		initFormula5(registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN));
		initFormula5(registry.addressOf(CONTRACT_WATER_ERC20_TOKEN));
		initFormula5(registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN));
		initFormula5(registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN));

		initFormula10(registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN));
		initFormula10(registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN));
		initFormula10(registry.addressOf(CONTRACT_WATER_ERC20_TOKEN));
		initFormula10(registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN));
		initFormula10(registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN));

		initFormula15(registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN));
		initFormula15(registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN));
		initFormula15(registry.addressOf(CONTRACT_WATER_ERC20_TOKEN));
		initFormula15(registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN));
		initFormula15(registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN));
		isInit = true;
	}

	function initFormula0(address token) private {
		bytes32 name = "合金镐";	
		bytes memory meta = abi.encodePacked(uint16(5), uint16(1), uint16(1), true, uint128(4 * RATE_DECIMALS), uint128(4 * RATE_DECIMALS));
		bytes32[] memory majors = new bytes32[](1);
		address[] memory minors = new address[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_ERC721_GEGO), uint16(256), uint16(0), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = ((200 * UINT) << 128) | (350 * UINT);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		IFormula(formula).insert(name, meta, majors, minors, limits);
	}

	function initFormula5(address token) private {
		bytes32 name = "人力铸铁钻机";	
		bytes memory meta = abi.encodePacked(uint16(5), uint16(1), uint16(1), true, uint128(4 * RATE_DECIMALS), uint128(4 * RATE_DECIMALS));
		bytes32[] memory majors = new bytes32[](1);
		address[] memory minors = new address[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = ((200 * UINT) << 128) | (350 * UINT);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		IFormula(formula).insert(name, meta, majors, minors, limits);
	}

	function initFormula10(address token) private {
		bytes32 name = "人力钨钢钻机";	
		bytes memory meta = abi.encodePacked(uint16(5), uint16(1), uint16(2), true, uint128(7 * RATE_DECIMALS), uint128(8 * RATE_DECIMALS));
		bytes32[] memory majors = new bytes32[](1);
		address[] memory minors = new address[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(2), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = ((300 * UINT) << 128) | (550 * UINT);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		IFormula(formula).insert(name, meta, majors, minors, limits);
	}

	function initFormula15(address token) private {
		bytes32 name = "人力金刚钻机";	
		bytes memory meta = abi.encodePacked(uint16(5), uint16(1), uint16(3), true, uint128(30 * RATE_DECIMALS), uint128(70 * RATE_DECIMALS));
		bytes32[] memory majors = new bytes32[](1);
		address[] memory minors = new address[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(3), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = ((800 * UINT) << 128) | (2200 * UINT);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		IFormula(formula).insert(name, meta, majors, minors, limits);
	}
}
