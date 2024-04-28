// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from  "@openzeppelin/contracts/utils/Counters.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PodFiPlatform is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _listenerId;
    Counters.Counter private _podcastId;

    ERC20 public podToken; // PodFi's native token
    ERC721 public exclusiveContent; // NFT for exclusive content

    struct Listener {
        uint256 id;
        address account;
        uint256 tokensEarned;
        uint256 lastUpdateTime;
        uint256 stakedAmount;
    }

    struct Podcast {
        uint256 id;
        address creator;
        string name;
        uint256 averageEngagement;
        mapping(uint256 => Ad) ads;
    }

    struct Ad {
        uint256 id;
        address advertiser;
        string content;
        uint256 cost;
        uint256 durationDays;
        uint256 expirationTimestamp;
        bool active;
    }

    mapping(address => Listener) public listeners;
    mapping(uint256 => Podcast) public podcasts;
    mapping(uint256 => Ad) public ads;

    uint256 public stakingDuration; // Duration for staking in seconds.
    uint256 public rewardAmount; // Reward amount users will receive.
    uint256 public startTime; // Start time of the staking period.

    event TokensEarned(address indexed listener, uint256 amount);
    event PodcastCreated(uint256 indexed podcastId, address indexed creator);
    event Staked(address indexed listener, uint256 amount);
    event Withdrawn(address indexed listener, uint256 amount);
    event RewardPaid(address indexed listener, uint256 reward);
    event TokensRedeemed(address indexed listener, uint256 amount);

    constructor(
        address _podToken,
        address _exclusiveContent,
        uint256 _stakingDuration,
        uint256 _rewardAmount
    ) {
        podToken = ERC20(_podToken);
        exclusiveContent = ERC721(_exclusiveContent);
        stakingDuration = _stakingDuration;
        rewardAmount = _rewardAmount;
    }

    // Function to create a new podcast
    function createPodcast(string memory name) external {
        _podcastId.increment();
        podcasts[_podcastId.current()] = Podcast(_podcastId.current(), msg.sender, name, 0);
        emit PodcastCreated(_podcastId.current(), msg.sender);
    }

    // Function for a listener to earn tokens
    function earnTokens(address listener, uint256 amount) external onlyOwner {
        listeners[listener].tokensEarned += amount;
        emit TokensEarned(listener, amount);
    }

    // Function to allow users to stake tokens.
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(block.timestamp >= startTime, "Staking period has not started");

        // Transfer tokens from the user to this contract.
        podToken.transferFrom(msg.sender, address(this), amount);

        listeners[msg.sender].stakedAmount += amount;
        listeners[msg.sender].lastUpdateTime = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    // Function to allow users to withdraw their staked tokens and rewards.
    function withdraw() external {
        uint256 amount = listeners[msg.sender].stakedAmount;
        require(amount > 0, "Nothing to withdraw");
        require(block.timestamp >= startTime + stakingDuration, "Staking period is not over");

        uint256 reward = calculateReward(msg.sender);
        listeners[msg.sender].stakedAmount = 0;

        // Transfer staked tokens and rewards back to the user.
        podToken.transfer(msg.sender, amount);
        podToken.transfer(msg.sender, reward);

        emit Withdrawn(msg.sender, amount);
        emit RewardPaid(msg.sender, reward);
    }

    // Function to calculate the listener's reward based on their engagement.
    function calculateReward(address listener) internal view returns (uint256) {
        uint256 lastUpdate = listeners[listener].lastUpdateTime;
        if (lastUpdate == 0 || lastUpdate >= startTime + stakingDuration) {
            return 0;
        }

        uint256 stakingTime = block.timestamp - lastUpdate;
        return (stakingTime * rewardAmount) / stakingDuration;
    }

    // Function for a listener to redeem tokens
    function redeemTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(listeners[msg.sender].tokensEarned >= amount, "Not enough tokens to redeem");

        listeners[msg.sender].tokensEarned -= amount;
        podToken.transfer(msg.sender, amount);

        emit TokensRedeemed(msg.sender, amount);
    }

    // Function to provide analytics on listener engagement and token rewards
    function getListenerAnalytics(address listener) external view returns (uint256 tokensEarned, uint256 lastUpdateTime) {
        return (listeners[listener].tokensEarned, listeners[listener].lastUpdateTime);
    }

    // Function to mint NFTs tied to exclusive podcast content
    function mintExclusiveContent(address to, string memory tokenURI) external onlyOwner {
        _podcastId.increment();
        uint256 newTokenId = _podcastId.current();
        exclusiveContent.mint(to, newTokenId);
        exclusiveContent.setTokenURI(newTokenId, tokenURI);
    }

    // Owner function to start the staking period.
    function startStaking() external onlyOwner {
        require(startTime == 0, "Staking has already started");
        startTime = block.timestamp;
    }
}