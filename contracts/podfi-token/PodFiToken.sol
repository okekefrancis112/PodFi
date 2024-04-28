// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PodFiToken is ERC20 {
    // Token distribution amounts
    uint256 private constant AUDIENCE_LISTEN_REWARD = 5 * 10**18; // 5 POD
    uint256 private constant AUDIENCE_LIKE_REWARD = 3 * 10**18; // 3 POD
    uint256 private constant CREATOR_LISTEN_REWARD = 10 * 10**18; // 10 POD per 10 listens
    uint256 private constant CREATOR_LIKE_REWARD = 4 * 10**18; // 4 POD

    // Owner address for initial token distribution and management
    address public owner;

    // Struct to hold content engagement data
    struct Content {
        uint256 listens;
        uint256 likes;
        address creator;
    }

    // Mapping to store content engagement data
    mapping(uint256 => Content) public contents;

    // Modifier to restrict certain functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(uint256 initialSupply) ERC20("PodFi", "POD") {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }

    // Function to record a listen and reward audience
    function recordListen(uint256 contentId, address listener) external {
        Content storage content = contents[contentId];
        content.listens++;
        _mint(listener, AUDIENCE_LISTEN_REWARD); // Reward the listener

        // Check and reward creator per 10 listens
        if (content.listens % 10 == 0) {
            _mint(content.creator, CREATOR_LISTEN_REWARD);
        }
    }

    // Function to record a like and reward audience
    function recordLike(uint256 contentId, address liker) external {
        Content storage content = contents[contentId];
        content.likes++;
        _mint(liker, AUDIENCE_LIKE_REWARD); // Reward the liker
        _mint(content.creator, CREATOR_LIKE_REWARD); // Reward the creator
    }

    // Function for the owner to add content
    function addContent(uint256 contentId, address creator) external onlyOwner {
        require(contents[contentId].creator == address(0), "Content already exists");
        contents[contentId] = Content(0, 0, creator);
    }

    // Function to change the owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}

// Deployed Contract Address: 0x4efe6df3497A20c85b8fD5AC7105D61078EAC955
// https://testnet.bscscan.com/address/0x4efe6df3497A20c85b8fD5AC7105D61078EAC955#code 
