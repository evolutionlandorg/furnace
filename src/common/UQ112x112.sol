pragma solidity ^0.6.7;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint8 constant RESOLUTION = 112;
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uint224 x) internal pure returns (uint112) {
        return uint112(x >> RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        require(y != 0, 'UQ112x112: DIV_BY_ZERO');
        z = x / uint224(y);
    }

    // multiply a UQ112x112 by a uint112, returning a UQ112x112
    // reverts on overflow
    function mul(uint224 x, uint112 y) internal pure returns (uint224 z) {
        require(y == 0 || (z = x * uint224(y)) / uint224(y) == x, "UQ112x112: MULTIPLICATION_OVERFLOW");
    }
}
