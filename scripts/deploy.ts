const { ethers } = require("hardhat");


// PodFi is deployed to 0xeF625Aa9c3C8140aFBd1C2ff2c25e92D8eeff8bF
// PodFi verified address is https://repo.sourcify.dev/contracts/full_match/534351/0xeF625Aa9c3C8140aFBd1C2ff2c25e92D8eeff8bF

// PodFiPodcast is deployed to 0xB44B7Bb77fBF7ACcb093d513642fF6Cf3A52C62e
// PodFiPodcast verified address is https://repo.sourcify.dev/contracts/full_match/534351/0xB44B7Bb77fBF7ACcb093d513642fF6Cf3A52C62e/

// PodfiAdsMarketplace is deployed to 0xfF002Ca6ef63b04dA543ADC1F56b184A57D5b038
// PodfiAdsMarketplace verified address is https://repo.sourcify.dev/contracts/full_match/534351/0xfF002Ca6ef63b04dA543ADC1F56b184A57D5b038/

async function main() {

  const podFi = await ethers.getContractFactory("PodFiToken");
  const podFiPodcast = await ethers.getContractFactory("PodfiPodcast");
  const podfiAdsMarketplace = await ethers.getContractFactory("PodfiAdsMarketplace");

  const PodFi = await podFi.deploy();
  const PodFiPodcast = await podFiPodcast.deploy();
  const PodfiAdsMarketplace = await podfiAdsMarketplace.deploy();

  await PodFi.deployed();
  await PodFiPodcast.deployed();
  await PodfiAdsMarketplace.deployed();

  console.log(`PodFi is deployed to ${PodFi.address}`);
  console.log(`PodFiPodcast is deployed to ${PodFiPodcast.address}`);
  console.log(`PodfiAdsMarketplace is deployed to ${PodfiAdsMarketplace.address}`);

  // await ethers.run("verify:verify", {
  //   address: address,
  //   contract: [],
  //   constructorArguments: [],
  // });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
