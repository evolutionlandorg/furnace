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
	ln -s $(PWD)/lib/land/flat/LandResourceV5.sol $(PWD)/one/LandResourceV5.f.sol
	ln -s $(PWD)/lib/apostle/flat/ApostleBaseV3.sol $(PWD)/one/ApostleBaseV3.f.sol

.PHONY: all buildone clean test deploy flat lint link
