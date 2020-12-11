pragma solidity ^0.6.7;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**128 - 1]
// resolution: 1 / 2**128

library UQ128x128 {
    uint8 constant RESOLUTION = 128;
    uint256 constant Q128 = 2**128;

    // encode a uint128 as a UQ128x128
    function encode(uint128 y) internal pure returns (uint256 z) {
        z = uint256(y) * Q128; // never overflows
    }

    // decode a UQ128x128 into a uint128 by truncating after the radix point
    function decode(uint256 x) internal pure returns (uint128) {
        return uint128(x >> RESOLUTION);
    }

    // divide a UQ128x128 by a uint128, returning a UQ128x128
    function uqdiv(uint256 x, uint128 y) internal pure returns (uint256 z) {
        require(y != 0, 'UQ128x128: DIV_BY_ZERO');
        z = x / uint256(y);
    }

    // multiply a UQ128x128 by a uint128, returning a UQ128x128
    // reverts on overflow
    function uqmul(uint256 x, uint128 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * uint256(y)) / uint256(y) == x, "UQ128x128: MULTIPLICATION_OVERFLOW");
    }

	function mul128(uint128 a, uint128 b) internal pure returns (uint128) {
		if (a == 0) {
			return 0;
		}

		uint128 c = a * b;
		require(c / a == b, "UQ128x128: MULTIPLICATION128_OVERFLOW");

		return c;
	}
}
