pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/IObjectOwnership.sol";
import "./interfaces/IDrillBase.sol";
import "./DrillBoxPriceCrab.sol";

contract BoxBaseCrab is Initializable, DSMath, DSStop, DrillBoxPriceCrab {
	event Create(
		address indexed owner,
		uint256 indexed tokenId,
		Box typ,
        address token,
        uint256 price,
		uint256 createTime
	);

	event OpenBox(
		address indexed user,
		uint256 indexed boxId,
		uint256 drillId,
		uint256 value
	);

	// 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";
	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";
	// 0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000
	bytes32 public constant CONTRACT_DRILL_BASE = "CONTRACT_DRILL_BASE";

    enum Box {
        NaN,
        Gold,
        Silver
    }

    struct Prop {
        uint8 typ;
        bool opened;
        address token;
        uint256 price;
    }

	uint128 public lastObjectId;
    ISettingsRegistry public registry;
	uint256 public priceIncreaseBeginTime;
    mapping(uint256 => Prop) public propOf;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function initialize(address _registry, uint256 _priceIncreaseBeginTime) public initializer {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
        registry = ISettingsRegistry(_registry);
		priceIncreaseBeginTime = _priceIncreaseBeginTime;
    }

	function getPrice() public view returns (uint256 priceGoldBox, uint256 priceSilverBox)
	{
		// solhint-disable-next-line not-rely-on-time
		if (now <= priceIncreaseBeginTime) {
			priceGoldBox = GOLD_BOX_BASE_PRICE;
			priceSilverBox = SILVER_BOX_BASE_PRICE;
		} else {
			// solhint-disable-next-line not-rely-on-time
			uint256 numDays = sub(now, priceIncreaseBeginTime) / 1 days;
			if (numDays > 90) {
				priceGoldBox = GOLD_BOX_MAX_PRICE;
				priceSilverBox = SILVER_BOX_MAX_PRICE;
			} else {
				priceGoldBox = uint256(GOLD_BOX_PRICE[numDays]);
				priceSilverBox = uint256(SILVER_BOX_PRICE[numDays]);
			}
		}
		priceGoldBox = mul(priceGoldBox, DECIMALS);
		priceSilverBox = mul(priceSilverBox, DECIMALS);
	}

    function buyBox(address to, uint256 goldBoxAmount, uint256 silverBoxAmount, uint256 amountMax) external stoppable {
		(uint256 priceGoldBox, uint256 priceSilverBox) = getPrice();
		uint256 chargeGoldBox = mul(goldBoxAmount, priceGoldBox);
		uint256 chargeSilverBox = mul(silverBoxAmount, priceSilverBox);
		uint256 charge = add(chargeGoldBox, chargeSilverBox);
		//  Only supported tokens can be called
		address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
		require(
			goldBoxAmount > 0 || silverBoxAmount > 0,
			"Buy gold or silver box"
		);
		require(amountMax >= charge, "No enough ring for buying lucky boxes.");

		IERC20(ring).transferFrom(msg.sender, address(this), charge);

		if (goldBoxAmount > 0) {
            for (uint i = 0; i < goldBoxAmount; i++) {
                _buyGoldBox(to, ring, priceGoldBox);
            }
		}
		if (silverBoxAmount > 0) {
            for (uint i = 0; i < silverBoxAmount; i++) {
                _buySilverBox(to, ring, priceSilverBox);
            }
		}
    }

    function openBoxes(uint256[] calldata ids) external {
        for (uint256 i = 0; i < ids.length; i++){
            openBox(ids[i]);
        }
    }

    function openBox(uint256 boxId) public notContract stoppable {
        require(IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(boxId) == msg.sender, "forbidden");
        Prop storage prop = propOf[boxId];
        prop.opened = true;
        _openBox(msg.sender, boxId, prop.typ, prop.price);
    }

	function _openBox(address _user, uint256 boxId, uint8 boxType, uint256 _amount) internal returns(uint256 drillId, uint256 value) {
		(uint256 prizeDrill, uint256 prizeRing) = _random(boxId);
		if (boxType == uint8(Box.Gold)) {
			// gold box
			if (prizeRing == 1 && _amount > 1) {
				address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
				value = _amount / 2;
				IERC20(ring).transfer(_user, value);
			}
			if (prizeDrill < 10) {
				drillId = _rewardDrill(3, _user);
			} else {
				drillId = _rewardDrill(2, _user);
			}
		} else if (boxType == uint8(Box.Silver)) {
			// silver box
			if (prizeDrill == 0) {
				drillId = _rewardDrill(3, _user);
			} else if (prizeDrill < 10) {
				drillId = _rewardDrill(2, _user);
			} else {
				drillId = _rewardDrill(1, _user);
			}
		}
		emit OpenBox(_user, boxId, drillId, value);
	}

	function createBox(Box typ, address to, address token, uint256 price) public auth returns (uint256) {
		return _createBox(typ, to, token, price);
	}

	function _rewardDrill(uint16 _grade, address _owner) internal returns (uint256) {
		address drill = registry.addressOf(CONTRACT_DRILL_BASE);
		return IDrillBase(drill).createDrill(_grade, _owner);
	}

    function _buyGoldBox(address to, address token, uint256 price) internal returns (uint256) {
        return _createBox(Box.Gold, to, token, price);
    }

    function _buySilverBox(address to, address token, uint256 price) internal returns (uint256) {
        return _createBox(Box.Silver, to, token, price);
    }

    function _createBox(Box typ, address to, address token, uint256 price) internal returns (uint256) {
        lastObjectId += 1;
        require(lastObjectId < uint128(-1), "overflow");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(to, lastObjectId);
        propOf[tokenId] = Prop(uint8(typ), false, token, price);
        emit Create(to, tokenId, typ, token, price, block.timestamp);
    }

	function _random(uint256 _boxId) internal view returns (uint256, uint256) {
		uint256 seed =
			uint256(
				keccak256(
					abi.encodePacked(
						blockhash(block.number - 1),
						block.timestamp, // solhint-disable-line not-rely-on-time
						block.difficulty,
                        msg.sender,
						_boxId
					)
				)
			);
		return (seed % 100, seed >> 255);
	}

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
