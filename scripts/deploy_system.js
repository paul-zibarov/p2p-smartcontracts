const addresses = require('../addresses');

const hre = require("hardhat");
const fs = require('fs');

async function main() {
  // await deployERC721("ERC721 Token", "T721");
  // await deployERC1155("ERC1155 Token", "T1155");
  // await deployERC20("ERC20 Token", "T20", "18", "1000000000000000000000000000");
  // await deployP2P();
}

async function deployERC721(name, symbol) {
  const ERC721 = await hre.ethers.getContractFactory("ERC721Enumerable");
  let token = await ERC721.deploy();
  console.log("ERC721 Implementation address:", token.address);

  const ERC721Proxy = await hre.ethers.getContractFactory("ERC721Proxy");
  const tokenProxy = await ERC721Proxy.deploy(token.address);
  console.log("ERC721 Proxy address:", tokenProxy.address);

  token = ERC721.attach(tokenProxy.address);
  await token.initialize(name, symbol)
}

async function deployERC1155(name, symbol) {
  const ERC1155 = await hre.ethers.getContractFactory("ERC1155");
  let token = await ERC1155.deploy();
  console.log("ERC1155 Implementation address:", token.address);

  const ERC1155Proxy = await hre.ethers.getContractFactory("ERC1155Proxy");
  const tokenProxy = await ERC1155Proxy.deploy(token.address);
  console.log("ERC1155 Proxy address:", tokenProxy.address);

  token = ERC1155.attach(tokenProxy.address);
  await token.initialize(name, symbol);
}

async function deployERC20(name, symbol, decimals, totalSupply) {
  const ERC20 = await hre.ethers.getContractFactory("ERC20");
  let token = await ERC20.deploy(name, symbol, decimals, totalSupply);
  console.log("ERC20 address:", token.address);
}

async function deployP2P() {
  const P2P = await hre.ethers.getContractFactory("P2P");
  let p2p = await P2P.deploy();
  console.log("P2P Implementation address:", p2p.address);

  const P2PProxy = await hre.ethers.getContractFactory("P2PProxy");
  let p2pProxy = await P2PProxy.deploy(p2p.address);
  console.log("P2P Proxy address:", p2pProxy.address);
  
  p2p = P2P.attach(p2pProxy.address);
  await p2p.updateAllowedNFT(addresses.erc1155Proxy, true)
  await p2p.updateAllowedNFT(addresses.erc721Proxy, true)
}

main().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});