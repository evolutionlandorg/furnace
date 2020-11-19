pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IItemBase.sol";
import "./FurnanceSettingIds.sol";

contract ItemTakeBack is DSMath, DSStop, FurnanceSettingIds {
    event TakeBackNFT(
        address indexed user,
        uint256 indexed nonce,
        uint256 tokenId
    );
    event OpenBox(
        address indexed user,
        uint256 indexed nonce,
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

    ISettingsRegistry public registry;

    modifier isHuman() {
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
    // takeBack(...) is invoked by the user who want to clain item.
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
            supervisor == verify(_hashmessage, _v, _r, _s),
            "verify failed"
        );
        // verify that the _user, _nonce, _value are exactly what they should be
        require(
            keccak256(
                abi.encodePacked(_user, _nonce, _expireTime, networkId, _grades)
            ) == _hashmessage,
            "hash invaild"
        );
        require(now <= _expireTime, "you are expired.");
        require(_grades.length > 0, "no item.");
        for (uint256 i = 0; i < _grades.length; i++) {
            uint16 grade = _grades[i];
            uint256 tokenId;
            if (grade == 1) {
                tokenId = rewardLevel1Item(_user);
            } else if (grade == 2) {
                tokenId = rewardLevel2Item(_user);
            } else if (grade == 3) {
                tokenId = rewardLevel3Item(_user);
            }
            emit TakeBackNFT(_user, _nonce, tokenId);
        }
        // after the claiming operation succeeds
        userToNonce[_user] += 1;
    }

    // _hashmessage = hash("${_user}${_nonce}${_expireTime}${networkId}${boxId[]}${amount[]}")
    function openBoxes(
        uint256 _nonce,
        uint256 _expireTime,
        uint256[] memory _boxIds,
        uint256[] memory _amounts,
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
            supervisor == verify(_hashmessage, _v, _r, _s),
            "verify failed"
        );
        // verify that the _user, _nonce, _value are exactly what they should be
        require(
            keccak256(
                abi.encodePacked(
                    _user,
                    _nonce,
                    _expireTime,
                    networkId,
                    _boxIds,
                    _amounts
                )
            ) == _hashmessage,
            "hash invaild"
        );
        require(now <= _expireTime, "you are expired.");
        require(_boxIds.length == _amounts.length, "invalid box or amount");
        require(_boxIds.length > 0, "no box.");
        for (uint256 i = 0; i < _boxIds.length; i++) {
            openBox(_user, _nonce, _boxIds[i], _amounts[i]);
        }
        // after the claiming operation succeeds
        userToNonce[_user] += 1;
    }

    function openBox(
        address _user,
        uint256 _nonce,
        uint256 _boxId,
        uint256 _amount
    ) internal {
        (uint256 prizeNFT, uint256 prizeFT) = random(
            _nonce,
            _boxId
        );
        uint256 tokenId;
        uint256 value;
        uint256 boxType = (_boxId >> 255) & 1;
        if (boxType == 1) {
            // gold box
            if (prizeFT == 1 && _amount > 1) {
                address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
                value = _amount / 2;
                IERC20(ring).transfer(_user, value);
            }
            if (prizeNFT < 10) {
                tokenId = rewardLevel3Item(_user);
            } else {
                tokenId = rewardLevel2Item(_user);
            }
        } else {
            // silver box
            if (prizeNFT == 0) {
                tokenId = rewardLevel3Item(_user);
            } else if (prizeNFT < 10) {
                tokenId = rewardLevel2Item(_user);
            } else {
                tokenId = rewardLevel1Item(_user);
            }
        }
        emit OpenBox(_user, _nonce, _boxId, tokenId, value);
    }

    function rewardLevel1Item(address _owner)
        internal
        returns (uint256)
    {
        address item = registry.addressOf(CONTRACT_ITEM_BASE);
        return
            IItemBase(item).createItem(
                0,
                1,
                0,
                2,
                0,
                false,
                0,
                new address[](0),
                new uint256[](0),
                _owner
            );
    }

    function rewardLevel2Item(address _owner)
        internal
        returns (uint256)
    {
        address item = registry.addressOf(CONTRACT_ITEM_BASE);
        return
            IItemBase(item).createItem(
                0,
                2,
                0,
                3,
                0,
                false,
                0,
                new address[](0),
                new uint256[](0),
                _owner
            );
    }

    function rewardLevel3Item(address _owner)
        internal
        returns (uint256)
    {
        address item = registry.addressOf(CONTRACT_ITEM_BASE);
        return
            IItemBase(item).createItem(
                0,
                3,
                0,
                4,
                0,
                false,
                0,
                new address[](0),
                new uint256[](0),
                _owner
            );
    }

    // random algorithm
    function random(uint256 _nonce, uint256 _boxId)
        internal
        view
        returns (
            uint256,
            uint256
        )
    {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number),
                    block.difficulty,
                    _nonce,
                    _boxId
                )
            )
        );
        return (seed % 100, seed & (1 << 255));
    }

    function verify(
        bytes32 _hashmessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (address) {
        bytes memory prefix = "\x19EvolutionLand Signed Message:\n32";
        bytes32 prefixedHash = keccak256(
            abi.encodePacked(prefix, _hashmessage)
        );
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
            make_payable(owner).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }

    function make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }
}
