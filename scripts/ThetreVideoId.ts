import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    const Thetre = await ethers.getContractFactory("Thetre");
    const thetre = Thetre.attach("0x19648bD235C758C7a54BC4B7e4d8Faf67a8a44EE");


    let tx = await thetre.setMovieVideo("Game Changers", "stream_37d4vvm62yujs23rjgmi273aq")
    await tx.wait()

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });