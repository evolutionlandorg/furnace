pragma solidity ^0.6.7;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./FurnanceSettingIds.sol";
import "./ItemBoxPrice.sol";

contract ItemLuckyBox is DSMath, DSStop, ItemBoxPrice, FurnanceSettingIds {
    //TODO: backend CHECK.
    event GoldBoxSale(address indexed buyer, uint256 amount, uint256 price);
    event SilverBoxSale(address indexed buyer, uint256 amount, uint256 price);
    event RingRefunded(address indexed buyer, uint256 value);
    event ClaimedTokens(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    address payable public wallet;

    uint256 public priceIncreaseBeginTime;

    ISettingsRegistry public registry;

    constructor(
        address _registry,
        address payable _wallet,
        uint256 _priceIncreaseBeginTime
    ) public {
        require(_wallet != address(0), "Need a good wallet to store fund");

        registry = ISettingsRegistry(_registry);
        wallet = _wallet;
        priceIncreaseBeginTime = _priceIncreaseBeginTime;
    }

    /**
     * @dev ERC223 fallback function, make sure to check the msg.sender is from target token contracts
     * @param _from - person who transfer token in for buying box.
     * @param _amount - amount of token.
     * @param _data - data which indicate the operations.
     */
    function tokenFallback(
        address _from,
        uint256 _amount,
        bytes memory _data
    ) public stoppable {
        uint256 goldBoxAmount;
        uint256 silverBoxAmount;
        //TODO:: check
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            goldBoxAmount := mload(add(ptr, 132))
            silverBoxAmount := mload(add(ptr, 164))
        }
        (uint256 priceGoldBox, uint256 priceSilverBox) = getPrice();
        uint256 chargeGoldBox = mul(goldBoxAmount, priceGoldBox);
        uint256 chargeSilverBox = mul(silverBoxAmount, priceSilverBox);
        uint256 charge = add(chargeGoldBox, chargeSilverBox);
        //  Only supported tokens can be called
        address ring = registry.addressOf(CONTRACT_RING_ERC20_TOKEN);
        require(msg.sender == ring, "Only support ring");
        require(
            goldBoxAmount > 0 || silverBoxAmount > 0,
            "Buy gold or silver box"
        );
        require(_amount >= charge, "No enough ring for buying lucky boxs.");

        IERC20(ring).transfer(wallet, charge);

        if (goldBoxAmount > 0) {
            emit GoldBoxSale(_from, goldBoxAmount, priceGoldBox);
        }
        if (silverBoxAmount > 0) {
            emit SilverBoxSale(_from, silverBoxAmount, priceSilverBox);
        }
        if (_amount > charge) {
            uint256 ringToRefund = sub(_amount, charge);
            IERC20(ring).transfer(_from, ringToRefund);
            emit RingRefunded(_from, ringToRefund);
        }
    }

    function getPrice()
        public
        view
        returns (uint256 priceGoldBox, uint256 priceSilverBox)
    {
        if (now <= priceIncreaseBeginTime) {
            priceGoldBox = GOLD_BOX_BASE_PRICE;
            priceSilverBox = SILVER_BOX_BASE_PRICE;
        } else {
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
