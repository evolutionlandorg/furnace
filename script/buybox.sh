#!/usr/bin/env bash

set -ex

. $(PWD)/script/init.sh

# buy box
amount=$(seth --to-uint256 $(seth --to-wei 150 ether))
goldBox=$(seth --to-uint256 0)
silverBox=$(seth --to-uint256 1)
data=$goldBox${silverBox:2}
seth send -F $AUTH $TOKEN_RING "transfer(address,uint256,bytes)" $ITEMLUCKYBOX $amount $data 

