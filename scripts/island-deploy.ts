import hre from 'hardhat';
import {
    config as envConfig
} from 'dotenv';
import { AddressLike } from 'ethers';
  
envConfig();
  
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const fundingAccount = process.env.FUNDING_ACCOUNT_ADDRESS as AddressLike;
    const maxLevel = 3;

    // Deploy the contract
    const factory = await hre.ethers.getContractFactory("Island");
    const contract = await factory.deploy(fundingAccount, maxLevel);
    const response = await contract.waitForDeployment();
    const address = await response.getAddress()

    console.log("Contract deployed to:", address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
