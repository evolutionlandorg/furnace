all     :; dapp build
buildone:; dapp --use solc:0.4.24 buildone
clean   :; dapp clean
test    :; dapp test
deploy  :; dapp create Furnance
flat    :; bash flat.sh 
lint    :; solhint --max-warnings 0 'src/**/*.sol' 
link    :;
	rm -rf 'one'
	mkdir 'one'
	ln lib/apostle/contracts-flattener/ApostleBaseV3.sol one/ApostleBaseV3.f.sol
	ln lib/land/contracts-flattener/LandResourceV5.sol one/LandResourceV5.f.sol

.PHONY: all buildone clean test deploy flat lint link
