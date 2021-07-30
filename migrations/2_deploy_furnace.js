var DrillBase = artifacts.require("DrillBase")
var ItemBase = artifacts.require("ItemBase")
var Formula = artifacts.require("Formula")
var MetaDataTeller = artifacts.require("MetaDataTeller")
var DrillTakeBack = artifacts.require("DrillTakeBack")
var DrillLuckyBox = artifacts.require("DrillLuckyBox")
var DrillBaseAuthority = artifacts.require("DrillBaseAuthority")
var ObjectOwnershipAuthorityV4 = artifacts.require("ObjectOwnershipAuthorityV4")
var OwnedUpgradeabilityProxy = artifacts.require("OwnedUpgradeabilityProxy")
// var LandResourceV6 = artifacts.require("LandResourceV6")
var TronWeb = require('tronweb')

const SETTINGSREGISTRY = {
  base58: "TV7XzfAcDrcpFmRkgCh2gg8wf15Cz9764W",
  hex: "41d1fd927d8bf55bff2dfb8248047bc9881e710cc7"
}

const Supervisor = {
  base58: "TA2YGCFuifxkJrkRrnKbugQF5ZVkJzkk4p",
  hex: "4100A1537D251A6A4C4EFFAB76948899061FEA47B9"
}

// const LandResourceAuthority = {
//   base58: "TQCr6mPg4C3HDKFU72m34Vn8C3PLc3g4sN",
//   hex: "419c2622fc3074864a19bf9cc1d8e7b50eb60be31c"
// }

const tronWeb = new TronWeb({
  fullHost: 'https://api.shasta.trongrid.io',
  headers: { "TRON-PRO-API-KEY": process.env.API_KEY },
  privateKey: process.env.PRIVATE_KEY_SHASTA
})

let network;
let timestamp = 1620804505;
let resourceStartTime = 1579422612;
let params = {
  feeLimit:1000000000,
  callValue: 0,
  shouldPollResponse:true
}

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
      await asyncDeploy(deployer, network, accounts);
  });
};

async function asyncDeploy(deployer, network, accounts) {
  if (network == "shasta") {
    network = 200001
  } else if (network == "mainnet") {
    network = 200000
  }
  //---------------------deploy-------------------------//
  // DrillBaseProxy
  tronWeb.setDefaultBlock('latest');
  let drill_base_abi = [
    ...OwnedUpgradeabilityProxy.abi,
    ...DrillBase.abi
  ]
  let drill_base_proxy = await tronWeb.contract().new({
    name: "DrillBaseProxy",
    abi: drill_base_abi,
    bytecode: OwnedUpgradeabilityProxy.bytecode,
    ...params
  });
  deployer.logger.log("DrillBaseProxy" + ':\n    (base58) ' + tronWeb.address.fromHex(drill_base_proxy.address) + '\n    (hex) ' + drill_base_proxy.address)
  await deployer.deploy(DrillBase);
  let drillBase = await DrillBase.deployed();

  // ItemBaseProxy 
  let item_base_abi = [
    ...OwnedUpgradeabilityProxy.abi,
    ...ItemBase.abi
  ]
  let item_base_proxy = await tronWeb.contract().new({
    name: "ItemBaseProxy",
    abi: item_base_abi,
    bytecode: OwnedUpgradeabilityProxy.bytecode,
    ...params
  })
  deployer.logger.log("ItemBaseProxy" + ':\n    (base58) ' + tronWeb.address.fromHex(item_base_proxy.address) + '\n    (hex) ' + item_base_proxy.address)
  await deployer.deploy(ItemBase);
  let itemBase = await ItemBase.deployed();
  
  // FormulaProxy
  let formula_abi = [
    ...OwnedUpgradeabilityProxy.abi,
    ...Formula.abi
  ]
  let formula_proxy = await tronWeb.contract().new({
    name: "FormulaProxy",
    abi: formula_abi,
    bytecode: OwnedUpgradeabilityProxy.bytecode,
    ...params
  })
  deployer.logger.log("FormulaProxy" + ':\n    (base58) ' + tronWeb.address.fromHex(formula_proxy.address) + '\n    (hex) ' + formula_proxy.address)
  await deployer.deploy(Formula);
  let formula = await Formula.deployed();

  // MetaDataTellerProxy
  let meta_teller_abi = [
    ...OwnedUpgradeabilityProxy.abi,
    ...MetaDataTeller.abi
  ]
  let meta_teller_proxy = await tronWeb.contract().new({
    name: "MetaDataTellerProxy",
    abi: meta_teller_abi,
    bytecode: OwnedUpgradeabilityProxy.bytecode,
    ...params
  })
  deployer.logger.log("MetaDataTellerProxy" + ':\n    (base58) ' + tronWeb.address.fromHex(meta_teller_proxy.address) + '\n    (hex) ' + meta_teller_proxy.address)
  await deployer.deploy(MetaDataTeller);
  let metaDataTeller = await MetaDataTeller.deployed();

  await deployer.deploy(DrillTakeBack, SETTINGSREGISTRY.hex, Supervisor.hex, network);
  let drillTakeBack = await DrillTakeBack.deployed();
  await deployer.deploy(DrillLuckyBox, SETTINGSREGISTRY.hex, drillTakeBack.address, timestamp);
  let drillLuckyBox = await DrillLuckyBox.deployed();

  //---------------------upgrade-------------------------//
  // tron-contracts landrs migration
  //---------------------auth-------------------------//
  let registry = await tronWeb.contract().at(SETTINGSREGISTRY.hex);
  // CONTRACT_LAND_BASE
  let landBaseAddr = await registry.addressOf("0x434f4e54524143545f4c414e445f424153450000000000000000000000000000").call()
  // CONTRACT_APOSTLE_BASE
  let apostleBaseAddr = await registry.addressOf("0x434f4e54524143545f41504f53544c455f424153450000000000000000000000").call()
  await deployer.deploy(DrillBaseAuthority, [drillTakeBack.address]);
  let drillBaseAuthority = DrillBaseAuthority.deployed();
  await deployer.deploy(ObjectOwnershipAuthorityV4, [landBaseAddr, apostleBaseAddr, drill_base_proxy.address, item_base_proxy.address]);
  let objectOwnershipAuthorityV4 = ObjectOwnershipAuthorityV4.deployed();
}

