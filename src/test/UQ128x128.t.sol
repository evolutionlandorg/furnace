pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "../common/UQ128x128.sol";

contract UQ128x128Test is DSTest {
    using UQ128x128 for uint256;

    function setUp() public {
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_uqdiv() public {
		uint128 DECIMALS = 10**8;
        assertEq(uint256(UQ128x128.encode(4).uqdiv(2).decode()), 2);
        assertEq(uint256(UQ128x128.encode(5).uqdiv(2).decode()), 2);
        assertEq(uint256(UQ128x128.encode(2).uqdiv(3).decode()), 0);
        assertEq(uint256(UQ128x128.encode(5).uqmul(100).uqdiv(2).decode()), 250);
		uint128 x = UQ128x128.encode(1).uqdiv(3).uqmul(DECIMALS).decode();
		uint128 y = UQ128x128.encode(2).uqdiv(3).uqmul(DECIMALS).decode();
		assertEq(uint256(x), 33333333);
		assertEq(uint256(y), 66666666);
		assertEq(uint256(x * y / DECIMALS), 22222221);
    }

}
