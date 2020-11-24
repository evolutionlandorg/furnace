pragma solidity ^0.6.7;
 
import "zeppelin-solidity/proxy/Initializable.sol";
import "ds-auth/auth.sol";
import "./FurnaceSettingIds.sol";

contract Formula is Initializable, DSAuth, FurnaceSettingIds {
    event AddFormula(
        uint256 indexed index,
        string name,
        uint16 class,
        uint16 grade,
        bool canDisenchant,
        uint16[] majorIndex,
        bytes32[] tokens,
        uint256[] mins,
        uint256[] maxs
    );
    event RemoveFormula(uint256 indexed index);
	event SetFurnaceStrength(uint256 indexed objectClass, uint256 indexed formulaIndex, uint256 base, uint256 enhance);
    struct FormulaEntry {
        // Item parameter
        // name is needed?
        string name;
        uint16 class;
        uint16 grade;
        bool canDisenchant;
        // if it is removed
        bool disable;
        // major meterail of the Formula index
        uint16[] majorIndex;
        // minor meterail info
        bytes32[] tokens;
        uint256[] mins;
        uint256[] maxs;
        // uint256 smeltTime;
        // uint256 disenchantTime;
        // uint256 loseRate;
    }

	struct Strength {
		uint256 base;
		uint256 enhance;
	}

    FormulaEntry[] public formulas;
	mapping(bytes32 => Strength) public strengths;

    function initialize() public initializer {
        FormulaEntry memory f0 = FormulaEntry({
            name: "",
            class: 0,
            grade: 0,
            canDisenchant: false,
            disable: true,
            majorIndex: new uint16[](0),
            tokens: new bytes32[](0),
            mins: new uint256[](0),
            maxs: new uint256[](0)
        });
        formulas.push(f0);
		// setFurnaceStrength(0, 0, 0);
        FormulaEntry memory f1 = FormulaEntry({
            name: "普通GEGO镐",
            class: 0,
            grade: 1,
            canDisenchant: false,
            disable: false,
            majorIndex: new uint16[](0),
            tokens: new bytes32[](0),
            mins: new uint256[](0),
            maxs: new uint256[](0)
        });
        formulas.push(f1);
		// setFurnaceStrength(1, 100, 0);
        FormulaEntry memory f2 = FormulaEntry({
            name: "铸铁钻头",
            class: 0,
            grade: 1,
            canDisenchant: false,
            disable: false,
            majorIndex: new uint16[](0),
            tokens: new bytes32[](0),
            mins: new uint256[](0),
            maxs: new uint256[](0)
        });
        formulas.push(f2);
		// setFurnaceStrength(2, 150, 0);
        FormulaEntry memory f3 = FormulaEntry({
            name: "钨钢钻头",
            class: 0,
            grade: 2,
            canDisenchant: false,
            disable: false,
            majorIndex: new uint16[](0),
            tokens: new bytes32[](0),
            mins: new uint256[](0),
            maxs: new uint256[](0)
        });
        formulas.push(f3);
		// setFurnaceStrength(3, 200, 0);
        FormulaEntry memory f4 = FormulaEntry({
            name: "金刚钻头",
            class: 0,
            grade: 3,
            canDisenchant: false,
            disable: false,
            majorIndex: new uint16[](0),
            tokens: new bytes32[](0),
            mins: new uint256[](0),
            maxs: new uint256[](0)
        });
        formulas.push(f4);
		// setFurnaceStrength(4, 300, 0);
    }

    function add(
        string memory _name,
        uint16 _class,
        uint16 _grade,
        bool _canDisenchant,
        uint16[] memory _majorIndex,
        bytes32[] memory _tokens,
        uint256[] memory _mins,
        uint256[] memory _maxs
    ) public auth returns (bool) {
		require(formulas.length < 65536, "formula is full.");
		require(_majorIndex.length > 0, "Major length invalid");
        require(_tokens.length == _mins.length, "Token length invalid");
        require(_mins.length == _maxs.length, "length invalid");
        FormulaEntry memory formula = FormulaEntry({
            name: _name,
            class: _class,
            grade: _grade,
            canDisenchant: _canDisenchant,
            disable: false,
            majorIndex: _majorIndex,
            tokens: _tokens,
            mins: _mins,
            maxs: _maxs
        });
        formulas.push(formula);
        emit AddFormula(
            formulas.length - 1,
            formula.name,
            formula.class,
            formula.grade,
            formula.canDisenchant,
            formula.majorIndex,
            formula.tokens,
            formula.mins,
            formula.maxs
        );
    }

    function remove(uint256 index) public auth {
        require(index < formulas.length, "Formula: out of range");
        formulas[index].disable = true;
        emit RemoveFormula(index);
    }

    function length() public view returns (uint256) {
        return formulas.length;
    }

    function at(uint256 index)
        public
        view
        returns (
            string memory name,
            uint16 class,
            uint16 grade,
            bool canDisenchant,
            uint16[] memory majorIndex,
            bytes32[] memory tokens,
            uint256[] memory mins,
            uint256[] memory maxs
        )
    {
        require(index < formulas.length, "Formula: out of range");
        FormulaEntry memory formula = formulas[index];
        return (
            formula.name,
            formula.class,
            formula.grade,
            formula.canDisenchant,
            formula.majorIndex,
            formula.tokens,
            formula.mins,
            formula.maxs
        );
    }

	// util to get key based on object class + formula index + appkey 
    function _getKey(
        uint8 _objectClass,
        uint256 _formulaIndex,
        bytes32 _appKey
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_objectClass, _formulaIndex, _appKey));
    }

	function getFurnaceStrength(uint256 _formulaIndex) public view returns(uint256, uint256) {
		bytes32 key = _getKey(ITEM_OBJECT_CLASS, _formulaIndex, FURNACE_APP);
		Strength memory s = strengths[key];
		return (s.base, s.enhance);
	}

	function setFurnaceStrength(uint256 _formulaIndex, uint256 _base, uint256 _enhance) public auth {
		bytes32 key = _getKey(ITEM_OBJECT_CLASS, _formulaIndex, FURNACE_APP);
		Strength memory s = Strength({
			base: _base,
			enhance: _enhance
		});
		strengths[key] = s;
		emit SetFurnaceStrength(ITEM_OBJECT_CLASS, _formulaIndex, _base, _enhance);
	}
}
