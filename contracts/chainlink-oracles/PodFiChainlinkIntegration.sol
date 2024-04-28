// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PodFiContract is ChainlinkClient, ERC721 {
    using Chainlink for Chainlink.Request;

    uint256 private fee;
    address private oracle;
    bytes32 private jobId;

    // NFT metadata structure
    struct NFTData {
        uint256 id;
        string contentUri;
        bool isExclusive;
    }

    mapping(uint256 => NFTData) public nfts;
    uint256 public nextNftId;

    // Chainlink Listener Data
    struct ListenerData {
        uint256 demographicData;
        uint256 engagementData;
    }

    mapping(address => ListenerData) public listenerData;

    constructor() ERC721("PodFiNFT", "PFNFT") {
        setPublicChainlinkToken();

        //Avalanche Fuji:
        oracle = 0x022EEA14A6010167ca026B32576D6686dD7e85d2;

        //GET>uint256:
        jobId = ca98366cc7314957b8c012c72f05aeeb;
        fee = 0.1 * 10 ** 18; // Chainlink fee
    }

    // Function to request listener data from Chainlink oracle
    function requestListenerData(address listener) public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // Add listener address to the request
        request.add("listener", addressToString(listener));
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // Callback function for Chainlink oracle
    function fulfill(bytes32 _requestId, uint256 _demographicData, uint256 _engagementData) public recordChainlinkFulfillment(_requestId) {
        ListenerData storage data = listenerData[msg.sender];
        data.demographicData = _demographicData;
        data.engagementData = _engagementData;
    }

    // Function to mint NFTs
    function mintNFT(address recipient, string memory contentUri, bool isExclusive) public {
        uint256 nftId = nextNftId++;
        nfts[nftId] = NFTData(nftId, contentUri, isExclusive);
        _mint(recipient, nftId);
    }

    function addressToString(address _addr) private pure returns(string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);

        str[0] = "0";
        str[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}