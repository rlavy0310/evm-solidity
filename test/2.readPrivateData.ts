const ethers = require("ethers");

const bsc_test = 'https://bsc-testnet.blockpi.network/v1/rpc/public';
const provider = new ethers.JsonRpcProvider(bsc_test);

const address = '0x76395032F29F3e4215dee481635BD8B868004da5' 

// use maplocation function in the contract 
const slot = `0xb9cccf7ff387e44a4aeaf20dd80e750924b264e8a7cf32e2688f1613d8a1aaa1s`

const main = async () => {
    console.log("read slot data")
    const privateData = await provider.getStorage(address, slot)
    console.log("mapping[0xABC] calue is: ", ethers.getAddress(ethers.dataSlice(privateData, 12)))    
}

main()
