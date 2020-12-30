// hevm: flattened sources of src/ItemBase.sol
pragma solidity >0.4.13 >=0.4.23 >=0.4.24 <0.7.0 >=0.6.7 <0.7.0;

////// lib/ds-auth/src/auth.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.4.23; */

interface DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// lib/ds-stop/lib/ds-note/src/note.sol
/// note.sol -- the `note' modifier, for logging calls as events

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.4.23; */

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }

        _;

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);
    }
}

////// lib/ds-stop/src/stop.sol
/// stop.sol -- mixin for enable/disable functionality

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.4.23; */

/* import "ds-auth/auth.sol"; */
/* import "ds-note/note.sol"; */

contract DSStop is DSNote, DSAuth {
    bool public stopped;

    modifier stoppable {
        require(!stopped, "ds-stop-is-stopped");
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

////// lib/zeppelin-solidity/src/proxy/Initializable.sol
// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
/* pragma solidity >=0.4.24 <0.7.0; */


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

////// src/common/UQ128x128.sol
/* pragma solidity ^0.6.7; */

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**128 - 1]
// resolution: 1 / 2**128

library UQ128x128 {
    uint8 public constant RESOLUTION = 128;
    uint256 public constant Q128 = 2**128;

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
        require(y != 0, "UQ128x128: DIV_BY_ZERO");
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

////// src/interfaces/IELIP002.sol
/* pragma solidity ^0.6.7; */

/**
@title IELIP002
@dev See https://github.com/evolutionlandorg/furnace/blob/main/elip-002.md
@author echo.hu@itering.com
*/
interface IELIP002 {
	struct Item {
		// index of `Formula`
		uint256 index;
		// base strength rate
		uint128 base;
		// enhance strength rate
		uint128 enhance;
		// rate of enhance
		uint128 rate;
		// extension of `ObjectClass`
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		// element prefer
		uint16 prefer;
		// ids of major material
		uint256[] ids;
		// addresses of major material
		address[] tokens;
		// amounts of minor material
		uint256[] amounts;
	}

	/**
        @dev `Enchanted` MUST emit when item is enchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the enchant (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is enchanted.
        The `index` argument MUST be index of the `Formula`.
        The `base` argument MUST be base strength rate of the item.
        The `enhance` argument MUST be enhance strength rate of the item.
        The `rate` argument MUST be rate of minor material.
        The `objClassExt` argument MUST be extension of `ObjectClass`.
        The `class` argument MUST be class of the item.
        The `grade` argument MUST be grade of the item.
        The `prefer` argument MUST be prefer of the item.
        The `ids` argument MUST be token ids of major material.
        The `tokens` argument MUST be token addresses of minor material.
        The `amounts` argument MUST be token amounts of minor material.
        The `now` argument MUST be timestamp of enchant.
    */
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint128 base,
		uint128 enhance,
		uint128 rate,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		uint256[] ids,
		address[] tokens,
		uint256[] amounts,
		uint256 now
	);

	/**
        @dev `Disenchanted` MUST emit when item is disenchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the disenchanted (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is disenchated.
        The `majors` argument MUST be major token addresses of major material.
        The `ids` argument MUST be token ids of major material.
        The `minors` argument MUST be token addresses of minor material.
        The `amounts` argument MUST be token amounts of minor material.
    */
	event Disenchanted(
		address indexed user,
		uint256 tokenId,
		address[] majors,
		uint256[] ids,
		address[] minors,
		uint256[] amounts
	);

	/**
        @notice Caller must be owner of tokens to enchant.
        @dev Enchant function, Enchant a new NFT token from ERC721 tokens and ERC20 tokens. Enchant rule is according to `Formula`.
        MUST revert if `_index` is not in `formula`.
        MUST revert if length of `_ids` is not the same as length of `formula` index rules.
        MUST revert if length of `_values` is not the same as length of `formula` index rules.
        MUST revert on any other error.        
        @param _ids     IDs of NFT tokens(order and length must match `formula` index rules).
        @param _tokens  Addresses of FT tokens(order and length must match `formula` index rules).
        @param _values  Amounts of FT tokens(order and length must match `formula` index rules).
		@return {
			"tokenId": "New Token ID of Enchanting."
		}
    */
	function enchant(
		uint256 _index,
		uint256[] calldata _ids,
		address[] calldata _tokens,
		uint256[] calldata _values
	) external returns (uint256);

	// {
	// 	### smelt
	// 	1. check Formula rule by index
	//  2. transfer FTs and NFTs to address(this)
	// 	3. track FTs NFTs to new NFT
	// 	4. mint new NFT to caller
	// }

	/**
        @notice Caller must be owner of token id to disenchat.
        @dev Disenchant function, A enchanted NFT can be disenchanted into origin ERC721 tokens and ERC20 tokens recursively.
        MUST revert on any other error.        
        @param _ids     Token IDs to disenchant.
        @param _depth   Depth of disenchanting recursively.
    */
	function disenchant(uint256 _ids, uint256 _depth) external;

	// {
	// 	### disenchant
	//  1. tranfer _id to address(this)
	// 	2. burn new NFT
	// 	3. delete track FTs NFTs to new NFT
	// 	4. transfer FNs NFTs to owner
	// }

	/**
        @dev Get base info of item.
        @param _tokenId Token id of item.
		@return {
			"objClassExt": "Extension of `ObjectClass`.",
			"class": "Class of the item.",
			"grade": "Grade of the item."
		}
    */
	function getBaseInfo(uint256 _tokenId)
		external
		view
		returns (
			uint16,
			uint16,
			uint16
		);

	/**
        @dev Get rate of item.
        @param _tokenId Token id of item.
        @param _element Element item prefer.
		@return {
			"rate": "strength rate of item."
		}
    */
	function getRate(uint256 _tokenId, uint256 _element)
		external
		view
		returns (uint256);

	function getObjectClassExt(uint256 _tokenId) 
		external	
		view
		returns (uint16);
}

////// src/interfaces/IFormula.sol
/* pragma solidity ^0.6.7; */

/**
@title IFormula
@author echo.hu@itering.com
*/
interface IFormula {
	struct FormulaEntry {
		// item name
		bytes32 name;
		// base strength rate
		uint128 base;
		// enhance strength rate
		uint128 enhance;
		// extension of `ObjectClass`
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		bool canDisenchant;
		// if it is removed
		// uint256 enchantTime;
		// uint256 disenchantTime;
		// uint256 loseRate;

		// major material info
		// [address token, uint16 objectClassExt, uint16 class, uint16 grade]
		bytes32[] majors;
		// minor material info
		bytes32[] minors;
		// [uint128 min, uint128 max]
		uint256[] limits;
		bool disable;
	}

	event AddFormula(
		uint256 indexed index,
		bytes32 name,
		uint128 base,
		uint128 enhance,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		bool canDisenchant,
		bytes32[] majors,
		bytes32[] minors,
		uint256[] limits
	);
	event DisableFormula(uint256 indexed index);
	event EnableFormula(uint256 indexed index);

	/**
        @notice Only governance can add `formula`.
        @dev Add a formula rule.
        MUST revert if length of `_majors` is not the same as length of `_class`.
        MUST revert if length of `_minors` is not the same as length of `_mins` and `_maxs.
        MUST revert on any other error.        
        @param _name     New enchanted NFT name.
        @param _majors   FT token addresses of major meterail for enchanting.
        @param _minors   FT Token addresses of minor meterail for enchanting.
        @param _limits   FT Token limits of minor meterail for enchanting.
    */
	function insert(
		bytes32 _name,
		uint128 _base,
		uint128 _enhance,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32[] calldata _majors,
		bytes32[] calldata _minors,
		uint256[] calldata _limits
	) external;

	/**
        @notice Only governance can enable `formula`.
        @dev Enable a formula rule.
        MUST revert on any other error.        
        @param _index  index of formula.
    */
	function disable(uint256 _index) external;

	/**
        @notice Only governance can disble `formula`.
        @dev Disble a formula rule.
        MUST revert on any other error.        
        @param _index  index of formula.
    */
	function enable(uint256 _index) external;

	/**
        @dev Returns the length of the formula.
	         0x1f7b6d32
     */
	function length() external view returns (uint256);

	/**
        @dev Returns the availability of the formula.
     */
	function isDisable(uint256 _index) external view returns (bool);

	/**
        @dev returns the major material of the formula.
     */
	function getMajors(uint256 _index) external view returns (bytes32[] memory);

	/**
        @dev returns the minor material of the formula.
     */
	function getMinors(uint256 _index)
		external
		view
		returns (bytes32[] memory, uint256[] memory);

	/**
        @dev Decode major info of the major.
	         0x6ef2fd27
		@return {
			"token": "Major token address.",
			"objClassExt": "Major token objClassExt.",
			"class": "Major token class.",
			"grade": "Major token address."
		}
     */
	function getMajorInfo(bytes32 _major)
		external
		pure
		returns (
			address,
			uint16,
			uint16,
			uint16
		);

	/**
        @dev Decode major info of limit.
	         0x827d6320
		@return {
			"min": "Min amount of minor material.",
			"max": "Max amount of minor material."

		}
     */
	function getLimit(uint256 _limit) external pure returns (uint128, uint128);

	/**
        @dev Returns meta info of the item.
	         0x78533046
		@return {
			"objClassExt": "Major token objClassExt.",
			"class": "Major token class.",
			"grade": "Major token address.",
			"base":  "Base strength rate.",
			"enhance": "Enhance strength rate.",
		}
     */
	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint128,
			uint128
		);

	/**
        @dev returns the minor addresses of the formula.
		     0x762b8a4d
     */
	function getMajorAddresses(uint256 _index)
		external
		view
		returns (address[] memory);

	/**
        @dev returns canDisenchant of the formula.
     */
	function getDisenchant(uint256 _index) external view returns (bool);
}

