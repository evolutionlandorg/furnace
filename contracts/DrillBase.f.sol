// hevm: flattened sources of src/DrillBase.sol

pragma solidity =0.6.0;

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

////// src/interfaces/IObjectOwnership.sol
/* pragma solidity ^0.6.7; */

interface IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) external returns (uint256 _tokenId);
	
    function burn(address _to, uint256 _tokenId) external;
}

////// src/interfaces/ISettingsRegistry.sol
/* pragma solidity ^0.6.7; */

interface ISettingsRegistry {
    function uintOf(bytes32 _propertyName) external view returns (uint256);

    function addressOf(bytes32 _propertyName) external view returns (address);
}

////// src/DrillBase.sol
/* pragma solidity ^0.6.7; */

/* import "ds-auth/auth.sol"; */
/* import "./interfaces/ISettingsRegistry.sol"; */
/* import "./interfaces/IObjectOwnership.sol"; */

contract DrillBase is DSAuth {
	event Create(
		address indexed owner,
		uint256 indexed tokenId,
		uint16 grade,
		uint256 createTime
	);
	event Destroy(address indexed owner, uint256 indexed tokenId);

	uint256 internal constant _CLEAR_HIGH =
		0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	/*** STORAGE ***/
	bool private singletonLock = false;

	uint128 public lastDrillObjectId;

	ISettingsRegistry public registry;

	modifier singletonLockCall() {
		require(!singletonLock, "Only can call once");
		_;
		singletonLock = true;
	}

	/**
	 * @dev Same with constructor, but is used and called by storage proxy as logic contract.
	 */
	function initializeContract(address _registry) public singletonLockCall {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);
	}

	/**
	 * @dev create a Drill.
	 * @param grade - Drill grade.
	 * @param to - owner of the Drill.
	 * @return   - tokenId.
	 */
	function createDrill(uint16 grade, address to)
		public
		auth
		returns (uint256)
	{
		return _createDrill(grade, to);
	}

	function _createDrill(uint16 grade, address to) internal returns (uint256) {
		lastDrillObjectId += 1;
		require(
			lastDrillObjectId < 5192296858534827628530496329220095,
			"Drill: object id overflow."
		);

		uint128 objectId = (uint128(grade) << 112) | lastDrillObjectId;

		uint256 tokenId =
			IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP))
				.mintObject(to, objectId);
		emit Create(
			to,
			tokenId,
			grade,
			now // solhint-disable-line
		);
		return tokenId;
	}

	/**
	 * @dev destroy a Drill.
	 * @param to owner of the drill.
	 * @param tokenId tokenId of the drill.
	 */
	function destroyDrill(address to, uint256 tokenId) public auth {
		IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).burn(
			to,
			tokenId
		);
		emit Destroy(to, tokenId);
	}

	function getGrade(uint256 tokenId) public pure returns (uint16) {
		uint128 objectId = uint128(tokenId & _CLEAR_HIGH);
		return uint16(objectId >> 112);
	}
}

