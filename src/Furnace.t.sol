pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./Furnace.sol";

contract FurnaceTest is DSTest {
    Furnace furnace;

    function setUp() public {
        furnace = new Furnace();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