////// src/interfaces/IMetaDataTeller.sol
/* pragma solidity ^0.6.7; */

interface IMetaDataTeller {
	function addTokenMeta(
		address _token,
		uint16 _grade,
		uint112 _strengthRate
	) external;

	function getObjClassExt(address _token, uint256 _id) external view returns (uint16 objClassExt);

	//0xf666196d
	function getMetaData(address _token, uint256 _id)
		external
		view
		returns (uint16, uint16, uint16);

    //0x7999a5cf
	function getPrefer(address _token) external view returns (uint256);

	//0x33281815
	function getRate(
		address _token,
		uint256 _id,
		uint256 _index
	) external view returns (uint256);

	//0xf8350ed0
	function isAllowed(address _token, uint256 _id) external view returns (bool);
}

////// src/interfaces/IObjectOwnership.sol
/* pragma solidity ^0.6.7; */

interface IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) external returns (uint256 _tokenId);
	
    function burn(address _to, uint256 _tokenId) external;
}

////// src/interfaces/ISettingsRegistry.sol
/* pragma solidity ^0.6.7; */

interface ISettingsRegistry {
    function addressOf(bytes32 _propertyName) external view returns (address);

    function bytesOf(bytes32 _propertyName) external view returns (bytes memory);

    function boolOf(bytes32 _propertyName) external view returns (bool);

