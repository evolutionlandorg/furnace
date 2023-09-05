all      :; source .env && dapp --use solc:0.6.7 build
buildone :; dapp --use solc:0.4.24 buildone
clean    :; dapp clean
test     :; dapp test
deploy   :; dapp create Furnance
flat     :; source .env && dapp flat
lint     :; solhint --max-warnings 0 'src/**/*.sol'
link     :;
	rm -rf 'one'
	mkdir 'one'
	ln -s $(PWD)/lib/land/flat/LandResourceV5.sol $(PWD)/one/LandResourceV5.f.sol

.PHONY: all buildone clean test deploy flat lint link
