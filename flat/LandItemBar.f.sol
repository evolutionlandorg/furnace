// hevm: flattened sources of src/LandItemBar.sol
pragma solidity >0.4.13 >=0.4.23 >=0.4.24 <0.7.0 >=0.6.0 <0.7.0 >=0.6.2 <0.7.0 >=0.6.7 <0.7.0;

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

////// lib/zeppelin-solidity/src/introspection/IERC165.sol
// SPDX-License-Identifier: MIT

/* pragma solidity ^0.6.0; */

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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

////// lib/zeppelin-solidity/src/token/ERC721/IERC721.sol
// SPDX-License-Identifier: MIT

/* pragma solidity ^0.6.2; */

/* import "../../introspection/IERC165.sol"; */

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

////// src/interfaces/ERC721Receiver.sol
/* pragma solidity ^0.6.7; */

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
abstract contract ERC721Receiver {
	/**
	 * @dev Magic value to be returned upon successful reception of an NFT
	 *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
	 *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
	 */
	bytes4 internal constant _ERC721_RECEIVED = 0xf0b9e5ba;

	/**
	 * @notice Handle the receipt of an NFT
	 * @dev The ERC721 smart contract calls this function on the recipient
	 * after a `safetransfer`. This function MAY throw to revert and reject the
	 * transfer. This function MUST use 50,000 gas or less. Return of other
	 * than the magic value MUST result in the transaction being reverted.
	 * Note: the contract address is always the message sender.
	 * @param _from The sending address
	 * @param _tokenId The NFT identifier which is being transfered
	 * @param _data Additional data with no specified format
	 * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
	 */
	function onERC721Received(
		address _from,
		uint256 _tokenId,
		bytes calldata _data
	) external virtual returns (bytes4);
}

////// src/interfaces/IInterstellarEncoder.sol
/* pragma solidity ^0.6.7; */

interface IInterstellarEncoder {
	function registerNewObjectClass(address _objectContract, uint8 objectClass)
		external;

	function encodeTokenId(
		address _tokenAddress,
		uint8 _objectClass,
		uint128 _objectIndex
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForObjectContract(
		address _tokenAddress,
		address _objectContract,
		uint128 _objectId
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForOuterObjectContract(
		address _objectContract,
		address nftAddress,
		address _originNftAddress,
		uint128 _objectId,
		uint16 _producerId,
		uint8 _convertType
	) external view returns (uint256);

	function getContractAddress(uint256 _tokenId)
		external
		view
		returns (address);

	function getObjectId(uint256 _tokenId)
		external
		view
		returns (uint128 _objectId);

	function getObjectClass(uint256 _tokenId) external view returns (uint8);

	function getObjectAddress(uint256 _tokenId) external view returns (address);

	function getProducerId(uint256 _tokenId) external view returns (uint16);

	function getOriginAddress(uint256 _tokenId) external view returns (address);
}

////// src/interfaces/ILandBase.sol
/* pragma solidity ^0.6.7; */

interface ILandBase { 
    function resourceToken2RateAttrId(address _resourceToken) external view returns (uint256);
}

////// src/interfaces/ILandResource.sol
/* pragma solidity ^0.6.7; */

interface ILandResource {

    function updateMinerStrengthWhenStart(uint256 _apostleTokenId) external;

    function updateMinerStrengthWhenStop(uint256 _apostleTokenId) external;

    function updateAllMinerStrengthWhenStart(uint256 _landTokenId) external;

    function updateAllMinerStrengthWhenStop(uint256 _landTokenId) external;

    function landWorkingOn(uint256 _apostleTokenId) external view returns (uint256);
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

////// src/ItemBar.sol
/* pragma solidity ^0.6.7; */

/* import "ds-auth/auth.sol"; */
/* import "ds-math/math.sol"; */
/* import "zeppelin-solidity/token/ERC721/IERC721.sol"; */
/* import "./interfaces/ISettingsRegistry.sol"; */
/* import "./interfaces/IInterstellarEncoder.sol"; */
/* import "./interfaces/ERC721Receiver.sol"; */
/* import "./interfaces/IMetaDataTeller.sol"; */
/* import "./interfaces/ILandBase.sol"; */
/* import "./interfaces/ILandResource.sol"; */

abstract contract ItemBar is DSAuth, DSMath {
	event Equip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);
	event Unequip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f4c414e445f5245534f5552434500000000000000000000
	bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	struct Bar {
		address staker;
		address token;
		uint256 id;
		mapping(address => uint256) rates;
	}

	struct Status {
		address staker;
		uint256 tokenId;
		uint256 index;
	}

	ISettingsRegistry public registry;
	uint256 public maxAmount;
	mapping(uint256 => mapping(uint256 => Bar)) public tokenId2Bars;
	mapping(address => mapping(uint256 => Status)) public itemId2Index;

	IMetaDataTeller public teller;
	address public gold;
	address public wood;
	address public water;
	address public fire;
	address public soil;

	modifier onlyAuth(uint256 _tokenId, uint256 _index) virtual { _; }

	modifier updateMinerStrength(uint256 _tokenId) virtual { _; }

	function isAllowed(
		uint256 _tokenId,
		address _token,
		uint256 _id
	) public view virtual returns (bool);

	constructor(address _registry, uint256 _maxAmount) internal {
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;
	}

	function refresh() public virtual auth {
		teller = IMetaDataTeller(registry.addressOf(CONTRACT_METADATA_TELLER));

		gold = registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		wood = registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		water = registry.addressOf(CONTRACT_WATER_ERC20_TOKEN);
		fire = registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		soil = registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN);
	}

	function getTokenIdByItem(address _item, uint256 _itemId)
		public
		view
		returns (address, uint256)
	{
		return (
			itemId2Index[_item][_itemId].staker,
			itemId2Index[_item][_itemId].tokenId
		);
	}

	function getBarStaker(uint256 _tokenId, uint256 _index)
		public
		view
		returns (address)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN.");
		return tokenId2Bars[_tokenId][_index].staker;
	}

