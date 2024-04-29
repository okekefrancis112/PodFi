// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract PodfiPodcast is PausableUpgradeable, ReentrancyGuardUpgradeable {
    // Enum for defining the status of a podcast
    enum PodcastStatus {
        Ongoing,
        Ended
    }

    // Struct for storing podcast details
    struct Podcast {
        address creator;
        string creatorIceCandidates;
        PodcastStatus status;
        mapping(address => string) listenerIceCandidates;
    }

    // Counter for total number of podcasts
    uint public numPodcasts;
    // Mapping to store podcasts
    mapping (uint => Podcast) public podcasts;

    // Mapping to track admin addresses
    mapping(address => bool) public admins;

    // Events
    event PodcastStarted(uint podcastId);
    event PodcastEnded(uint podcastId);
    event PodcastParticipantJoined(uint podcastId, address participant, string iceCandidates);

    // Modifier to restrict access to only admins
    modifier onlyAdmin() {
        require(admins[msg.sender], "NOT_AN_ADMIN");
        _;
    }

    // Modifier to restrict access to only the creator of a specific podcast
    modifier onlyPodcastCreator(uint podcastId) {
        require(podcastId < numPodcasts && podcasts[podcastId].creator == msg.sender, "NOT_A_PODCAST_CREATOR");
        _;
    }

    // Contract constructor
    constructor() {
        admins[msg.sender] = true; // Set the deployer as an admin
    }

    // Function to get all podcasts
    // function getPodcasts() external view returns (Podcast[] memory) {
    //     return podcasts;
    // }
    // function getPodcasts() external view returns (Podcast[] memory) {
    //     Podcast[] memory podcastList = new Podcast[](numPodcasts); // Initialize an array to store podcasts
    //     // Loop through all podcasts and add them to the array
    //     for (uint i = 0; i < numPodcasts; i++) {
    //         podcastList[i] = podcasts[i];
    //     }
    //     return podcastList; // Return the array of podcasts
    // }

// Function to start a new podcast
    function startPodcast(string memory iceCandidates) external {
        Podcast storage newPodcast = podcasts[numPodcasts++]; // Increment the counter and get the next podcast slot
        newPodcast.creator = msg.sender; // Set the creator of the podcast
        newPodcast.creatorIceCandidates = iceCandidates; // Set the creator's ICE candidates
        newPodcast.status = PodcastStatus.Ongoing; // Set the status of the podcast to ongoing

        emit PodcastStarted(numPodcasts - 1); // Emit event for new podcast
    }

    // Function for a participant to join a podcast
    function joinPodcast(uint podcastId, string memory iceCandidates) external {
        require(podcastId < numPodcasts, "PODCAST_NOT_FOUND");
        require(podcasts[podcastId].status == PodcastStatus.Ongoing, "PODCAST_NOT_STARTED");

        podcasts[podcastId].listenerIceCandidates[msg.sender] = iceCandidates; // Set listener's ICE candidates

        emit PodcastParticipantJoined(podcastId, msg.sender, iceCandidates); // Emit event for participant joining
    }

    // Function to end a podcast
    function endPodcast(uint podcastId) external onlyPodcastCreator(podcastId) {
        require(podcastId < numPodcasts, "PODCAST_NOT_FOUND");
        require(podcasts[podcastId].status == PodcastStatus.Ongoing, "PODCAST_NOT_STARTED");

        podcasts[podcastId].status = PodcastStatus.Ended; // Update the status of the podcast

        emit PodcastEnded(podcastId); // Emit event for podcast ending
    }
}
