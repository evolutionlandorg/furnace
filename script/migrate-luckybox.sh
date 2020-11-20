#!/usr/bin/env bash

set -e

if [ "$FURNANCE_VERBOSE" ]; then set -x; fi

. $(PWD)/script/init.sh

address=$(dapp create src/ItemLuckyBox.sol:ItemLuckyBox $ISETTINGSREGISTRY $AUTH $(seth --to-uint256 1605657600)  -C ropsten --verify)
seth call $address "getPrice()(uint256,uint256)"   # 1000 100  
path=$FNC_CONFIG
cat $path | jq '.ITEMLUCKYBOX = $address' --arg address $address | sponge $path
cat $path