	function getBarItem(uint256 _tokenId, uint256 _index)
		public
		view
		returns (address, uint256)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN.");
		return (
			tokenId2Bars[_tokenId][_index].token,
			tokenId2Bars[_tokenId][_index].id
		);
	}

	function batchEquip(
		uint256 _tokenId,
		uint256[] calldata _indexes,
		address[] calldata _tokens,
		uint256[] calldata _ids
	) external updateMinerStrength(_tokenId) {
		require(
			_indexes.length <= maxAmount &&
				_indexes.length > 0 &&
				_indexes.length == _tokens.length &&
				_indexes.length == _ids.length,
			"Furnace: INVALID_LENGTH."
		);
		for (uint256 i = 0; i < _indexes.length; i++) {
			_equip(_tokenId, _indexes[i], _tokens[i], _ids[i]);
		}
	}

	/**
        @dev Equip function, A NFT can equip to EVO Bar (LandBar or ApostleBar).
        @param _tokenId Token Id which to be quiped.
        @param _index   Index of the Bar.
        @param _token   Token address which to quip.
        @param _id      Token Id which to quip.
    */
	function equip(
		uint256 _tokenId,
		uint256 _index,
		address _token,
		uint256 _id
	) public updateMinerStrength(_tokenId) {
		_equip(_tokenId, _index, _token, _id);
	}

	function _equip(
		uint256 _tokenId,
		uint256 _index,
		address _token,
		uint256 _id
	) internal onlyAuth(_tokenId, _index) {
		require(isAllowed(_tokenId, _token, _id), "Furnace: PERMISSION");
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token != address(0)) {
			(, uint16 class, ) = teller.getMetaData(_token, _id);

			(, uint16 originClass, ) = teller.getMetaData(bar.token, bar.id);
			require(class > originClass, "Furnace: INVALID_CLASS");
			IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		}
		IERC721(_token).transferFrom(msg.sender, address(this), _id);

		bar.staker = msg.sender;
		bar.token = _token;
		bar.id = _id;
		bar.rates[gold] = teller.getRate(bar.token, bar.id, 1);
		bar.rates[wood] = teller.getRate(bar.token, bar.id, 2);
		bar.rates[water] = teller.getRate(bar.token, bar.id, 3);
		bar.rates[fire] = teller.getRate(bar.token, bar.id, 4);
		bar.rates[soil] = teller.getRate(bar.token, bar.id, 5);
		itemId2Index[bar.token][bar.id] = Status({
			staker: bar.staker,
			tokenId: _tokenId,
			index: _index
		});
		emit Equip(_tokenId, _index, bar.staker, bar.token, bar.id);
	}

	function batchUnquip(uint256 _tokenId, uint256[] calldata _indexes)
		external
		updateMinerStrength(_tokenId)
	{
		require(
			_indexes.length <= maxAmount && _indexes.length > 0,
			"Furnace: INVALID_LENGTH"
		);
		for (uint256 i = 0; i < _indexes.length; i++) {
			_unequip(_tokenId, _indexes[i]);
		}
	}

	/**
        @dev Unequip function, A NFT can unequip from EVO Bar (LandBar or ApostleBar).
        @param _tokenId Token Id which to be unquiped.
        @param _index   Index of the Bar.
    */
	function unequip(uint256 _tokenId, uint256 _index)
		public
		updateMinerStrength(_tokenId)
	{
		_unequip(_tokenId, _index);
	}

	function _unequip(uint256 _tokenId, uint256 _index) internal {
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		require(bar.token != address(0), "Furnace: EMPTY");
		require(bar.staker == msg.sender, "Furnace: FORBIDDEN");
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit Unequip(_tokenId, _index, bar.staker, bar.token, bar.id);
		//TODO: check
		delete bar.rates[gold];
		delete bar.rates[wood];
		delete bar.rates[water];
		delete bar.rates[fire];
		delete bar.rates[soil];
		delete itemId2Index[bar.token][bar.id];
		delete tokenId2Bars[_tokenId][_index];
	}

	function setMaxAmount(uint256 _maxAmount) public auth {
		require(_maxAmount > maxAmount, "Furnace: INVALID_MAXAMOUNT");
		maxAmount = _maxAmount;
	}

	function enhanceStrengthRateByIndex(
		address _resource,
		uint256 _tokenId,
		uint256 _index
	) external view returns (uint256) {
		Bar storage bar = tokenId2Bars[_tokenId][_index];
		if (bar.token == address(0)) {
			return 0;
		}
		return bar.rates[_resource];
	}

	function enhanceStrengthRateOf(address _resource, uint256 _tokenId)
		external
		view
		returns (uint256)
	{
		uint256 rate;
		for (uint256 i = 0; i < maxAmount; i++) {
			Bar storage bar = tokenId2Bars[_tokenId][i];
			if (bar.token == address(0)) {
				continue;
			}
			rate = add(rate, bar.rates[_resource]);
		}
		return rate;
	}
}

