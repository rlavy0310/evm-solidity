import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    bscTest: {
      url: 'https://bsc-testnet.blockpi.network/v1/rpc/public	', // 输入您的RPC URL
      chainId: 97, // (hex: 0x504),
      accounts: [process.env.SECRET_KEY],
    },
  },
};

export default config;
