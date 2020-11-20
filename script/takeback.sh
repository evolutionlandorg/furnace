#!/usr/bin/env bash

set -ex

. $(PWD)/script/init.sh

# take back 
# _hashmessage = hash("${_user}${_nonce}${_expireTime}${networkId}${grade[]}")

nonce=$(seth --to-uint256 1)
expireTime=$(seth --to-uint256 1605787415)
networkId=$(seth --to-uint256 3)
grade=$(seth --to-uint256 2)
msg="${OWNER}${nonce:2}${expireTime:2}${networkId:2}${grade:2}" 
# abi.encodePacked(_user, _nonce, _expireTime, networkId, _grades)
hashmsg=$(seth keccak $msg)
signedmsg=$(ethsign msg --from $SUPERVISOR --data $hashmsg --passphrase-file $ETH_PASSWORD --key-store $ETH_KEYSTORE)
prefixedHash=$(seth call $ECDSA "toEthSignedMessageHash(bytes32)" $hashmsg)
signer=$(seth call $ECDSA "recover(bytes32,bytes)" $prefixedHash $signedmsg)
dec=$(seth --abi-decode 'f()(address,bytes32,bytes32,uint8)' "$signer")
sup=$(echo $dec | cut -d' ' -f 1)
r=$(echo $dec | cut -d' ' -f 2)
s=$(echo $dec | cut -d' ' -f 3)
v=$(echo $dec | cut -d' ' -f 4)
seth send -F $OWNER $ITEMTAKEBACK "takeBack(uint256,uint256,uint16[],bytes32,uint8,bytes32,bytes32)" $nonce $expireTime [$grade] $hashmsg $v $r $s  
