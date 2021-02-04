const nervos = require('../nervos')
const { abi } = require('./compiled_cross_chain_demo.js')

const tx0 = {
  from: '0x4b5ae4567ad5d9fb92bc9afd6a657e6fa13a2523',
  privateKey: '0x5f0258a4778057a8a7d97809bd209055b2fbafa654ce7d31ec7191066b9225e6',
  nonce: 999999,
  quota: 1000000000,
  chainId: 3,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

// contract contract instance
const crossTokenContract = new nervos.appchain.Contract(abi, "0x27Ec3678e4d61534AB8A87cF8FEB8aC110dDeda5")

function sendToSideChain() {
  nervos.appchain
  .getBlockNumber()
  .then(current => {
    tx0.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    // deploy contract
    return crossTokenContract
      .methods
      .sendToSideChain(
        2,
        "0x10bDd1684100bbcE6C17E97DB9a3779A000b350B",
        "0x" + "7".padStart(64, "0")
        )
      .send(tx0)
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return nervos.listeners.listenToTransactionReceipt(txRes.hash)
    } else {
      throw new Error('No Transaction Hash Received')
    }
  })
  .then(receipt => {
    // console.log(receipt)
    if (!receipt.errorMessage) {
        console.log('Success')
        console.log(receipt)
    } else {
        throw new Error(receipt.errorMessage)
    }
  })
  .catch(err => {
      console.log(err)
  })
}

function recvFromSideChain(proof) {
  nervos.appchain
  .getBlockNumber()
  .then(current => {
    tx0.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    // deploy contract
    return crossTokenContract
      .methods
      .recvFromSideChain(proof)
      .send(tx0)
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return nervos.listeners.listenToTransactionReceipt(txRes.hash)
    } else {
      throw new Error('No Transaction Hash Received')
    }
  })
  .then(receipt => {
    // console.log(receipt)
    if (!receipt.errorMessage) {
        console.log('Success')
        console.log(receipt)
    } else {
        throw new Error(receipt.errorMessage)
    }
  })
  .catch(err => {
      console.log(err)
  })
}

