pragma solidity ^0.6.7;

contract ItemBaseAuthority {
    mapping(address => bool) public whiteList;

    constructor(address[] memory _whitelists) public {
        for (uint256 i = 0; i < _whitelists.length; i++) {
            whiteList[_whitelists[i]] = true;
        }
    }

    function canCall(
        address _src,
        address _dst,
        bytes4 _sig
    ) public view returns (bool) {
        return
            (whiteList[_src] &&
                _sig ==
                bytes4(
                    keccak256(
                        "createItem(uint16,uint16,uint16,uint16,uint16,bool,uint256,address[],uint256[],address)"
                    )
                )) ||
            (whiteList[_src] &&
                _sig == bytes4(keccak256("destroyItem(address,uint256)")));
    }
}