    function intOf(bytes32 _propertyName) external view returns (int);

    function setUintProperty(bytes32 _propertyName, uint _value) external;

    function setStringProperty(bytes32 _propertyName, string calldata _value) external;

    function setAddressProperty(bytes32 _propertyName, address _value) external;

    function setBytesProperty(bytes32 _propertyName, bytes calldata _value) external;

    function setBoolProperty(bytes32 _propertyName, bool _value) external;

    function setIntProperty(bytes32 _propertyName, int _value) external;

    function getValueTypeOf(bytes32 _propertyName) external view returns (uint /* SettingsValueTypes */ );

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}

////// src/ItemBase.sol
/* pragma solidity ^0.6.7; */

/* import "ds-math/math.sol"; */
/* import "ds-stop/stop.sol"; */
/* import "zeppelin-solidity/proxy/Initializable.sol"; */
/* import "./interfaces/IELIP002.sol"; */
/* import "./interfaces/IFormula.sol"; */
/* import "./interfaces/ISettingsRegistry.sol"; */
/* import "./interfaces/IMetaDataTeller.sol"; */
/* import "./interfaces/IObjectOwnership.sol"; */
/* import "./common/UQ128x128.sol"; */

contract ItemBase is Initializable, DSStop, DSMath, IELIP002 {
	using UQ128x128 for uint256;

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f464f524d554c4100000000000000000000000000000000
	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	//0x434f4e54524143545f4c505f454c454d454e545f544f4b454e00000000000000
	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN =
		"CONTRACT_LP_ELEMENT_TOKEN";

	//0x434f4e54524143545f454c454d454e545f544f4b454e00000000000000000000
	bytes32 public constant CONTRACT_ELEMENT_TOKEN = "CONTRACT_ELEMENT_TOKEN";

	// rate precision
	uint128 public constant RATE_PRECISION = 10**8;
	// save about 200 gas when contract create
	bytes4 private constant _SELECTOR =
		bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

	/*** STORAGE ***/

	uint128 public lastItemObjectId;
	ISettingsRegistry public registry;
	mapping(uint256 => Item) public tokenId2Item;

	// mapping(uint256 => mapping(uint256 => uint256)) public tokenId2Rate;

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		// trick test
		lastItemObjectId = 1000;
	}

	function _safeTransfer(
		address token,
		address from,
		address to,
		uint256 value
	) private {
		(bool success, bytes memory data) =
			token.call(abi.encodeWithSelector(_SELECTOR, from, to, value)); // solhint-disable-line
		require(
			success && (data.length == 0 || abi.decode(data, (bool))),
			"Furnace: TRANSFER_FAILED"
		);
	}

	function enchant(
		uint256 _index,
		uint256[] calldata _ids,
		address[] calldata _tokens,
		uint256[] calldata _values
	) external override stoppable returns (uint256) {
		_dealMajor(_index, _ids);
		(uint16 prefer, uint128 rate, uint256[] memory amounts) =
			_dealMinor(_index, _tokens, _values);
		return _enchanceItem(_index, prefer, rate, _ids, _tokens, amounts);
	}

	function _dealMajor(uint256 _index, uint256[] memory _ids) private {
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		address formula = registry.addressOf(CONTRACT_FORMULA);
		require(
			IFormula(formula).isDisable(_index) == false,
			"Furnace: FORMULA_DISABLE"
		);
		bytes32[] memory majors = IFormula(formula).getMajors(_index);
		require(_ids.length == majors.length, "Furnace: INVALID_LENGTH");
		for (uint256 i = 0; i < majors.length; i++) {
			bytes32 major = majors[i];
			uint256 id = _ids[i];
			(
				address majorAddress,
				uint16 majorObjClassExt,
				uint16 majorClass,
				uint16 majorGrade
			) = IFormula(formula).getMajorInfo(major);
			(uint16 objectClassExt, uint16 class, uint16 grade) =
				IMetaDataTeller(teller).getMetaData(majorAddress, id);
			require(
				objectClassExt == majorObjClassExt,
				"Furnace: INVALID_OBJECTCLASSEXT"
			);
			require(class == majorClass, "Furnace: INVALID_CLASS");
			require(grade == majorGrade, "Furnace: INVALID_GRADE");
			_safeTransfer(majorAddress, msg.sender, address(this), id);
		}
	}

	function _dealMinor(
		uint256 _index,
		address[] memory _tokens,
		uint256[] memory _values
	)
		private
		returns (
			uint16,
			uint128,
			uint256[] memory
		)
	{
		address formula = registry.addressOf(CONTRACT_FORMULA);
		address teller = registry.addressOf(CONTRACT_METADATA_TELLER);
		(bytes32[] memory minors, uint256[] memory limits) =
			IFormula(formula).getMinors(_index);
		require(
			_tokens.length == minors.length && _values.length == minors.length,
			"Furnace: INVALID_VALUES_LENGTH."
		);
		uint16 prefer;
		//TODO: check rate calculate.
		uint128 rate = RATE_PRECISION;
		uint256[] memory amounts = new uint256[](minors.length);
		for (uint256 i = 0; i < minors.length; i++) {
			address minorAddress = _tokens[i];
			uint256 value = _values[i];
			(uint128 minorMin, uint128 minorMax) =
				IFormula(formula).getLimit(limits[i]);
			require(minorMax > minorMin, "Furnace: INVALID_LIMIT");
			uint256 element = IMetaDataTeller(teller).getPrefer(minorAddress);
			_checkMinorAddress(element, minors[i], minorAddress);
			prefer |= uint16(1 << element);
			require(value >= minorMin, "Furnace: VALUE_INSUFFICIENT");
			require(value <= uint128(-1), "Furnace: VALUE_OVERFLOW");
			uint128 numerator;
			uint128 denominator;
			if (value > minorMax) {
				numerator = minorMax - minorMin;
				_safeTransfer(
					minorAddress,
					msg.sender,
					address(this),
					minorMax
				);
				amounts[i] = minorMax;
			} else {
				numerator = uint128(value) - minorMin;
				_safeTransfer(minorAddress, msg.sender, address(this), value);
				amounts[i] = value;
			}
			denominator = minorMax - minorMin;
			uint128 enhanceRate =
				UQ128x128
					.encode(numerator)
					.uqdiv(denominator)
					.uqmul(RATE_PRECISION)
					.decode();
			rate = UQ128x128.mul128(rate, enhanceRate) / RATE_PRECISION;
		}
		return (prefer, rate, amounts);
	}

	function _checkMinorAddress(
		uint256 element,
		bytes32 minor,
		address minorAddress
	) internal view {
		if (element > 0) {
			require(
				minor == CONTRACT_ELEMENT_TOKEN ||
					minor == CONTRACT_LP_ELEMENT_TOKEN,
				"Funace: INVALID_TOKEN"
			);
		} else {
			require(
				minorAddress == registry.addressOf(minor),
				"Furnace: INVALID_TOKEN"
			);
		}
	}

	function _enchanceItem(
		uint256 _index,
		uint16 _prefer,
		uint128 _rate,
		uint256[] memory _ids,
		address[] memory _tokens,
		uint256[] memory _amounts
	) private returns (uint256) {
		lastItemObjectId += 1;
		require(lastItemObjectId <= uint128(-1), "Furnace: OBJECTID_OVERFLOW");

		(
			uint16 objClassExt,
			uint16 class,
			uint16 grade,
			uint128 base,
			uint128 enhance
		) = IFormula(registry.addressOf(CONTRACT_FORMULA)).getMetaInfo(_index);

		Item memory item =
			Item({
				index: _index,
				base: base,
				enhance: enhance,
				rate: _rate,
				objClassExt: objClassExt,
				class: class,
				grade: grade,
				prefer: _prefer,
				ids: _ids,
				tokens: _tokens,
				amounts: _amounts
			});
		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(msg.sender, lastItemObjectId);
		tokenId2Item[tokenId] = item;
		emit Enchanced(
			msg.sender,
			tokenId,
			item.index,
			item.base,
			item.enhance,
			item.rate,
			item.objClassExt,
			item.class,
			item.grade,
			item.prefer,
			item.ids,
			item.tokens,
			item.amounts,
			now // solhint-disable-line
		);
		return tokenId;
	}

	function _disenchantItem(address to, uint256 tokenId) private {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			to,
			tokenId
		);
	}

	function disenchant(uint256 _id, uint256 _depth)
		external
		override
		stoppable
	{
		_safeTransfer(
			registry.addressOf(CONTRACT_OBJECT_OWNERSHIP),
			msg.sender,
			address(this),
			_id
		);
		_disenchant(_id, _depth);
	}

	function _disenchant(uint256 _tokenId, uint256 _depth)
		private
		returns (uint256)
	{
		(
			uint16 class,
			bool canDisenchant,
			address[] memory majors,
			uint256[] memory ids,
			address[] memory minors,
			uint256[] memory amounts
		) = getEnchantedInfo(_tokenId);
		require(_depth > 0, "Furnace: INVALID_DEPTH");
		require(canDisenchant == true, "Furnace: DISENCHANT_DISABLE");
		require(class > 0, "Furnace: INVALID_CLASS");
		require(ids.length == majors.length, "Furnace: INVALID_MAJORS_LENGTH.");
		require(
			amounts.length == minors.length,
			"Furnace: INVALID_MINORS_LENGTH."
		);
		_disenchantItem(address(this), _tokenId);
		for (uint256 i = 0; i < majors.length; i++) {
			address major = majors[i];
			uint256 id = ids[i];
			if (_depth == 1 || class == 0) {
				_safeTransfer(major, address(this), msg.sender, id);
			} else {
				_disenchant(id, _depth - 1);
			}
		}
		for (uint256 i = 0; i < minors.length; i++) {
			address minor = minors[i];
			uint256 amount = amounts[i];
			_safeTransfer(minor, address(this), msg.sender, amount);
		}
		emit Disenchanted(msg.sender, _tokenId, majors, ids, minors, amounts);
	}

	function getRate(uint256 _tokenId, uint256 _element)
		public
		view
		override
		returns (uint256)
	{
		Item storage item = tokenId2Item[_tokenId];
		if (uint256(item.prefer) & (1 << _element) > 0) {
			uint128 realEnhanceRate =
				item.base +
					UQ128x128.mul128(item.rate, item.enhance) /
					RATE_PRECISION;
			return uint256(realEnhanceRate);
		}
		return uint256(item.base / 2);
	}

	function getBaseInfo(uint256 _tokenId)
		public
		view
		override
		returns (
			uint16,
			uint16,
			uint16
		)
	{
		Item storage item = tokenId2Item[_tokenId];
		return (item.objClassExt, item.class, item.grade);
	}

	function getObjectClassExt(uint256 _tokenId) 
		public
		view
		override
		returns (uint16)
	{
		return tokenId2Item[_tokenId].objClassExt;
	}

	function getEnchantedInfo(uint256 _tokenId)
		public
		view
		returns (
			uint16,
			bool,
			address[] memory,
			uint256[] memory,
			address[] memory,
			uint256[] memory
		)
	{
		Item storage item = tokenId2Item[_tokenId];
		address formula = registry.addressOf(CONTRACT_FORMULA);
		return (
			item.class,
			IFormula(formula).getDisenchant(item.index),
			IFormula(formula).getMajorAddresses(item.index),
			item.ids,
			item.tokens,
			item.amounts
		);
	}
}

