import { ethers } from "hardhat";

async function main() {
  const proxyWBTC = "0x28Cac6604A8f2471E19c8863E8AfB163aB60186a";
  const usdcAddress = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"; // neecd to fix
  const wbtcAddress = "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6"; // need to fix

  const predict = await ethers.deployContract("Prediction", [proxyWBTC, usdcAddress, wbtcAddress], );

  await predict.waitForDeployment();

  console.log(`Predict contract deployed to ${predict.target}`);

  // Wait for the transaction to be mined, and get the transaction receipt
  const receipt = await predict.deploymentTransaction();
  console.log(`Gas used: ${receipt?.gasPrice?.toString()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
