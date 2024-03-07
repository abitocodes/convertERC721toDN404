// scripts/deploy.js
async function main() {
  const ConvertERC721toDN404 = await ethers.getContractFactory("ConvertERC721toDN404");
  const convertERC721toDN404 = await ConvertERC721toDN404.deploy("<NFT_CONTRACT_ADDRESS>", "<DN404MIRROR_CONTRACT_ADDRESS>");

  await convertERC721toDN404.deployed();

  console.log("ConvertERC721toDN404 deployed to:", convertERC721toDN404.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });
