pragma solidity ^0.6.7;

interface ISettingsRegistry {
    function addressOf(bytes32 _propertyName) external view returns (address);
}
