pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "../common/UQ112x112.sol";

contract UQ112x112Test is DSTest {
    using UQ112x112 for uint224;

    function setUp() public {
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_uqdiv() public {
		uint112 DECIMALS = 10**8;
        assertEq(uint256(UQ112x112.encode(4).uqdiv(2).decode()), 2);
        assertEq(uint256(UQ112x112.encode(5).uqdiv(2).decode()), 2);
        assertEq(uint256(UQ112x112.encode(2).uqdiv(3).decode()), 0);
        assertEq(uint256(UQ112x112.encode(5).mul(100).uqdiv(2).decode()), 250);
		uint112 x = UQ112x112.encode(1).uqdiv(3).mul(DECIMALS).decode();
		uint112 y = UQ112x112.encode(2).uqdiv(3).mul(DECIMALS).decode();
		assertEq(uint256(x), 33333333);
		assertEq(uint256(y), 66666666);
		assertEq(uint256(x * y / DECIMALS), 22222221);
    }

}
