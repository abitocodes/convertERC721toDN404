// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/convertERC721toDN404.sol"; // 스마트 컨트랙트의 경로를 확인해주세요.

contract DeployConvertERC721toDN404 is Script {
    function run() external {
        string memory nftContractAddress = vm.envString("NFT_CONTRACT_ADDRESS");
        if (bytes(nftContractAddress).length == 0) {
            revert("The NFT contract address is not set correctly, please check your .env file.");
        }

        vm.startBroadcast();

        ConvertERC721toDN404 convertERC721toDN404 = new ConvertERC721toDN404(nftContractAddress);

        vm.stopBroadcast();

        console.log("ConvertERC721toDN404 deployed to:", address(convertERC721toDN404));
    }
}
