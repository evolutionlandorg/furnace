#!/usr/bin/env bash

set -ex

# Look for my key files in a custom directory
# ETH_KEYSTORE=~/workspace/contract/darwinia/darwinia-bridge-on-ethereum/dataDir/keystore
# ETH keystore passwd
# ETH_PASSWORD=~/workspace/contract/darwinia/darwinia-bridge-on-ethereum/dataDir/keystore/passwd
# ERC-20 RING
TOKEN_RING=0xb52FBE2B925ab79a821b261C82c5Ba0814AAA5e0
# InterstellarEncoder
INTERSTELLARENCODER=0x6Be8f8d0aDB016b1EB09FA4AADdD65F43af5Ada9
# ISettingsRegistry
ISETTINGSREGISTRY=0x6982702995b053A21389219c1BFc0b188eB5a372
# IObjectOwnership
IOBJECTOWNERSHIP_PROXY=0x5eA9ea8E80230E514b5e023e8d956550a22D02c6
# ObjectOwnershipAuthority
OBJECTOWNERSHIPAUTHORITY=0x7b796211e7f8b239b7ec257fe05ceeb6d9e53d62
# LandBase Proxy
LANDBASE_PROXY=0x33c7A4C0454618c4AD43330C056eEC231c00d366
# ApostleBaseV2 Proxy
APOSTLEBASE_PROXY=0x2E1dd56F118505a9D420Bf50D3bbAd80B3Aa2Ef3
# ERC721Bridge Proxy
ERC721BRIDGE_PROXY=0xFBCf09250Ca11B2142D40Fa39521b334C1d7Cb17
# Formula
FORMULA=0x3217F36AE34aCA2CE60d218af8F47d29101204a8
# ItemBase Proxy
ITEMBASE_PROXY=0x588abe3F7EE935137102C5e2B8042788935f4CB0
# ItemBase
ITEMBASE=0x841dAc53Bd3cb199d5f453BEf03dB6c4f9de999a
# ItemBaseAuthority 
ITEMBASEAUTHORITY=0xf62c4cfb52e2a3356d59a28db0201bfceb7e8478
# ItemLuckyBox
ITEMLUCKYBOX=0x75774d78306a847f5cfc7630f37bd4ed649784b3
# ItemTakeBack
ITEMTAKEBACK=0xda66771a4e7a6aa6cbaf5526ccb9a3159cf64e03
# ECDSA
ECDSA=0xa2d2d90d03b0876a4883fb6c95b3c6dbaeb24def

AUTH=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
OWNER=0xcC5E48BEb33b83b8bD0D9d9A85A8F6a27C51F5C5
SUPERVISOR=0x00a1537d251a6a4c4effAb76948899061FeA47b9
OWNERSHIPV3WHITELIST=[$LANDBASE_PROXY,$APOSTLEBASE_PROXY,$ERC721BRIDGE_PROXY,$ITEMBASE_PROXY]

# dapp create src/Formula.sol:Formula  -C ropsten --verify
# dapp create src/ItemBase.sol:ItemBase  -C ropsten --verify
# seth send $ITEMBASE_PROXY "upgradeTo(address)" $ITEMBASE
# seth send $ITEMBASE_PROXY "initializeContract(address)" $ISETTINGSREGISTRY

# dapp create ObjectOwnershipAuthorityV3 $OWNERSHIPV3WHITELIST -C ropsten --verify
# seth send -F $OWNER $IOBJECTOWNERSHIP_PROXY "setAuthority(address)" $OBJECTOWNERSHIPAUTHORITY 
# seth send -F $OWNER $INTERSTELLARENCODER "registerNewObjectClass(address,uint8)" $ITEMBASE_PROXY $(seth --to-hex 100) 
# seth call $INTERSTELLARENCODER "classAddress2Id(address)" $ITEMBASE_PROXY 
# seth call $INTERSTELLARENCODER "ownershipId2Address(uint8)" $(seth --to-hex 4) 
# item=$(seth --to-bytes32 $(seth --to-hex $(seth --from-ascii "CONTRACT_ITEM_BASE")))
# seth send -F $OWNER $ISETTINGSREGISTRY "setAddressProperty(bytes32,address)" $item $ITEMBASE_PROXY 
# seth call $ISETTINGSREGISTRY "addressOf(bytes32)" $item  

