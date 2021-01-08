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

		_initFormula8(CONTRACT_LP_ELEMENT_TOKEN, CONTRACT_LP_KTON_ERC20_TOKEN);
		_initFormula9(CONTRACT_LP_ELEMENT_TOKEN, CONTRACT_LP_KTON_ERC20_TOKEN);
		_initFormula10(CONTRACT_LP_ELEMENT_TOKEN, CONTRACT_LP_RING_ERC20_TOKEN);
		_initFormula11(CONTRACT_LP_ELEMENT_TOKEN, CONTRACT_LP_RING_ERC20_TOKEN);
		_initFormula12(CONTRACT_LP_ELEMENT_TOKEN, CONTRACT_LP_KTON_ERC20_TOKEN);
		isInit = true;
	}

	function _initFormula0(bytes32 token) private {
		bytes32 name = "合金镐";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_ERC721_GEGO), uint16(256), uint16(0), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 200 * UINT;
		IFormula(formula).insert(name, uint128(4 * RATE_DECIMALS), uint16(256), uint16(1), uint16(1), true, majors, minors, limits);
	}

	function _initFormula1(bytes32 token) private {
		bytes32 name = "人力铸铁钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 200 * UINT;
		IFormula(formula).insert(name, uint128(4 * RATE_DECIMALS), uint16(4), uint16(1), uint16(1), true, majors, minors, limits);
	}

	function _initFormula2(bytes32 token) private {
		bytes32 name = "人力钨钢钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(2), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 300 * UINT;
		IFormula(formula).insert(name, uint128(7 * RATE_DECIMALS), uint16(4), uint16(1), uint16(2), true, majors, minors, limits);
	}

	function _initFormula3(bytes32 token) private {
		bytes32 name = "人力金刚钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(0), uint16(3), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 800 * UINT;
		IFormula(formula).insert(name, uint128(30 * RATE_DECIMALS), uint16(4), uint16(1), uint16(3), true, majors, minors, limits);
	}

	function _initFormula4(bytes32 token) private {
		bytes32 name = "高级合金镐";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(256), uint16(1), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 200 * UINT;
		IFormula(formula).insert(name, uint128(13 * RATE_DECIMALS), uint16(256), uint16(2), uint16(1), true, majors, minors, limits);
	}

	function _initFormula5(bytes32 token) private {
		bytes32 name = "燃油铸铁钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(1), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 200 * UINT;
		IFormula(formula).insert(name, uint128(13 * RATE_DECIMALS), uint16(4), uint16(2), uint16(1), true, majors, minors, limits);
	}

	function _initFormula6(bytes32 token) private {
		bytes32 name = "燃油钨钢钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(1), uint16(2), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 300 * UINT;
		IFormula(formula).insert(name, uint128(22 * RATE_DECIMALS), uint16(4), uint16(2), uint16(2), true, majors, minors, limits);
	}

	function _initFormula7(bytes32 token) private {
		bytes32 name = "燃油金刚钻机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](1);
		uint256[] memory limits = new uint256[](1);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(1), uint16(3), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token;
		limits[0] = 800 * UINT;
		IFormula(formula).insert(name, uint128(80 * RATE_DECIMALS), uint16(4), uint16(2), uint16(3), true, majors, minors, limits);
	}

	function _initFormula8(bytes32 token1, bytes32 token2) private {
		bytes32 name = "超级合金镐";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](2);
		uint256[] memory limits = new uint256[](2);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(256), uint16(2), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token1;
		minors[1] = token2;
		limits[0] = 150 * UINT;
		limits[1] = 150 * UINT;
		IFormula(formula).insert(name, uint128(26 * RATE_DECIMALS), uint16(256), uint16(3), uint16(1), true, majors, minors, limits);
	}

	function _initFormula9(bytes32 token1, bytes32 token2) private {
		bytes32 name = "铸铁挖掘机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](2);
		uint256[] memory limits = new uint256[](2);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(1), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token1;
		minors[1] = token2;
		limits[0] = 150 * UINT;
		limits[1] = 150 * UINT;
		IFormula(formula).insert(name, uint128(26 * RATE_DECIMALS), uint16(4), uint16(3), uint16(1), true, majors, minors, limits);
	}

	function _initFormula10(bytes32 token1, bytes32 token2) private {
		bytes32 name = "钨钢挖掘机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](2);
		uint256[] memory limits = new uint256[](2);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(2), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token1;
		minors[1] = token2;
		limits[0] = 230 * UINT;
		limits[1] = 230 * UINT;
		IFormula(formula).insert(name, uint128(44 * RATE_DECIMALS), uint16(4), uint16(3), uint16(2), true, majors, minors, limits);
	}

	function _initFormula11(bytes32 token1, bytes32 token2) private {
		bytes32 name = "金刚挖掘机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](2);
		uint256[] memory limits = new uint256[](2);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(3), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token1;
		minors[1] = token2;
		limits[0] = 800 * UINT;
		limits[1] = 800 * UINT;
		IFormula(formula).insert(name, uint128(180 * RATE_DECIMALS), uint16(4), uint16(3), uint16(3), true, majors, minors, limits);
	}

	function _initFormula12(bytes32 token1, bytes32 token2) private {
		bytes32 name = "蓝翔挖掘机";	
		bytes32[] memory majors = new bytes32[](1);
		bytes32[] memory minors = new bytes32[](2);
		uint256[] memory limits = new uint256[](2);
		bytes memory majorData = abi.encodePacked(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP), uint16(4), uint16(2), uint16(3), bytes6(0)); 
		majors[0] = abi.decode(majorData, (bytes32));
		minors[0] = token1;
		minors[1] = token2;
		limits[0] = 900 * UINT;
		limits[1] = 900 * UINT;
		IFormula(formula).insert(name, uint128(220 * RATE_DECIMALS), uint16(4), uint16(3), uint16(3), true, majors, minors, limits);
	}
}
