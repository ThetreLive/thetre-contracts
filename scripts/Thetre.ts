import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const Thetre = await ethers.getContractFactory("Thetre");
    // replace with timelock address
    const thetre = await Thetre.deploy("");

    await thetre.deployed();

    console.log("ThetreTicket deployed to:", thetre.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });