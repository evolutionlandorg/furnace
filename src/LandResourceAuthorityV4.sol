pragma solidity ^0.6.7;

/**
 * @title LandResourceAuthority
 * @dev LandResourceAuthority is authority that manage LanResourece.
 * difference between LandResourceAuthorityV3 whiteList:
[$PETBASE_PROXY,$TOKENUSE_PROXY] ==> 
[$PETBASE_PROXY,$TOKENUSE_PROXY,$APOSTLEITEMBAR_PROXY,$LANDITEMBAR_PROXY]
 */
contract LandResourceAuthorityV4 {
	constructor(address[] memory _whitelists) public {
		for (uint256 i = 0; i < _whitelists.length; i++) {
			whiteList[_whitelists[i]] = true;
		}
	}

	mapping(address => bool) public whiteList;

	function canCall(
		address _src,
		address /*_dst*/,
		bytes4 _sig
	) public view returns (bool) {
		return
			(whiteList[_src] &&
				_sig == bytes4(keccak256("activityStopped(uint256)"))) ||
			(whiteList[_src] &&
				_sig ==
				bytes4(keccak256("updateMinerStrengthWhenStop(uint256)"))) ||
			(whiteList[_src] &&
				_sig ==
				bytes4(keccak256("updateAllMinerStrengthWhenStop(uint256)"))) ||
			(whiteList[_src] &&
				_sig ==
				bytes4(
					keccak256("updateAllMinerStrengthWhenStart(uint256)")
				)) ||
			(whiteList[_src] &&
				_sig ==
				bytes4(keccak256("updateMinerStrengthWhenStart(uint256)")));
	}
}
