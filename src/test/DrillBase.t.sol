pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "../DrillBase.sol";

contract DrillBaseTest is DSTest {
    DrillBase item;

    function setUp() public {
        item = new DrillBase();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
