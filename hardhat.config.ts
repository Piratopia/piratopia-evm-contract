import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import {
  config as envConfig
} from 'dotenv';

envConfig();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  defaultNetwork: 'seiDevnet',
  networks: {
    seiDevnet: {
      url: 'https://evm-rpc-arctic-1.sei-apis.com',
      chainId: 713715,
      accounts: [`0x${process.env.DEPLOY_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: {
      seiDevnet: process.env.DEPLOY_EXPLORER_API_KEY as string,
    },
    customChains: [
      {
        network: "seiDevnet",
        chainId: 713715,
        urls: {
          apiURL: "https://seitrace.com/arctic-1/api",
          browserURL: "https://seitrace.com"
        }
      },
    ],
  }
};

export default config;
