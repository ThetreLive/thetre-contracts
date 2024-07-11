import { ethers, upgrades } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const ThetreTicket = await ethers.getContractFactory("ThetreTicket");
    const thetreTicket = await upgrades.deployProxy(ThetreTicket, ["ThetreTicket", "THT", "https://base.token.uri/", deployer.address], { initializer: 'initialize' });

    await thetreTicket.deployed();

    console.log("ThetreTicket deployed to:", thetreTicket.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });