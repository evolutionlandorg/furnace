all     :; dapp build
clean   :; dapp clean
test    :; dapp test
deploy  :; dapp create Furnance
lint    :; solhint --max-warnings 0 'src/**/*.sol' 
flatten :; 
	rm -rf 'bin/flatten'
	mkdir -p 'bin/flatten'
	hevm flatten --source-file src/DrillBase.sol >> bin/flatten/DrillBase.f.sol
	hevm flatten --source-file src/DrillBaseAuthority.sol >> bin/flatten/DrillBaseAuthority.f.sol
	hevm flatten --source-file src/DrillBaseProxy.sol >> bin/flatten/DrillBaseProxy.f.sol
	hevm flatten --source-file src/DrillLuckyBox.sol >> bin/flatten/DrillLuckyBox.f.sol
	hevm flatten --source-file src/DrillTakeBack.sol >> bin/flatten/DrillTakeBack.f.sol
	hevm flatten --source-file src/FurnaceProxyAdmin.sol >> bin/flatten/FurnaceProxyAdmin.f.sol
	hevm flatten --source-file src/ObjectOwnershipAuthorityV3.sol >> bin/flatten/ObjectOwnershipAuthorityV3.f.sol
