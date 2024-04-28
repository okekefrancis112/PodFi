// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract PodfiPodcast is PausableUpgradeable, ReentrancyGuardUpgradeable {
  enum PodcastStatus {
    Ongoing,
    Ended
  }

  struct Podcast {
    address creator;
    creator creatorIceCandidates;
    PodcastStatus status;
    mapping(address => string) listenerIceCandidate;
  }

  Podcast[] public podcasts;

  mapping(address => bool) public admins;

  event PodcastStarted(uint podcastId);
  event PodcastEnded(uint podcastId);
  event PodcastParticipantJoined(uint podcastId, address participant, string iceCandidates);

  modifier onlyAdmin() {
    require(admins[msg.sender], "NOT_AN_ADMIN");
    _;
  }

  /**
   * @dev Modifier to check if the caller is a registered podcast creator.
   */
  modifier onlyPodcastCreator(uint podcastId) {
    require(podcasts[podcastId].creator == msg.sender, "NOT_A_PODCAST_CREATOR");
    _;
  }

  /**
   * @dev Contract constructor. Sets the owner to the deployer's address.
   */
  constructor() {
    admins[msg.sender] = true;
  }

  /**
   * @dev Function to get all ads on the platform
   */
  function getPodcasts() external view returns (Podcast[] memory) {
    uint numPodcasts = ;
    Podcast[] memory _podcasts = new Podcast[](adSize);
    for (uint i = 0; i < numPodcasts; i++) {
      _podcasts[i] = podcasts[i];
    }
    return _podcasts;
  }

  function startPodcast(string podcastId, string iceCandidates) {
    if (podcasts[podcastId]) {
      revert("Podcast ID taken!"):
    }

    Podcast storage _podcast = podcasts[podcastId];

    _podcast.creator = msg.sender;
    _podcast.creatorIceCandidates = iceCandidates;
    _podcast.status = PodcastStatus.Started;

    podcasts[podcastId] = _podcast;

    emit PodcastStarted(podcastId);
  }

  function joinPodcast(string podcastId, string iceCandidates) {
    require(podcasts[podcastId], "PODCAST_NOT_FOUND");
    require(podcasts[podcastId].status == PodcastStatus.Started, "PODCAST_NOT_STARTED");

    podcasts[podcastId].listenerIceCandidate[msg.sender] = iceCandidates;

    emit PodcastParticipantJoined(podcastId, msg.sender, iceCandidates);
  }

  function endPodcast(string podcastId) onlyPodcastCreator(podcastId) {
    require(podcasts[podcastId].status == PodcastStatus.Started, "PODCAST_NOT_STARTED");

    Podcast storage _podcast = podcasts[podcastId];
    _podcast.status = PodcastStatus.Ended;
  }
}
