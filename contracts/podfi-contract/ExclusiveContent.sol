// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract ExclusiveContentNFT is ERC721Enumerable, Ownable, VRFConsumerBase {
    using Strings for uint256;

    // Base URI for metadata
    string private _baseTokenURI;

    // Chainlink VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;

    // Mapping from tokenId to podcast content URI
    mapping(uint256 => string) public tokenContentURIs;

    // Event emitted when a new NFT is minted
    event Minted(address indexed owner, uint256 tokenId, string contentURI);

    // Constructor
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address vrfCoordinator,
        address link,
        bytes32 _keyHash,
        uint256 _fee
    )
        ERC721(name, symbol)
        VRFConsumerBase(vrfCoordinator, link)
    {
        _baseTokenURI = baseTokenURI;
        keyHash = _keyHash;
        fee = _fee;
    }

    // Mint new exclusive content NFT
    function mintNFT() external returns (uint256) {
        // Ensure the caller has approval to mint
        require(_isApprovedOrOwner(msg.sender, type(uint256).max), "Not approved to mint");

        // Request randomness from Chainlink VRF
        bytes32 requestId = requestRandomness(keyHash, fee);

        // Generate a unique tokenId based on the random requestId
        uint256 tokenId = uint256(requestId);

        // Mint the NFT
        _safeMint(msg.sender, tokenId);

        // Emit Minted event
        emit Minted(msg.sender, tokenId, tokenContentURIs[tokenId]);

        return tokenId;
    }

    // Set base URI for metadata
    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    // Set token URI for a specific token ID
    function setTokenURI(uint256 tokenId, string memory tokenURI) external onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }

    // Override function to return the URI for a token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(_baseTokenURI, tokenId.toString(), ".json"));
    }

    // Callback function called by Chainlink VRF with the random result
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // Use the randomness to set the content URI for the NFT
        uint256 tokenId = uint256(requestId);
        tokenContentURIs[tokenId] = generateContentURI(randomness);
    }

    // Function to generate a content URI based on randomness
    function generateContentURI(uint256 randomness) internal pure returns (string memory) {
        //  content URI
        return string(abi.encodePacked("https://example.com/content/", randomness));
    }
}
