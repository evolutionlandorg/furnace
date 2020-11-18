pragma solidity ^0.6.7;

import "ds-auth/auth.sol";

contract Formula is DSAuth {
    event AddFormula(
        uint256 indexed index,
        string name,
        uint16 class,
        uint16 grade,
        uint16 prefer,
        bool canDisenchant,
        uint16 majorIndex,
        address[] tokens,
        uint256[] mins,
        uint256[] maxs
    );
    event RemoveFormula(uint256 indexed index);

    struct FormulaBase {
        // Item parameter
        // name is needed?
        string name;
        uint16 class;
        uint16 grade;
        uint16 prefer;
        bool canDisenchant;
        // if it is removed
        bool disable;
        // major meterail of the Formula index
        uint16 majorIndex;
        // minor meterail info
        address[] tokens;
        uint256[] mins;
        uint256[] maxs;
        // uint256 smeltTime;
        // uint256 disenchantTime;
        // uint256 loseRate;
    }

    FormulaBase[] public formulas;

    function add(
        string memory _name,
        uint16 _class,
        uint16 _grade,
        uint16 _prefer,
        bool _canDisenchant,
        uint16 _majorIndex,
        address[] memory _tokens,
        uint256[] memory _mins,
        uint256[] memory _maxs
    ) public auth {
        require(_tokens.length == _mins.length, "length invalid");
        require(_mins.length == _maxs.length, "length invalid");
        FormulaBase memory formula = FormulaBase({
            name: _name,
            class: _class,
            grade: _grade,
            prefer: _prefer,
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
            formula.prefer,
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
            uint16 prefer,
            bool canDisenchant,
            uint16 majorIndex,
            address[] memory tokens,
            uint256[] memory mins,
            uint256[] memory maxs
        )
    {
        require(index < formulas.length, "Formula: out of range");
        FormulaBase memory formula = formulas[index];
        return (
            formula.name,
            formula.class,
            formula.grade,
            formula.prefer,
            formula.canDisenchant,
            formula.majorIndex,
            formula.tokens,
            formula.mins,
            formula.maxs
        );
    }
}
