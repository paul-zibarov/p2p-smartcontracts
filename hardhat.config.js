require("@nomiclabs/hardhat-waffle");
require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");
require('hardhat-abi-exporter');
require("dotenv").config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("pk", "Prints the list of accounts", async (taskArgs, hre) => {
  console.log(process.env.PK);
});

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "bscTestnet",
  networks: {
    bscTestnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
      accounts: [process.env.PK],
      gas: 2000000,
      gasPrice: "auto",
    }
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },  
  },
  //size-contracts
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: false,
  },
  //export-abi
  //clear-abi
  abiExporter: {
    path: './abi',
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
    pretty: false,
  },
  etherscan: {
    apiKey: {
        bscTestnet: "",
    }
  }
};