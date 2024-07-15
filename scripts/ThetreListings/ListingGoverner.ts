import { ethers } from "hardhat";

async function main() {
  // Deploy the TimelockController
  const minDelay = 0;
  const [deployer] = await ethers.getSigners();
  const proposers = [deployer.address];
  const executors = [deployer.address];


  const TimelockController = await ethers.getContractFactory("TimelockController");
  const timelock = await TimelockController.deploy(minDelay, proposers, executors, deployer.address);
  await timelock.deployed();

  console.log("TimelockController deployed to:", timelock.address);

  const Token = await ethers.getContractFactory("DAOToken");
  const token = await Token.deploy();
  await token.deployed();

  console.log("Token deployed to:", token.address);

  const tx = await token.mint(deployer.address, "1000000000000000000000000");
  await tx.wait();

  console.log("Minted 1,000,000 tokens to deployer. Hash - ", tx.hash);

  // Deploy the ListingGoverner
  const ListingGoverner = await ethers.getContractFactory("ListingGoverner");
  const governor = await ListingGoverner.deploy(token.address, timelock.address);
  await governor.deployed();

  console.log("ListingGoverner deployed to:", governor.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