////// src/LandItemBar.sol
/* pragma solidity ^0.6.7; */

/* import "zeppelin-solidity/proxy/Initializable.sol"; */
/* import "./ItemBar.sol"; */

contract LandItemBar is Initializable, ItemBar(address(0), 0) {
	event ForceUnequip(
		uint256 indexed tokenId,
		uint256 index,
		address staker,
		address token,
		uint256 id
	);

	mapping(uint256 => mapping(uint256 => bool)) public land2IsPrivate;
	IERC721 public ownership;
	ILandResource public landResource;
	IInterstellarEncoder public interstellarEncoder; 

	function initialize(address _registry, uint256 _maxAmount)
		public
		initializer
	{
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
		maxAmount = _maxAmount;

		refresh();
	}

	function refresh() public auth override {
		super.refresh();

		ownership = IERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
		landResource = ILandResource(registry.addressOf(CONTRACT_LAND_RESOURCE));
		interstellarEncoder = IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER));
	}

	modifier onlyLander(uint256 _landTokenId) {
		require(
			ownership.ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
		);
		_;
	}

	modifier onlyAuth(uint256 _landTokenId, uint256 _index) override {
		require(
			land2IsPrivate[_landTokenId][_index] == false ||
				ownership.ownerOf(_landTokenId) == msg.sender,
			"Furnace: Forbidden"
		);
		_;
	}

	modifier updateMinerStrength(uint256 _landTokenId) override {
		landResource.updateAllMinerStrengthWhenStop(
			_landTokenId
		);
		_;
		landResource.updateAllMinerStrengthWhenStart(
			_landTokenId
		);
	}

	function _forceUneqiup(uint256 _landTokenId, uint256 _index)
		internal
		updateMinerStrength(_landTokenId)
	{
		require(_index < maxAmount, "Furnace: INDEX_FORBIDDEN");
		Bar storage bar = tokenId2Bars[_landTokenId][_index];
		if (bar.token == address(0)) return;
		IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
		emit ForceUnequip(_landTokenId, _index, bar.staker, bar.token, bar.id);
		delete bar.rates[gold];
		delete bar.rates[wood];
		delete bar.rates[water];
		delete bar.rates[fire];
		delete bar.rates[soil];
		delete itemId2Index[bar.token][bar.id];
		delete tokenId2Bars[_landTokenId][_index];
	}

	function setPrivate(uint256 _landTokenId, uint256 _index)
		external
		onlyLander(_landTokenId)
	{
		require(land2IsPrivate[_landTokenId][_index] == false, "Furnace: ALREADY_PRIVATE");
		land2IsPrivate[_landTokenId][_index] = true;
		Bar storage bar = tokenId2Bars[_landTokenId][_index];
		if (bar.staker != msg.sender) {
			_forceUneqiup(_landTokenId, _index);
		}
	}

	function setPublic(uint256 _landTokenId, uint256 _index) external onlyLander(_landTokenId) {
		require(land2IsPrivate[_landTokenId][_index] == true, "Furnace: ALREADY_PUBLIC.");
		land2IsPrivate[_landTokenId][_index] = false;
	}

	function isAllowed(uint256 _landTokenId, address _token, uint256 _id)
		public
		view
		override
		returns (bool)
	{
        require(interstellarEncoder.getObjectClass(_landTokenId) == 1, "Funace: ONLY_LAND");
		return teller.isAllowed(_token, _id);
	}

	function isAmbassador(uint256 _landTokenId) public pure returns (bool) {
		uint128 objectId = uint128(_landTokenId);
		return uint16(uint16(objectId >> 112) & 0xFC00) > 0;
	}
}

