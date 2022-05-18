import { addresses } from "../addresses";

const hre = require("hardhat");
const fs = require('fs');

async function main() {
  await deployBEP721("BEP721 Token", "T721");
  await deployBEP1155("BEP1155 Token", "T1155");
  await deployBEP20("BEP20 Token", "T20", "18", "1000000000000000000000000000");
  await deployP2P();
}

async function deployBEP721(name, symbol) {
  const BEP721 = await hre.ethers.getContractFactory("BEP721Enumerable");
  let token = await BEP721.deploy();
  console.log("BEP721 Implementation address:", token.address);

  const BEP721Proxy = await hre.ethers.getContractFactory("BEP721Proxy");
  const tokenProxy = await BEP721Proxy.deploy(token.address);
  console.log("BEP721 Proxy address:", tokenProxy.address);

  token = await BEP721.attach(tokenProxy.address);
  token.initialize(name, symbol)

}

async function deployBEP1155(name, symbol) {
  const BEP1155 = await hre.ethers.getContractFactory("BEP1155");
  let token = await BEP1155.deploy();
  console.log("BEP1155 Implementation address:", token.address);

  const BEP1155Proxy = await hre.ethers.getContractFactory("BEP1155Proxy");
  const tokenProxy = await BEP1155Proxy.deploy(token.address);
  console.log("BEP1155 Proxy address:", tokenProxy.address);

  token = await BEP1155.attach(tokenProxy.address);
  await token.initialize(name, symbol);
}

async function deployBEP20(name, symbol, decimals, totalSupply) {
  const BEP20 = await hre.ethers.getContractFactory("BEP20");
  let token = await BEP20.deploy(name, symbol, decimals, totalSupply);
  console.log("BEP20 address:", token.address);
}

async function deployP2P() {
  const P2P = await hre.ethers.getContractFactory("P2P");
  let p2p = await P2P.deploy();
  console.log("P2P Implementation address:", p2p.address);

  const P2PProxy = await hre.ethers.getContractFactory("P2PProxy");
  let p2pProxy = await P2PProxy.deploy(p2p.address);
  console.log("P2P Proxy address:", p2pProxy.address);
  
  p2p = await P2P.attach(p2pProxy.address);
  await p2p.updateAllowedNFT(addresses.bep1155Proxy, true)
  await p2p.updateAllowedNFT(addresses.bep721Proxy, true)
}

main().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});