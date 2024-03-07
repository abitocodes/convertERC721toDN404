// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DN404.sol";
import "./DN404Mirror.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title ConvertERC721toDN404
 * @dev This contract allows locking ERC721 tokens to mint DN404 tokens and vice versa.
 * The DN404 tokens minted will have a 1:1 relationship with the ERC721 tokens locked,
 * and their token IDs will match.
 */
contract ConvertERC721toDN404 is DN404 {
    IERC721 public immutable nftToken; // The ERC721 token contract
    mapping(uint256 => bool) private _isTokenLocked; // Mapping to track locked ERC721 tokens

    event TokenLocked(address indexed owner, uint256 indexed tokenId);
    event TokenUnlocked(address indexed receiver, uint256 indexed tokenId);

    constructor(address _nftTokenAddress, address _mirrorAddress)
        DN404("DN404 Token", "DN404", _mirrorAddress) // Assuming DN404 constructor accepts these parameters
    {
        require(_nftTokenAddress != address(0), "NFT token address cannot be the zero address");
        nftToken = IERC721(_nftTokenAddress);
    }

    /**
     * @dev Locks an ERC721 token and mints a corresponding DN404 token.
     * The DN404 token will have the same token ID as the locked ERC721 token.
     * @param tokenId The token ID of the ERC721 token to lock and mint a DN404 token for.
     */
    function lockAndMint(uint256 tokenId) external {
        require(!_isTokenLocked[tokenId], "Token is already locked");
        require(nftToken.ownerOf(tokenId) == msg.sender, "Caller must own the token");

        // Lock the ERC721 token by transferring it to this contract
        nftToken.transferFrom(msg.sender, address(this), tokenId);

        // Mint a DN404 token with the same token ID to the caller
        _mint(msg.sender, tokenId); // Adjust this to match the DN404 minting functionality

        _isTokenLocked[tokenId] = true;
        emit TokenLocked(msg.sender, tokenId);
    }

    /**
     * @dev Burns a DN404 token and unlocks the corresponding locked ERC721 token.
     * The DN404 token to be burned must have the same token ID as the ERC721 token to unlock.
     * @param tokenId The token ID of the DN404 token to burn and the ERC721 token to unlock.
     */
    function burnAndUnlock(uint256 tokenId) external {
        require(_isTokenLocked[tokenId], "Token is not locked or already unlocked");

        // Burn the DN404 token with the same token ID
        _burn(msg.sender, tokenId); // Adjust this to match the DN404 burning functionality

        // Unlock the ERC721 token by transferring it back to the caller
        nftToken.transferFrom(address(this), msg.sender, tokenId);

        _isTokenLocked[tokenId] = false;
        emit TokenUnlocked(msg.sender, tokenId);
    }

    /**
     * @dev Checks if a token is locked in the contract.
     * @param tokenId The token ID to check.
     * @return bool True if the token is locked, false otherwise.
     */
    function isTokenLocked(uint256 tokenId) external view returns (bool) {
        return _isTokenLocked[tokenId];
    }
}
