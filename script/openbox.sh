#!/usr/bin/env bash

set -ex

. $(PWD)/script/init.sh

# open box
_hashmessage = hash("${_user}${_nonce}${_expireTime}${networkId}${boxId[]}${amount[]}")
nonce=$(seth --to-uint256 2)
expireTime=$(seth --to-uint256 1605787415)
networkId=$(seth --to-uint256 3)
boxId=0xffffffffff4143545f52494e475f45524332305f544f4b454e00000000000000
amount=$(seth --to-uint256 $(seth --to-wei 1000 ether))
msg="${AUTH}${nonce:2}${expireTime:2}${networkId:2}${boxId:2}${amount:2}" 
hashmsg=$(seth keccak $msg)
signedmsg=$(ethsign msg --from $SUPERVISOR --data $hashmsg --passphrase-file $ETH_PASSWORD --key-store $ETH_KEYSTORE)
prefixedHash=$(seth call $ECDSA "toEthSignedMessageHash(bytes32)" $hashmsg)
signer=$(seth call $ECDSA "recover(bytes32,bytes)" $prefixedHash $signedmsg)
dec=$(seth --abi-decode 'f()(address,bytes32,bytes32,uint8)' "$signer")
sup=$(echo $dec | cut -d' ' -f 1)
r=$(echo $dec | cut -d' ' -f 2)
s=$(echo $dec | cut -d' ' -f 3)
v=$(echo $dec | cut -d' ' -f 4)
seth send -F $AUTH $ITEMTAKEBACK "openBoxes(uint256,uint256,uint256[],uint256[],bytes32,uint8,bytes32,bytes32)" $nonce $expireTime [$boxId] [$amount] $hashmsg $v $r $s  