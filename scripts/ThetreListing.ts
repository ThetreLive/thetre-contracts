import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    const Thetre = await ethers.getContractFactory("Thetre");
    const thetre = Thetre.attach("0x19648bD235C758C7a54BC4B7e4d8Faf67a8a44EE");


    let tx = await thetre.listMovie("Game Changers", "0x63fffdbb50cd4e77dff7259da12cf522734ebab63fd4ca17644b212a9c89ebca")
    await tx.wait()

    const ticket = await thetre.movieTicket("Game Changers")
    console.log(ticket)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });