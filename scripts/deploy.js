// deploy.js:
require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  const nftContractAddress = process.env.NFT_CONTRACT_ADDRESS;
  if (!nftContractAddress) {
    throw new Error("NFT 컨트랙트 주소가 올바르게 설정되지 않았습니다. .env 파일을 확인해주세요.");
  }

  const ConvertERC721toDN404 = await ethers.getContractFactory("ConvertERC721toDN404");
  const convertERC721toDN404 = await ConvertERC721toDN404.deploy(nftContractAddress);
  
  // `deployTransaction`이 블록체인에 성공적으로 채굴되기를 기다립니다.
  await convertERC721toDN404.deployTransaction.wait();

  // 컨트랙트 주소를 로깅
  console.log("ConvertERC721toDN404 deployed to:", convertERC721toDN404.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
