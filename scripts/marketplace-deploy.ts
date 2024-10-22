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
    const feeRate = 100; // 1%

    // Deploy the contract
    const factory = await hre.ethers.getContractFactory("Marketplace");
    const contract = await factory.deploy(fundingAccount, feeRate);
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
