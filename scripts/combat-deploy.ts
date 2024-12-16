import hre from 'hardhat';
import {
    config as envConfig
} from 'dotenv';
import { AddressLike } from 'ethers';
  
envConfig();
  
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const initialFee = hre.ethers.parseEther("0"); // 0.01 ETH as the check-in fee
    const fundingAccount = process.env.FUNDING_ACCOUNT_ADDRESS as AddressLike; // Replace with your funding account address

    // Deploy the contract
    const factory = await hre.ethers.getContractFactory("Combat");
    const contract = await factory.deploy(fundingAccount, initialFee);
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
