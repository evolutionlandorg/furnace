pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IDrillBase.sol";
import "./FurnaceSettingIds.sol";

contract DrillTakeBack is DSMath, DSStop, FurnaceSettingIds {
	event TakeBackNFT(
		address indexed user,
		uint256 indexed nonce,
		uint256 tokenId
	);
	event OpenBox(
		address indexed user,
		uint256 indexed boxId,
		uint256 tokenId,
		uint256 value
	);
	event ClaimedTokens(
		address indexed token,
		address indexed to,
		uint256 amount
	);

	address public supervisor;

	uint256 public networkId;

	mapping(address => uint256) public userToNonce;

	// store opened box id.
	mapping(uint256 => bool) public openedBoxId;

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

	// _hashmessage = hash("${_user}${_nonce}${_expireTime}${networkId}${grade[]}")
	// _v, _r, _s are from supervisor's signature on _hashmessage
	// takeBack(...) is invoked by the user who want to clain drill.
	// while the _hashmessage is signed by supervisor
	function takeBack(
		uint256 _nonce,
		uint256 _expireTime,
		uint16[] memory _grades,
		bytes32 _hashmessage,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) public isHuman stoppable {
		address _user = msg.sender;
		// verify the _nonce is right
		require(userToNonce[_user] == _nonce, "nonce invalid");
		// verify the _hashmessage is signed by supervisor
		require(
			supervisor == _verify(_hashmessage, _v, _r, _s),
			"verify failed"
		);
		// verify that the _user, _nonce,  are exactly what they should be
		require(
			keccak256(
				abi.encodePacked(_user, _nonce, _expireTime, networkId, _grades)
			) == _hashmessage,
			"hash invaild"
		);
		// solhint-disable-next-line not-rely-on-time
		require(now <= _expireTime, "you are expired.");
		require(_grades.length > 0, "no drill.");
		for (uint256 i = 0; i < _grades.length; i++) {
			uint16 grade = _grades[i];
			uint256 tokenId;
			if (grade == 1) {
				tokenId = _rewardLevel1Drill(_user);
			} else if (grade == 2) {
				tokenId = _rewardLevel2Drill(_user);
			} else if (grade == 3) {
				tokenId = _rewardLevel3Drill(_user);
			}
			emit TakeBackNFT(_user, _nonce, tokenId);
		}
		// after the claiming operation succeeds
		userToNonce[_user] += 1;
	}

	// _hashmessage = hash("${_user}${_expireTime}${networkId}${boxId[]}${amount[]}")
	function openBoxes(
		uint256 _expireTime,
		uint256[] memory _boxIds,
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
					_user,
					_expireTime,
					networkId,
					_boxIds,
					_amounts
				)
			) == _hashmessage,
			"hash invaild"
		);
		// solhint-disable-next-line not-rely-on-time
		require(now <= _expireTime, "you are expired.");
		require(_boxIds.length == _amounts.length, "invalid box or amount.");
		require(_boxIds.length > 0, "no box.");
		for (uint256 i = 0; i < _boxIds.length; i++) {
			uint256 boxId = _boxIds[i];
			require(openedBoxId[boxId] == false, "box already opened.");
			_openBox(_user, boxId, _amounts[i]);
			openedBoxId[boxId] = true;
		}
		// after the claiming operation succeeds
		userToNonce[_user] += 1;
	}

	function _openBox(
		address _user,
		uint256 _boxId,
		uint256 _amount
	) internal {
		(uint256 prizeNFT, uint256 prizeFT) = _random(_boxId);
		uint256 tokenId;
		uint256 value;
		uint256 boxType = _boxId >> 255;
		if (boxType == 1) {
			// gold box
			if (prizeFT == 1 && _amount > 1) {
				address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
				value = _amount / 2;
				IERC20(ring).transfer(_user, value);
			}
			if (prizeNFT < 10) {
				tokenId = _rewardLevel3Drill(_user);
			} else {
				tokenId = _rewardLevel2Drill(_user);
			}
		} else {
			// silver box
			if (prizeNFT == 0) {
				tokenId = _rewardLevel3Drill(_user);
			} else if (prizeNFT < 10) {
				tokenId = _rewardLevel2Drill(_user);
			} else {
				tokenId = _rewardLevel1Drill(_user);
			}
		}
		emit OpenBox(_user, _boxId, tokenId, value);
	}

	function _rewardLevel1Drill(address _owner) internal returns (uint256) {
		address drill = registry.addressOf(CONTRACT_DRILL_BASE);
		return IDrillBase(drill).createDrill(1, _owner);
	}

	function _rewardLevel2Drill(address _owner) internal returns (uint256) {
		address drill = registry.addressOf(CONTRACT_DRILL_BASE);
		return IDrillBase(drill).createDrill(2, _owner);
	}

	function _rewardLevel3Drill(address _owner) internal returns (uint256) {
		address drill = registry.addressOf(CONTRACT_DRILL_BASE);
		return IDrillBase(drill).createDrill(3, _owner);
	}

	// random algorithm
	function _random(uint256 _boxId)
		internal
		view
		returns (uint256, uint256)
	{
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
