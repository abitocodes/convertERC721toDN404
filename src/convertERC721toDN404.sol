// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DN404.sol";
import "./DN404Mirror.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "solady/src/utils/LibBitmap.sol";

contract ConvertERC721toDN404 is DN404 {
    using LibBitmap for LibBitmap.Bitmap;

    IERC721 public immutable nftToken; 
    IERC721Metadata public immutable nftMetadata; 
    DN404Mirror public immutable dn404Mirror;

    LibBitmap.Bitmap private _isTokenLockedBitmap; // Using LibBitmap for tracking locked tokens

    event TokenLocked(address indexed owner, uint256 indexed tokenId);
    event TokenUnlocked(address indexed receiver, uint256 indexed tokenId);

    constructor(address _nftTokenAddress) {
        require(_nftTokenAddress != address(0), "NFT token address cannot be the zero address");

        nftToken = IERC721(_nftTokenAddress);
        nftMetadata = IERC721Metadata(_nftTokenAddress);

        DN404Mirror mirrorInstance = new DN404Mirror(msg.sender);
        dn404Mirror = mirrorInstance;

        uint96 initialTokenSupply = 0; 
        address initialSupplyOwner = msg.sender; 

        _initializeDN404(initialTokenSupply, initialSupplyOwner, address(mirrorInstance));

        // Prefill all 10k bits in exists bitmap
        _prefillExistsBitmap(10000);
    }

    function _prefillExistsBitmap(uint256 totalTokens) internal {
        for (uint256 i = 0; i < totalTokens; i += 256) {
            // Set a batch of 256 tokens at a time to save on gas
            _getDN404Storage().exists.setBatch(i, 256);
        }
    }

    function name() public view override returns (string memory) {
        return "ConvertERC721 to DN404 Token";
    }

    function symbol() public view override returns (string memory) {
        return "CETD";
    }

    function _tokenURI(uint256 tokenId) internal view override returns (string memory) {
        return nftMetadata.tokenURI(tokenId);
    }
    
    function lockAndMint(uint256 tokenId) external {
        require(!_isTokenLocked(tokenId), "Token is already locked");
        require(nftToken.ownerOf(tokenId) == msg.sender, "Caller must own the token");

        nftToken.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, tokenId);

        _isTokenLockedBitmap.set(tokenId);
        emit TokenLocked(msg.sender, tokenId);
    }

    function burnAndUnlock(uint256 tokenId) external {
        require(_isTokenLocked(tokenId), "Token is not locked or already unlocked");

        _burn(msg.sender, tokenId);
        nftToken.transferFrom(address(this), msg.sender, tokenId);

        _isTokenLockedBitmap.unset(tokenId);
        emit TokenUnlocked(msg.sender, tokenId);
    }

    function isTokenLocked(uint256 tokenId) external view returns (bool) {
        return _isTokenLockedBitmap.get(tokenId);
    }

    receive() external payable override {
        // Optional: Here, you can add logic when the contract receives ether.
    }

    // Utility function to check if a token is locked
    function _isTokenLocked(uint256 tokenId) internal view returns (bool) {
        return _isTokenLockedBitmap.get(tokenId);
    }
}