recvFromSideChain("0xf90debf901708080843b9aca009410bdd1684100bbce6c17e97db9a3779a000b350b80b8a43c057446000000000000000000000000000000000000000000000000000000000000000300000000000000000000000027ec3678e4d61534ab8a87cf8feb8ac110ddeda500000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000783024b330280b84188694e066aab57e43c8f306bf88f84111eb08461bc971f9cf87d863536ed4104c9a5fb1f84fddc3ce1efcf89666c2b34bec9c3095679f322bc8387d245f1f1fd0080a025854d609892240456f4c4c810cbdf69cfa728a251f50c1579f378f6a20d0f17b840d2bdee2f7bbf540e1bef0a081f317bc8d99eb0777e6fd9e30cc1ddc220a17a0c2a18d56b4c1727149a2571a4ad25f1ff58f631c6a4ab3cd518d2fd695313acc2f90206823a1cb9010000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f8dbf8d99410bdd1684100bbce6c17e97db9a3779a000b350be1a0e5a288d01ffd6a4cda0cb8852dc8151642eabb7c87cccbe82c25178d16675c87b8a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000300000000000000000000000027ec3678e4d61534ab8a87cf8feb8ac110ddeda512bf14d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c025a025854d609892240456f4c4c810cbdf69cfa728a251f50c1579f378f6a20d0f17c0f9040aa068009624f29362679d588b0ac4079b3418812d89674912be0c222bb68e7a7106a00563a53b4e0303eb605704311e96e9809cc9cffc2ac53ec352317e3f4886fe8aa025854d609892240456f4c4c810cbdf69cfa728a251f50c1579f378f6a20d0f17a0f61ed42b7d76df380515df2e6d6ea330c76d3ab99c1858eeb587d050210826ecb901000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000001000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000083024add88ffffffffffffffff823a1c860165dd0d575580b902530ace044200000000000000307864393931343537333739303838343261656537663235623934356164656238613634326533346465363135653637336130306235366563356466383231306366dc4a020000000000000000000000000004000000000000002a0000000000000030783137663334383764663966393333313936393630326266323033313635616266383836613065643141000000000000008e0ed9feb759910410c415e35dc32d7f5ce15b6166d26b2331bdefcfe334327475b259d84ad797da85a44f73d6aee5ad3a9fb95618489a317924ec61fb6382d6012a0000000000000030783038313034656565366332343062383536646532363064626138396565333133616261343162306341000000000000001f5545e8693468593c5318d8a68442f6b2960723c4ef27145d8a03f82df7e5de48617ba0cd0d4eb138253224a4e7f7c5788e1703d966a048ef00cfb069c61934002a000000000000003078643433323962323830626161613565326465313964376235636636656366396130633738363531644100000000000000e086657f79018def1920045f42cc1dd2d21516e6d20642a9a87f06358b6892fb7076dabc0f0ad08b92c09f379160f72a34f5ba5432531a0806452f0ae42d452b012a0000000000000030783637346133656663396566353732356564396435666334376162613562636131633730313631643741000000000000005445532e82245c148ba4e4f6b2306740213db0ec04e367473293cc7909a6bedb0c8e5db43915c46c8bf5d160a2edc2bccf19c3fd1d154461e467b1f1b5d502c000100294674a3efc9ef5725ed9d5fc47aba5bca1c70161d7f90408a0347d25bf4f24e839612f89000898abb643bf650e92a40f0ccae917fa268cdc3fa056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421b901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000083024ade88ffffffffffffffff80860165dd0d636c80b902530ace044200000000000000307834373735656239386530363762643634326335646263633164653262313830383464626230666461356236353430353130313631383137623539633165663338dd4a020000000000000000000000000004000000000000002a00000000000000307830383130346565653663323430623835366465323630646261383965653331336162613431623063410000000000000055098b6b048e7dc98ede148d7f2b8e00588b170438b4c6ec9f63f8736f9471c4437e1f6be1a797fce9a9c591fe11910e7c0bc021996ffd047f0556b024d497d4012a000000000000003078643433323962323830626161613565326465313964376235636636656366396130633738363531644100000000000000cc88bd8b32c41ad7f1c96d548d28a8565e738ef9fdf82c9fc2f85af6c97c57353bff6ce5e51f83366755b01428d2dda21e9465f4c8a700de5112592f1f63f7ed002a000000000000003078363734613365666339656635373235656439643566633437616261356263613163373031363164374100000000000000e3c06d8e9c0813104a666bee3c6817ee0ca4132701e6d50aa69c4b30e0bd279812ff2a91a2ef5fd9bdd7feb11b805c608460245be3fc11c8673e82974ac9c771012a0000000000000030783137663334383764663966393333313936393630326266323033313635616266383836613065643141000000000000005de5567dee331eab864637855a53b3ea332d65a61ceddf8dfbe3d123b1bfa65671cef96965e69840c7d5a88dd26126a71e57147ff5751148be208d7d55521ec20010029417f3487df9f9331969602bf203165abf886a0ed1b902530ace044200000000000000307834633738303162313435333339623131333337363338316430636165343363356132313234613334643565636435313362303734663962323431343064396635de4a020000000000000000000000000004000000000000002a00000000000000307836373461336566633965663537323565643964356663343761626135626361316337303136316437410000000000000091776206ec353f733919c1d35bd8500f5e7698d9cb4d61525cc639fad4b9ef04332eb479b5c9277cc3030a9f604601a44aacbe07e67e5d59e03f831cf9dc712e002a0000000000000030783038313034656565366332343062383536646532363064626138396565333133616261343162306341000000000000004cb599698763f2399d240353a5b693b4215d21d7375f59931378283996165acd28aeeeae128c0ea78f587908976cadc674b746d3d328b4a613edd7c226b01ae5012a00000000000000307864343332396232383062616161356532646531396437623563663665636639613063373836353164410000000000000001e57e22ec6b3348ab08dde62030e4a6da472964b3ee7307fd6a9898f7ca50b0715e6c9e443caecb9da53e35d2a84f9952bbb4ac35537e41f97c1419d3804508012a0000000000000030783137663334383764663966393333313936393630326266323033313635616266383836613065643141000000000000005cc66d9cb9093315b7cd04411e4bf3f63aa7652aa2bd5b848f1f12d7adafce5a6e5e7dd74c5de76f61c1a8d2d942b3439efce9c6d521b2a7c8a26c1ff373e883011002")