pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IDrillBase.sol";

contract DrillTakeBack is DSMath, DSStop {
	event TakeBackDrill(
		address indexed user,
		uint256 indexed id,
		uint256 tokenId
	);
	event OpenBox(
		address indexed user,
		uint256 indexed id,
		uint256 tokenId,
		uint256 value
	);
	event ClaimedTokens(
		address indexed token,
		address indexed to,
		uint256 amount
	);

	// 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_RING_ERC20_TOKEN =
		"CONTRACT_RING_ERC20_TOKEN";

	// 0x434f4e54524143545f4954454d5f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_DRILL_BASE = "CONTRACT_DRILL_BASE";

	address public supervisor;

	uint256 public networkId;

	mapping(uint256 => bool) public ids;

	ISettingsRegistry public registry;

	modifier isHuman() {
		// solhint-disable-next-line avoid-tx-origin
		require(msg.sender == tx.origin, "robot is not permitted");
		_;
	}

	constructor(
		address _registry,
		address _supervisor,
		uint256 _networkId
	) public {
		supervisor = _supervisor;
		networkId = _networkId;
		registry = ISettingsRegistry(_registry);
	}

	// _hashmessage = hash("${address(this)}{_user}${networkId}${ids[]}${grade[]}")
	// _v, _r, _s are from supervisor's signature on _hashmessage
	// takeBack(...) is invoked by the user who want to clain drill.
	// while the _hashmessage is signed by supervisor
	function takeBack(
		uint256[] memory _ids,
		uint16[] memory _grades,
		bytes32 _hashmessage,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) public isHuman stoppable {
		address _user = msg.sender;
		// verify the _hashmessage is signed by supervisor
		require(
			supervisor == _verify(_hashmessage, _v, _r, _s),
			"verify failed"
		);
		// verify that the address(this), _user, networkId, _ids, _grades are exactly what they should be
		require(
			keccak256(
				abi.encodePacked(address(this), _user, networkId, _ids, _grades)
			) == _hashmessage,
			"hash invaild"
		);
		require(_ids.length == _grades.length, "length invalid.");
		require(_grades.length > 0, "no drill.");
		for (uint256 i = 0; i < _ids.length; i++) {
			uint256 id = _ids[i];
			require(ids[id] == false, "already taked back.");
			uint16 grade = _grades[i];
			uint256 tokenId = _rewardDrill(grade, _user);
			ids[id] = true;
			emit TakeBackDrill(_user, id, tokenId);
		}
	}

	// _hashmessage = hash("${address(this)}${_user}${networkId}${boxId[]}${amount[]}")
	function openBoxes(
		uint256[] memory _ids,
		uint256[] memory _amounts,
		bytes32 _hashmessage,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) public isHuman stoppable {
		address _user = msg.sender;
		// verify the _hashmessage is signed by supervisor
		require(
			supervisor == _verify(_hashmessage, _v, _r, _s),
			"verify failed"
		);
		// verify that the _user, _value are exactly what they should be
		require(
			keccak256(
				abi.encodePacked(
					address(this),
					_user,
					networkId,
					_ids,
					_amounts
				)
			) == _hashmessage,
			"hash invaild"
		);
		require(_ids.length == _amounts.length, "length invalid.");
		require(_ids.length > 0, "no box.");
		for (uint256 i = 0; i < _ids.length; i++) {
			uint256 id = _ids[i];
			require(ids[id] == false, "box already opened.");
			_openBox(_user, id, _amounts[i]);
			ids[id] = true;
		}
	}

	function _openBox(
		address _user,
		uint256 _boxId,
		uint256 _amount
	) internal {
		(uint256 prizeDrill, uint256 prizeRing) = _random(_boxId);
		uint256 tokenId;
		uint256 value;
		uint256 boxType = _boxId >> 255;
		if (boxType == 1) {
			// gold box
			if (prizeRing == 1 && _amount > 1) {
				address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
				value = _amount / 2;
				IERC20(ring).transfer(_user, value);
			}
			if (prizeDrill < 10) {
				tokenId = _rewardDrill(3, _user);
			} else {
				tokenId = _rewardDrill(2, _user);
			}
		} else {
			// silver box
			if (prizeDrill == 0) {
				tokenId = _rewardDrill(3, _user);
			} else if (prizeDrill < 10) {
				tokenId = _rewardDrill(2, _user);
			} else {
				tokenId = _rewardDrill(1, _user);
			}
		}
		emit OpenBox(_user, _boxId, tokenId, value);
	}

	function _rewardDrill(uint16 _grade, address _owner)
		internal
		returns (uint256)
	{
		address drill = registry.addressOf(CONTRACT_DRILL_BASE);
		return IDrillBase(drill).createDrill(_grade, _owner);
	}

	// random algorithm
	function _random(uint256 _boxId) internal view returns (uint256, uint256) {
		uint256 seed =
			uint256(
				keccak256(
					abi.encodePacked(
						blockhash(block.number),
						block.timestamp, // solhint-disable-line not-rely-on-time
						block.difficulty,
						_boxId
					)
				)
			);
		return (seed % 100, seed >> 255);
	}

	function _verify(
		bytes32 _hashmessage,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) internal pure returns (address) {
		bytes memory prefix = "\x19EvolutionLand Signed Message:\n32";
		bytes32 prefixedHash =
			keccak256(abi.encodePacked(prefix, _hashmessage));
		address signer = ecrecover(prefixedHash, _v, _r, _s);
		return signer;
	}

	function changeSupervisor(address _newSupervisor) public auth {
		supervisor = _newSupervisor;
	}

	//////////
	// Safety Methods
	//////////

	/// @notice This method can be used by the controller to extract mistakenly
	///  sent tokens to this contract.
	/// @param _token The address of the token contract that you want to recover
	///  set to 0 in case you want to extract ether.
	function claimTokens(address _token) public auth {
		if (_token == address(0)) {
			_makePayable(owner).transfer(address(this).balance);
			return;
		}
		IERC20 token = IERC20(_token);
		uint256 balance = token.balanceOf(address(this));
		token.transfer(owner, balance);
		emit ClaimedTokens(_token, owner, balance);
	}

	function _makePayable(address x) internal pure returns (address payable) {
		return address(uint160(x));
	}
}