# seth --abi-decode 'f()(address)' $(seth call $IOBJECTOWNERSHIP_PROXY "authority()")
# seth --abi-decode 'f()(address[])' 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000300000000000000000000000033c7a4c0454618c4ad43330c056eec231c00d3660000000000000000000000002e1dd56f118505a9d420bf50d3bbad80b3aa2ef3000000000000000000000000fbcf09250ca11b2142d40fa39521b334c1d7cb17
# dapp create src/ECDSA.sol:ECDSA -C ropsten --verify
# dapp create src/ItemLuckyBox.sol:ItemLuckyBox $ISETTINGSREGISTRY $AUTH $(seth --to-uint256 1605657600)  -C ropsten --verify
# seth call $ITEMLUCKYBOX "getPrice()(uint256,uint256)"   # 1000 100  
# dapp create src/ItemTakeBack.sol:ItemTakeBack $ISETTINGSREGISTRY $SUPERVISOR $(seth --to-uint256 3)  -C ropsten --verify
# dapp create src/ItemBaseAuthority.sol:ItemBaseAuthority [$ITEMTAKEBACK] -C ropsten 
# seth call $ITEMBASEAUTHORITY "whiteList(address)" $ITEMTAKEBACK   
# seth send -F $AUTH $ITEMBASE_PROXY "setAuthority(address)" $ITEMBASEAUTHORITY 

# ring=$(seth --to-bytes32 $(seth --to-hex $(seth --from-ascii "CONTRACT_RING_ERC20_TOKEN")))
# seth call $ISETTINGSREGISTRY "addressOf(bytes32)" $ring 

# buy box
# amount=$(seth --to-uint256 $(seth --to-wei 150 ether))
# goldBox=$(seth --to-uint256 0)
# silverBox=$(seth --to-uint256 1)
# data=$goldBox${silverBox:2}
# seth send -F $AUTH $TOKEN_RING "transfer(address,uint256,bytes)" $ITEMLUCKYBOX $amount $data 

# open box
# _hashmessage = hash("${_user}${_nonce}${_expireTime}${networkId}${boxId[]}${amount[]}")
# nonce=$(seth --to-uint256 0)
# expireTime=$(seth --to-uint256 1605787415)
# networkId=$(seth --to-uint256 3)
# boxId=0xffffffffff4143545f52494e475f45524332305f544f4b454e00000000000000
# amount=$(seth --to-uint256 $(seth --to-wei 1000 ether))
# msg="${AUTH}${nonce:2}${expireTime:2}${networkId:2}${boxId:2}${amount:2}" 
# hashmsg=$(seth keccak $msg)
# signedmsg=$(ethsign msg --from $SUPERVISOR --data $hashmsg --passphrase-file $ETH_PASSWORD --key-store $ETH_KEYSTORE)
# prefixedHash=$(seth call $ECDSA "toEthSignedMessageHash(bytes32)" $hashmsg)
# signer=$(seth call $ECDSA "recover(bytes32,bytes)" $prefixedHash $signedmsg)
# dec=$(seth --abi-decode 'f()(address,bytes32,bytes32,uint8)' "$signer")
# sup=$(echo $dec | cut -d' ' -f 1)
# r=$(echo $dec | cut -d' ' -f 2)
# s=$(echo $dec | cut -d' ' -f 3)
# v=$(echo $dec | cut -d' ' -f 4)
# seth send -F $AUTH $ITEMTAKEBACK "openBoxes(uint256,uint256,uint256[],uint256[],bytes32,uint8,bytes32,bytes32)" $nonce $expireTime [$boxId] [$amount] $hashmsg $v $r $s  

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

# init formula
# 0

# name=$(seth --to-hexdata "普通GEGO镐子")
# seth send -F $AUTH $FORMULA "add(string,uint16,uint16,uint16,bool,uint16,address[],uint256[],uint256[])"  
