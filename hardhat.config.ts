import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import { vars } from "hardhat/config";
import '@openzeppelin/hardhat-upgrades';
import "@nomicfoundation/hardhat-chai-matchers";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    theta: {
      url: "https://eth-rpc-api-testnet.thetatoken.org/rpc",
      accounts: [vars.get("PRIVATE_KEY")],
    },
    hardhat: {
      forking: {
        url: "https://eth-rpc-api-testnet.thetatoken.org/rpc",
      }
    }
  },
  
  
};

export default config;
