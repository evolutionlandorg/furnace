pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./ItemBase.sol";

contract ItemBaseTest is DSTest {
    ItemBase item;

    function setUp() public {
        item = new ItemBase();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
