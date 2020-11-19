#!/usr/bin/env bash

set -e

if [ "$FURNANCE_VERBOSE" ]; then set -x; fi

[[ $(pwd) != ~ && -e .fncrc ]] && . .fncrc
. $(PWD)/script/init.sh

OWNERSHIPV3WHITELIST=[$LANDBASE_PROXY,$APOSTLEBASE_PROXY,$ERC721BRIDGE_PROXY,$ITEMBASE_PROXY]

address=$(dapp create src/ItemBase.sol:ItemBase  -C ropsten --verify)
seth send $ITEMBASE_PROXY "upgradeTo(address)" $address
# seth send $ITEMBASE_PROXY "initializeContract(address)" $ISETTINGSREGISTRY

path=$FNC_CONFIG
cat $path | jq '.ITEMBASE = $address' --arg address $address | sponge $path

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
