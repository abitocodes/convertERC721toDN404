require("dotenv").config(); // 환경 변수를 로드합니다.
const hre = require("hardhat");

async function main() {
  // .env 파일에서 DEPLOYER_ADDRESS 값을 읽어옵니다.
  const deployerAddress = process.env.DEPLOYER_ADDRESS;

  if (!deployerAddress) {
    console.error("DEPLOYER_ADDRESS is not defined in your .env file");
    process.exit(1);
  }

  console.log("Deploying DN404Mirror with deployer address:", deployerAddress);

  // DN404Mirror 컨트랙트를 가져옵니다.
  const DN404Mirror = await hre.ethers.getContractFactory("DN404Mirror");

  // DN404Mirror 컨트랙트를 배포합니다. 생성자 인자로 deployerAddress를 전달합니다.
  const dn404Mirror = await DN404Mirror.deploy(deployerAddress);

  await dn404Mirror.deployed();

  console.log("DN404Mirror deployed to:", dn404Mirror.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
