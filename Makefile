all    :; dapp build
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create Furnance
lint   :; solhint --max-warnings 0 'src/**/*.sol' 
