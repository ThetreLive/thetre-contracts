import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const Thetre = await ethers.getContractFactory("Thetre");
    // replace with timelock address
    const thetre = await Thetre.deploy("0xB4e7d6cF228a6cB316FeEcf4700BE133257eFF47");

    await thetre.deployed();

    console.log("ThetreTicket deployed to:", thetre.address);

    const ticketPrice = ethers.utils.parseEther("10");
    await thetre.setTicketPrice(ticketPrice);
    console.log("Ticket price set to 10 TFUEL.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });