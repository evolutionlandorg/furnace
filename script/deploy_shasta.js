var TronWeb = require('tronweb')

const SETTINGSREGISTRY = {
  base58: "TV7XzfAcDrcpFmRkgCh2gg8wf15Cz9764W",
  hex: "41d1fd927d8bf55bff2dfb8248047bc9881e710cc7"
}
const DrillBaseProxy = {
    base58: "TWNk96NpUTZvEeT47MDQ97zmHxgWe69taB",
    hex: "41dfd61370192c21a50ad23d7c9c923412f473a1df"
}
const DrillBase = {
    base58: "TUhiEK1h94E7zoSboFSjxFtPT3aGKAwxjs",
    hex: "41cd7c221a84ad4ec4a1aafd806e0ed37bd1b97744"
}
const ItemBaseProxy = {
    base58: "TZJCVbWW2uKPBSGxbUbrVcF69L7c5HSw3T",
    hex: "41ffe25f4c1ee40c1634ac1090576a230491edd1a1"
} 
const ItemBase = {
    base58: "TJWcz2uhk5vBX9Md87ZhwfAJktg8TkrxdJ",
    hex: "415db1eba73d75a230b9fbe6b5eb42e04df721af4d"
}
const FormulaProxy = {
    base58: "TKxg7wV5DaLwhpnFKYEntcDeqbbuERSiq8",
    hex: "416d977ab88003b7b6274af72e9ecf3ad4f6c698ec"
} 
const Formula = {
    base58: "TC6oAAvsxDx51sNRyauHfYqeUjRQ3agSH5",
    hex: "41175fad1d518b90885a4c35659e6cd42fcb10a325"
}
const MetaDataTellerProxy = {
    base58: "TXSxj55WTMPAhCnbozfh5Qdv9xnrDLitVN",
    hex: "41eb9a5f260d5da64ffde842f4cd8569a1eba70cb8"
}
const MetaDataTeller = {
    base58: "TEDrVmbDFpNjpuK8M4ZMUpnoYstAnmVvPt",
    hex: "412ea5a0384666e85d6f3209a9492a5c056ee0d20b"
}
const DrillBaseAuthority = {
    base58: "TRpyoteHBZbsFohYoxMRdZ41scsVPamBSV",
    hex: "41adf3ac1955425df68b49a4022a650a7b566cd450"
}
const ObjectOwnershipAuthorityV4 = {
    base58: "TUMgJUGK3ZBxFJRQwRw3sXZBfZiPXoYp2K",
    hex: "41c9b2344f05c2f05a61187016542f476eede0430c"
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
      shouldPollResponse:true
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
