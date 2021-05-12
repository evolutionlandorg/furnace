var DrillBase = artifacts.require("DrillBase")
var ItemBase = artifacts.require("ItemBase")
var Formula = artifacts.require("Formula")
var MetaDataTeller = artifacts.require("MetaDataTeller")
var DrillTakeBack = artifacts.require("DrillTakeBack")
var DrillLuckyBox = artifacts.require("DrillLuckyBox")
var DrillBaseAuthority = artifacts.require("DrillBaseAuthority")
var ObjectOwnershipAuthorityV4 = artifacts.require("ObjectOwnershipAuthorityV4")
var ObjectOwnership = artifacts.require("ObjectOwnership")
var SettingsRegistry = artifacts.require("SettingsRegistry")

const SETTINGSREGISTRY = {
  base58: "TV7XzfAcDrcpFmRkgCh2gg8wf15Cz9764W",
  hex: "41d1fd927d8bf55bff2dfb8248047bc9881e710cc7"
}

const Supervisor = {
  base58: "TA2YGCFuifxkJrkRrnKbugQF5ZVkJzkk4p",
  hex: "4100A1537D251A6A4C4EFFAB76948899061FEA47B9"
}

let network;
let timestamp = 1620804505;

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
  
  //---------------------auth-------------------------//
  let settingsRegistry = SettingsRegistry.at(SETTINGSREGISTRY.hex);
  let landBaseAddr = await settingsRegistry.addressOf("0x434f4e54524143545f4c414e445f424153450000000000000000000000000000")
  console.log(landBaseAddr)
  let apostleBaseAddr = await settingsRegistry.addressOf("0x434f4e54524143545f41504f53544c455f424153450000000000000000000000")
  console.log(apostleBaseAddr)
  deployer.deploy(DrillBaseAuthority, [drillTakeBack.address]);
  let drillBaseAuthority = DrillBaseAuthority.deployed();
  await drillBase.setAuthority(drillBaseAuthority.address);
  deployer.deploy(ObjectOwnershipAuthorityV4, [landBaseAddr, apostleBaseAddr, drillBase.address, itemBase.address]);
  let objectOwnershipAuthorityV4 = ObjectOwnershipAuthorityV4.deployed();
  let objectOwnershipAddr = await settingsRegistry.addressOf("0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000")
  console.log(objectOwnershipAddr)
  let objectOwnership = ObjectOwnership.at(OBJECTOWNERSHIP.hex);
  await objectOwnership.setAuthority(objectOwnershipAuthorityV4.address);
  //---------------------registry-------------------------//
  let encoderAddr = await settingsRegistry.address("0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000")
  await encoder.registerNewObjectClass(drillBase.address, 4)
  // TODO
}

