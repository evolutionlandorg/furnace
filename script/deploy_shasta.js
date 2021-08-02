var TronWeb = require('tronweb')

const SETTINGSREGISTRY = {
  base58: "TV7XzfAcDrcpFmRkgCh2gg8wf15Cz9764W",
  hex: "41d1fd927d8bf55bff2dfb8248047bc9881e710cc7"
}
const DrillBaseProxy = {
    base58: "TAAxxdpgahayFisHfe1bbneT2YCrf9S2t5",
    hex: "41023945222c34b091d5cc5eb0ff3975fd80d4afc9"
}
const DrillBase = {
    base58: "TJd8SzG3qRVnezo72aJK8JTAsGdQLvqV46",
    hex: "415eed032022b82dae1c6e850bafb2c12143d70112"
}
const ItemBaseProxy = {
    base58: "TKnQuzSQ2ZoMPb7QmLTE8FMPUeZZcRm4Yi",
    hex: "416ba6a05cb98df548490ff1b4c2de50e5659edeb0"
} 
const ItemBase = {
    base58: "TTZXrEwwE6DNzGZUDom1Asih4PrzRiGRew",
    hex: "41c0f803b77b1043e30e35e9c3aec20190bec5d94e"
}
const FormulaProxy = {
    base58: "TSyoTUJ8jQQsvoYKWQQgMzzEYx2W72FPKS",
    hex: "41ba96e675a47fd2cfd7d17ae5a7eb3e3cd8006bd4"
} 
const Formula = {
    base58: "TLRHVejup8uTJqZSEgW4KeCDXuA2Q2kCWv",
    hex: "41729fd2c9b4c1bbdbfac6e05adc0edb400bfc2440"
}
const MetaDataTellerProxy = {
    base58: "TP7c8ETm1ezDZQ6winReC5XdVoqJDFjvkK",
    hex: "41903043fc250232692f17fe2d07855056d2a1cac5"
}
const MetaDataTeller = {
    base58: "TZFWdktim7BjCDTssTGE9kXRmYD6VzZvQH",
    hex: "41ff6044799bc1a3fe80d535d511e65816690b72f6"
}
const DrillBaseAuthority = {
    base58: "TUk51ZC7qVhgiEVKrH5QtgX5DgdyGHHf5V",
    hex: "41cdee4fbcddc18d66aa15d536478df5d13766bddd"
}
const ObjectOwnershipAuthorityV4 = {
    base58: "TEAzt1iF62HQa2UH7Qk6tDHt2owUYnZG5V",
    hex: "412e1b604ce74250366492d1c676bddfc5114b413b"
}

const tronWeb = new TronWeb({
  fullHost: 'https://api.shasta.trongrid.io',
  headers: { "TRON-PRO-API-KEY": process.env.API_KEY },
  privateKey: process.env.PRIVATE_KEY_SHASTA
})

let params = {
  feeLimit:1_00_000_000,
  callValue:0,
  userFeePercentage:1,
  originEnergyLimit:10_000_000,
  shouldPollResponse:false
}

const app = async () => {
  tronWeb.setDefaultBlock('latest');

  //---------------------upgrade-------------------------//
  let drill_base_proxy = await tronWeb.contract().at(DrillBaseProxy.hex)
  
  console.log(1, await drill_base_proxy.upgradeTo(DrillBase.hex).send(params))
  console.log(2, await drill_base_proxy.initializeContract(SETTINGSREGISTRY.hex).send(params))
  
  let item_base_proxy = await tronWeb.contract().at(ItemBaseProxy.hex)
  console.log(3, await item_base_proxy.upgradeTo(ItemBase.hex).send(params))
  console.log(4, await item_base_proxy.initializeContract(SETTINGSREGISTRY.hex).send(params))

  let formula_proxy = await tronWeb.contract().at(FormulaProxy.hex)
  console.log(5, await formula_proxy.upgradeTo(Formula.hex).send(params))
  console.log(6, await formula_proxy.initializeContract(SETTINGSREGISTRY.hex).send({
      feeLimit:1_000_000_000,
      callValue:0,
      userFeePercentage:1,
      originEnergyLimit:100_000_000,
      shouldPollResponse: false
    }))
   
  let meta_teller_proxy = await tronWeb.contract().at(MetaDataTellerProxy.hex)
  console.log(7, await meta_teller_proxy.upgradeTo(MetaDataTeller.hex).send(params))
  console.log(8, await meta_teller_proxy.initializeContract(SETTINGSREGISTRY.hex).send(params))

  //---------------------auth-------------------------//
  let registry = await tronWeb.contract().at(SETTINGSREGISTRY.hex);
  console.log(9, await drill_base_proxy.setAuthority(DrillBaseAuthority.hex).send(params))
  // CONTRACT_OBJECT_OWNERSHIP
  let objectOwnershipAddr = await registry.addressOf("0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000").call()
  let objectOwnership = await tronWeb.contract().at(objectOwnershipAddr);
  console.log(10, await objectOwnership.setAuthority(ObjectOwnershipAuthorityV4.hex).send(params))
  //---------------------registry-------------------------//
  // CONTRACT_INTERSTELLAR_ENCODER
  let encoderAddr = await registry.addressOf("0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000").call()
  let encoder = await tronWeb.contract().at(encoderAddr)
  console.log(11, await encoder.registerNewObjectClass(DrillBaseProxy.hex, 4).send(params))
  console.log(12, await encoder.registerNewObjectClass(ItemBaseProxy.hex, 5).send(params))
  // CONTRACT_DRILL_BASE 
  console.log(13, await registry.setAddressProperty("0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000", DrillBaseProxy.hex).send(params))
  // CONTRACT_ITEM_BASE
  console.log(14, await registry.setAddressProperty("0x434f4e54524143545f4954454d5f424153450000000000000000000000000000", ItemBaseProxy.hex).send(params))
  // CONTRACT_FORMULA
  console.log(15, await registry.setAddressProperty("0x434f4e54524143545f464f524d554c4100000000000000000000000000000000", FormulaProxy.hex).send(params))
  // CONTRACT_METADATA_TELLER
  console.log(16, await registry.setAddressProperty("0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000", MetaDataTellerProxy.hex).send(params))
  // CONTRACT_LP_GOLD_ERC20_TOKEN
  let drillId = "0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000"
  console.log(17, await meta_teller_proxy.addInternalTokenMeta(drillId, 1, 1000000).send(params))
  console.log(18, await meta_teller_proxy.addInternalTokenMeta(drillId, 2, 5000000).send(params))
  console.log(19, await meta_teller_proxy.addInternalTokenMeta(drillId, 3, 12000000).send(params))
  // FURNACE_ITEM_MINE_FEE
  console.log(20, await registry.setUintProperty("0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000", 5000000).send(params))
  // UINT_ITEMBAR_PROTECT_PERIOD
  console.log(21, await registry.setUintProperty("0x55494e545f4954454d4241525f50524f544543545f504552494f440000000000", 604800).send(params))
  console.log("finished");
};

app();
