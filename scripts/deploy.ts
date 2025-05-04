import { ethers } from "hardhat";

async function main() {
  const ERC20 = await ethers.getContractFactory("ERC20");
  const erc20 = await ERC20.deploy("MyERC20", "MET");

  await erc20.waitForDeployment();

  console.log("MyERC20Contract deployed to:", erc20.target);
}

main().catch((error) => {
  console.error("Error deploying contract:", error);
  process.exitCode = 1;
});
