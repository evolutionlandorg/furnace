#!/usr/bin/env bash

set -e

if [ "$FURNANCE_VERBOSE" ]; then set -x; fi

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi

[[ $(pwd) != ~ && -e .fncrc ]] && . .fncrc

address=$(dapp create src/$1.sol:$1  -C ropsten --verify)
path=$FNC_CONFIG
cat $path | jq '.[''"'"${1^^}"'"''] = $address' --arg address $address | sponge $path
cat $path
