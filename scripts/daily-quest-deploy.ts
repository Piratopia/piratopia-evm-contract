import hre from 'hardhat';
import {
    config as envConfig
} from 'dotenv';
import { AddressLike } from 'ethers';
  
envConfig();
  
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const initialFee = hre.ethers.parseEther("0.01"); // 0.01 ETH as the check-in fee
    const fundingAccount = process.env.FUNDING_ACCOUNT_ADDRESS as AddressLike; // Replace with your funding account address

    // Deploy the contract
    const DailyQuest = await hre.ethers.getContractFactory("DailyQuest");
    const checkinContract = await DailyQuest.deploy(initialFee, fundingAccount);
    const response = await checkinContract.waitForDeployment();
    const address = await response.getAddress()

    console.log("Contract deployed to:", address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
