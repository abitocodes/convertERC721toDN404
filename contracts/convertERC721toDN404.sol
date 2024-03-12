// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DN404.sol";
import "./DN404Mirror.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol"; // ERC721 메타데이터 인터페이스 추가

/**
 * @title ConvertERC721toDN404
 * @dev This contract allows locking ERC721 tokens to mint DN404 tokens and vice versa.
 * The DN404 tokens minted will have a 1:1 relationship with the ERC721 tokens locked,
 * and their token IDs will match.
 */
contract ConvertERC721toDN404 is DN404 {
    IERC721 public immutable nftToken; // The ERC721 token contract
    IERC721Metadata public immutable nftMetadata; // ERC721 메타데이터 인터페이스 추가
    DN404Mirror public immutable dn404Mirror; // DN404Mirror 컨트랙트 인스턴스

    mapping(uint256 => bool) private _isTokenLocked; // Mapping to track locked ERC721 tokens

    event TokenLocked(address indexed owner, uint256 indexed tokenId);
    event TokenUnlocked(address indexed receiver, uint256 indexed tokenId);

    constructor(address _nftTokenAddress) {
        require(_nftTokenAddress != address(0), "NFT token address cannot be the zero address");

        nftToken = IERC721(_nftTokenAddress);
        nftMetadata = IERC721Metadata(_nftTokenAddress); // ERC721 메타데이터 인터페이스 초기화

        // DN404Mirror 컨트랙트 인스턴스를 생성하고 주소를 저장
        DN404Mirror mirrorInstance = new DN404Mirror(msg.sender);
        dn404Mirror = mirrorInstance;

        // DN404 컨트랙트 초기화. 여기서는 초기 토큰 공급량과 소유자를 예시 값으로 사용함
        uint96 initialTokenSupply = 0; // 초기 토큰 공급량을 가정한 값
        address initialSupplyOwner = msg.sender; // 초기 공급량 소유자로 배포자를 사용

        _initializeDN404(initialTokenSupply, initialSupplyOwner, address(mirrorInstance));
    }

    // Implements name from DN404.sol abstract contract
    function name() public view override returns (string memory) {
        return "ConvertERC721 to DN404 Token";
    }

    // Implements symbol from DN404.sol abstract contract
    function symbol() public view override returns (string memory) {
        return "CETD";
    }

    // `_tokenURI` 함수 구현
    function _tokenURI(uint256 tokenId) internal view override returns (string memory) {
        // ERC721 토큰의 tokenURI를 직접 조회하여 반환
        return nftMetadata.tokenURI(tokenId);
    }
    
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

    function burnAndUnlock(uint256 tokenId) external {
        require(_isTokenLocked[tokenId], "Token is not locked or already unlocked");

        // Burn the DN404 token with the same token ID
        _burn(msg.sender, tokenId); // Adjust this to match the DN404 burning functionality

        // Unlock the ERC721 token by transferring it back to the caller
        nftToken.transferFrom(address(this), msg.sender, tokenId);

        _isTokenLocked[tokenId] = false;
        emit TokenUnlocked(msg.sender, tokenId);
    }

    function isTokenLocked(uint256 tokenId) external view returns (bool) {
        return _isTokenLocked[tokenId];
    }

    // Override receive to enable contract to receive ether
    receive() external payable override {
        // Optional: 여기에 이더를 받았을 때 수행할 로직을 추가할 수 있습니다.
    }
}
