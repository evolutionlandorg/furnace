pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./Furnance.sol";

contract FurnanceTest is DSTest {
    Furnance furnance;

    function setUp() public {
        furnance = new Furnance();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
