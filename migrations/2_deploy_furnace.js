var DrillBase = artifacts.require("DrillBase")
var ItemBase = artifacts.require("ItemBase")
var Formula = artifacts.require("Formula")
var MetaDataTeller = artifacts.require("MetaDataTeller")
var DrillTakeBack = artifacts.require("DrillTakeBack")
var DrillLuckyBox = artifacts.require("DrillLuckyBox")
var DrillBaseAuthority = artifacts.require("DrillBaseAuthority")
var ObjectOwnershipAuthorityV4 = artifacts.require("ObjectOwnershipAuthorityV4")
var LandResourceV6 = artifacts.require("LandResourceV6")
var TronWeb = require('tronweb')

const SETTINGSREGISTRY = {
  base58: "TV7XzfAcDrcpFmRkgCh2gg8wf15Cz9764W",
  hex: "41d1fd927d8bf55bff2dfb8248047bc9881e710cc7"
}

const Supervisor = {
  base58: "TA2YGCFuifxkJrkRrnKbugQF5ZVkJzkk4p",
  hex: "4100A1537D251A6A4C4EFFAB76948899061FEA47B9"
}

const LandResourceAuthority = {
  base58: "TQCr6mPg4C3HDKFU72m34Vn8C3PLc3g4sN",
  hex: "419c2622fc3074864a19bf9cc1d8e7b50eb60be31c"
}

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
  callValue: 1000,
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
  tronWeb.setDefaultBlock('latest');
  //---------------------deploy-------------------------//
  await deployer.deploy(DrillBase, SETTINGSREGISTRY.hex);
  let drillBase = await DrillBase.deployed();
  await deployer.deploy(ItemBase, SETTINGSREGISTRY.hex);
  let itemBase = await ItemBase.deployed();
  await deployer.deploy(Formula, SETTINGSREGISTRY.hex);
  let formula = await Formula.deployed();
  await deployer.deploy(MetaDataTeller, SETTINGSREGISTRY.hex);
  let metaDataTeller = await MetaDataTeller.deployed();
  await deployer.deploy(DrillTakeBack, SETTINGSREGISTRY.hex, Supervisor.hex, network);
  let drillTakeBack = await DrillTakeBack.deployed();
  await deployer.deploy(DrillLuckyBox, SETTINGSREGISTRY.hex, drillTakeBack.address, timestamp);
  let drillLuckyBox = await DrillLuckyBox.deployed();
  //---------------------upgrade-------------------------//
  await deployer.deploy(LandResourceV6, SETTINGSREGISTRY.hex, resourceStartTime)
  let landrs = await LandResourceV6.deployed()
  await landrs.setAuthority(LandResourceAuthority.hex)
  console.log("LandResourceV6 setAuthority succeed.")
  //---------------------auth-------------------------//
  let registry = await tronWeb.contract().at(SETTINGSREGISTRY.hex);
  // CONTRACT_LAND_BASE
  let landBaseAddr = await registry.addressOf("0x434f4e54524143545f4c414e445f424153450000000000000000000000000000").call()
  // CONTRACT_APOSTLE_BASE
  let apostleBaseAddr = await registry.addressOf("0x434f4e54524143545f41504f53544c455f424153450000000000000000000000").call()
  await deployer.deploy(DrillBaseAuthority, [drillTakeBack.address]);
  let drillBaseAuthority = DrillBaseAuthority.deployed();
  await drillBase.setAuthority(DrillBaseAuthority.address);
  console.log("DrillBase setAuthority succeed.")
  await deployer.deploy(ObjectOwnershipAuthorityV4, [landBaseAddr, apostleBaseAddr, DrillBase.address, ItemBase.address]);
  let objectOwnershipAuthorityV4 = ObjectOwnershipAuthorityV4.deployed();
  // CONTRACT_OBJECT_OWNERSHIP
  let objectOwnershipAddr = await registry.addressOf("0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000").call()
  let objectOwnership = await tronWeb.contract().at(objectOwnershipAddr);
  await objectOwnership.setAuthority(ObjectOwnershipAuthorityV4.address);
  console.log("ObjectOwnership setAuthority succeed.")
  //---------------------registry-------------------------//
  // CONTRACT_INTERSTELLAR_ENCODER
  let encoderAddr = await registry.addressOf("0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000").call()
  let encoder = await tronWeb.contract().at(encoderAddr); 
  await encoder.registerNewObjectClass(DrillBase.address, 4).send(params);
  console.log("encoder registerNewObjectClass DrillBase succeed.")
  await encoder.registerNewObjectClass(ItemBase.address, 5).send(params);
  console.log("encoder registerNewObjectClass ItemBase succeed.")
  // CONTRACT_DRILL_BASE 
  await registry.setAddressProperty("0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000", DrillBase.address).send(params)
  console.log("registry CONTRACT_DRILL_BASE succeed.")
  // CONTRACT_ITEM_BASE
  await registry.setAddressProperty("0x434f4e54524143545f4954454d5f424153450000000000000000000000000000", ItemBase.address).send(params)
  console.log("registry CONTRACT_ITEM_BASE succeed.")
  // CONTRACT_FORMULA
  await registry.setAddressProperty("0x434f4e54524143545f464f524d554c4100000000000000000000000000000000", Formula.address)
  console.log("registry CONTRACT_FORMULA succeed.")
  // CONTRACT_METADATA_TELLER
  await registry.setAddressProperty("0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000", MetaDataTeller.address);
  console.log("registry CONTRACT_METADATA_TELLER succeed.")
  // CONTRACT_LP_GOLD_ERC20_TOKEN
  // await registry.setAddressProperty("0x434f4e54524143545f4c505f474f4c445f45524332305f544f4b454e00000000", LP_GOLD.hex);
  // CONTRACT_LP_WOOD_ERC20_TOKEN
  // await registry.setAddressProperty("0x434f4e54524143545f4c505f574f4f445f45524332305f544f4b454e00000000", LP_WOOD.hex);
  // CONTRACT_LP_WATER_ERC20_TOKEN
  // await registry.setAddressProperty("0x434f4e54524143545f4c505f57415445525f45524332305f544f4b454e000000", LP_WATER.hex);
  // CONTRACT_LP_FIRE_ERC20_TOKEN
  // await registry.setAddressProperty("0x434f4e54524143545f4c505f464952455f45524332305f544f4b454e00000000", LP_FIRE.hex);
  // CONTRACT_LP_SOIL_ERC20_TOKEN
  // await registry.setAddressProperty("0x434f4e54524143545f4c505f534f494c5f45524332305f544f4b454e00000000", LP_SOIL.hex);
  let drillId = "0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000"
  await metaDataTeller.addInternalTokenMeta(drillId, 1, 1000000)
  await metaDataTeller.addInternalTokenMeta(drillId, 2, 5000000)
  await metaDataTeller.addInternalTokenMeta(drillId, 3, 12000000)
  console.log("metaDataTeller addInternalTokenMeta succeed.")
  // FURNACE_ITEM_MINE_FEE
  await registry.setUintProperty("0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000", 5000000).send(params)
  console.log("registry FURNACE_ITEM_MINE_FEE succeed.")
  // UINT_ITEMBAR_PROTECT_PERIOD
  await registry.setUintProperty("0x55494e545f4954454d4241525f50524f544543545f504552494f440000000000", 604800).send(params)
  console.log("registry UINT_ITEMBAR_PROTECT_PERIOD succeed.")
}

