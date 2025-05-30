const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const EnergyToken = await hre.ethers.getContractFactory("EnergyToken");
  const energyToken = await EnergyToken.deploy();
  await energyToken.deployed();
  console.log("EnergyToken deployed to:", energyToken.address);

  const GridSwap = await hre.ethers.getContractFactory("GridSwap");
  const gridSwap = await GridSwap.deploy(energyToken.address);
  await gridSwap.deployed();
  console.log("GridSwap deployed to:", gridSwap.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
