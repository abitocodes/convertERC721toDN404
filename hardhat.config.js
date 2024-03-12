require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { PRIVATE_KEY, KLAYTN_RPC_URL } = process.env;

module.exports = {
  solidity: "0.8.24",
  networks: {
    cypress: {
      url: KLAYTN_RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 8217, // 클레이튼 메인넷 체인 ID
    }
  },
};
