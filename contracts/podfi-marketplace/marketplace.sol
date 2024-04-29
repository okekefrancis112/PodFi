// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title Podfi Decentralized Marketplace Smart Contract
 * @dev This contract manages the interactions between advertisers and podcast creators in a decentralized marketplace.
 * It allows advertisers to create and manage ads, and podcast creators to approve or reject ads.
 */
contract PodfiAdsMarketplace is PausableUpgradeable, ReentrancyGuardUpgradeable {
  ///@dev advertisers ID
  uint public nextAdvertiserId;
  ///@dev podcast creator ID
  uint public nextPodcastCreatorId;
  ///@dev advert ID
  uint public nextAdId;

  ///@notice Adstatus to track adverts statues
  enum AdStatus {
    Inactive,
    Active
  }

  /**
   * @dev Advertiser Structure
   * @param id Advertiser ID
   * @param account Advertiser account
   * @param name Advertiser name
   * @param isVerified Boolean to check if the Advertiser is verified
   */
  struct Advertiser {
    uint id;
    address account;
    string name;
    bool isVerified;
  }

  /**
   * @dev PodcastCreator Structure
   * @param id PodcastCreator ID
   * @param account Account of the Podcaster
   * @param name Name of the Podcaster
   * @param isVerified Boolean to Check if the Podcaster is verified
   * @param averageEngagement Engagement data from the Podcaster channel (Number of Engagement/Listeners)
   * @param ads Amount of ads the Podcaster currently has on the channel (active and inactive)
   */
  struct PodcastCreator {
    uint id;
    uint averageEngagement;
    address account;
    string channelName;
    string name;
    bool isVerified;
  }

  /**
   * @dev Ad Structure
   * @param id Id of the advert
   * @param advertiser Creator of the advert
   * @param content Content of the advert (video link on ipfs)
   * @param tag Tag of the advert
   * @param minimumeTargetEngagement minimum requirement of engagements for podcast creators to run the ads on their channels
   * @param cost Cost of the advert (rewards to the podcaster for running the ads)
   * @param status Status of the advert
   * @param numberOfDays The number of days the advert will be available
   * @param runnerFunds funds required to run the ads on the podcaster channels (multiples of the current ads cost )  cost * (numberOFChannels to run) = runnerFunds
   */
  struct Ad {
    uint id;
    address advertiser;
    string content; //url to ads vids
    string tag;
    uint minimumeTargetEngagement;
    uint cost;
    AdStatus status;
    uint numberOfDays;
    uint runnerFunds;
    uint numberOfChannels;
  }

  /**
   * @dev  SubsribedAd structure
   * @param id id of the advert
   * @param expirationDate expiration date of the advertisement subscription
   */
  struct SubsribedAd {
    uint id;
    uint expirationDate;
  }

  ///@dev mapping of advertisers details to their addresses
  mapping(address => Advertiser) public advertisers;
  ///@dev mapping of podcastcreator details to their addresses
  mapping(address => PodcastCreator) public podcastCreators;
  ///@dev mapping of podcastcreator address to their wallet balance
  mapping(address => uint) public pcWalletBalance;
  ///@dev mapping podcaster address to subsribed adverts ids (active and inactive), to the subscription structure
  mapping(address => mapping(uint => SubsribedAd)) public subsribedAds;
  ///@dev mapping adverts ID to the corresponding Adverts
  mapping(uint => Ad) public adverts;
  ///@dev mapping of admins
  mapping(address => bool) public admins;

  //************************* EVENTS ********************************/
  ///@dev AdCreated events emitted when an ad is created successfully
  event AdCreated(uint adId, address advertiser, string tag);
  ///@dev AdStatusChanged events emitted when an ad status is updated successfully by admin
  event AdStatusChanged(uint adId, AdStatus status);
  ///@dev AdSubscribed events emitted when an ad is subscribed to
  event AdSubscribed(uint adId);
  ///@dev RunnerFund events emitted when ad runner funds is incremented successfully
  event RunnerFund(uint adId, uint amount);
  ///@dev RegisterationSuccess events emitted when a registeration is successful
  event RegisterationSuccess(address _registrant, uint id);

  //************************* ERRORS  ******************************/
  error FundsForAdsUnavailable();

  /**
   * @dev Modifier to check if the caller is the contract an admin.
   */
  modifier onlyAdmin() {
    require(admins[msg.sender], "NOT_AN_ADMIN");
    _;
  }

  /**
   * @dev Modifier to check if the caller is a registered advertiser.
   */
  modifier onlyAdvertiser() {
    require(advertisers[msg.sender].account == msg.sender, "NOT_AN_ADVERTISER");
    _;
  }

  /**
   * @dev Modifier to check if the caller is a registered podcast creator.
   */
  modifier onlyPodcastCreator() {
    require(podcastCreators[msg.sender].account == msg.sender, "NOT_A_PODCAST_CREATOR");
    _;
  }

  /**
   * @dev Modifier to check if the caller is a verified advertiser.
   */
  modifier onlyVerifiedAdvertiser() {
    require(advertisers[msg.sender].isVerified, "ADVERTISER_IS_NOT_VERIFIED");
    _;
  }

  /**
   * @dev Modifier to check if the caller is a verified podcast creator.
   */
  modifier onlyVerifiedPodcastCreator() {
    require(podcastCreators[msg.sender].isVerified, "PODCASTOR_IS_NOT_VERIFIED");
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
  function getAds() external view returns (Ad[] memory) {
    uint adSize = nextAdId;
    Ad[] memory ads = new Ad[](adSize);
    for (uint i = 0; i < adSize; i++) {
      ads[i] = adverts[i];
    }
    return ads;
  }

  /**
   * @dev Function to get an advertiser
   * @param avertiser Address of the advertiser to get.
   */
  function getAdvertiser(address avertiser) external view returns (Advertiser memory) {
    return advertisers[avertiser];
  }

  /**
   * @dev Function to get a Podcaster
   * @param podcaster Address of the podcaster to get.
   */
  function getPodcaster(address podcaster) external view returns (PodcastCreator memory, SubsribedAd[] memory) {
    uint adSize = nextAdId;
    SubsribedAd[] memory _subscribedAds = new SubsribedAd[](adSize);

    for (uint i = 0; i < adSize; i++) {
      // Check if the ad ID exists in the podcast creator's ads mapping
      if (subsribedAds[podcaster][i].expirationDate != 0) {
        _subscribedAds[i] = subsribedAds[podcaster][i];
      }
    }
    return (podcastCreators[podcaster], _subscribedAds);
  }

  //***************************** ADVERTISER FUNCTIONS *********************/
  /**
   * @dev Registers a new advertiser in the marketplace.
   * @param name The name of the advertiser.
   */
  function registerAdvertiser(string memory name) external {
    require(advertisers[msg.sender].account != msg.sender, "ALREADY_REGISTERED_ADVERTISER");
    Advertiser storage newAdvertiser = advertisers[msg.sender];
    newAdvertiser.id = nextAdvertiserId;
    newAdvertiser.account = msg.sender;
    newAdvertiser.name = name;
    newAdvertiser.isVerified = false;
    emit RegisterationSuccess(msg.sender, nextAdvertiserId);
    // Increment the nextAdvertiserId for the next registration
    nextAdvertiserId++;
  }

  /**
   * @dev Creates a new ad in the marketplace.
   * @param content The content of the ad.
   * @param tag The tag of the new ad.
   * @param cost The cost of the ad.
   * @param numberOfDays The duration of the ad in days.
   * @param targetEngagement The minimumTargetEngagement required to run the ad on any channel.
   * @param numberOfChannels The number of channels to run the ad on
   */
  function createAd(
    string memory content,
    string memory tag,
    uint cost,
    uint numberOfDays,
    uint targetEngagement,
    uint numberOfChannels
  ) external payable onlyAdvertiser onlyVerifiedAdvertiser whenNotPaused {
    uint runnerFunds = cost * numberOfChannels;
    require(msg.value >= runnerFunds, "INSUFFICIENT_FUNDS_TO_RUN_ADS");

    Ad memory newAd = Ad({
      id: nextAdId,
      advertiser: msg.sender,
      content: content,
      tag: tag,
      minimumeTargetEngagement: targetEngagement,
      cost: cost,
      status: AdStatus.Active,
      numberOfDays: numberOfDays,
      numberOfChannels: numberOfChannels,
      runnerFunds: runnerFunds
    });

    adverts[nextAdId] = newAd;

    emit AdCreated(nextAdId, msg.sender, tag);
    nextAdId++;
  }

  /**
   *
   * @param adId id of the ad
   */
  function incrementRunnerFunds(
    uint adId,
    uint amount
  ) external onlyAdvertiser onlyVerifiedAdvertiser whenNotPaused nonReentrant {
    Ad storage ad = adverts[adId];
    require(msg.sender == ad.advertiser && amount > 0, "UNAUTHORIZED_NOT_CREATOR_OF_AD");
    ad.runnerFunds = ad.runnerFunds + amount;
    emit RunnerFund(adId, amount);
  }

  /**@dev Function to withdraw runner funds */
  function withdrawAdsFunds(uint adId) external onlyAdvertiser onlyVerifiedAdvertiser whenNotPaused nonReentrant {
    Ad storage ad = adverts[adId];
    require(ad.advertiser == msg.sender, "UNAUTHORIZED_WITHDRAWER");
    uint amount = ad.runnerFunds;
    ad.runnerFunds = 0;
    payable(address(this)).transfer(amount);
  }

  //***************************** PODCASTERS FUNCTIONS *********************/
  /**
   * @dev Registers a new podcast creator in the marketplace.
   * @param name The name of the podcast creator.
   */
  function registerPodcastCreator(
    string memory name,
    string memory channelName,
    uint averageEngagement
  ) external whenNotPaused {
    require(podcastCreators[msg.sender].account != msg.sender, "ALREADY_REGISTERED_PODCAST_CREATORS");

    PodcastCreator storage newPodcaster = podcastCreators[msg.sender];
    newPodcaster.id = nextPodcastCreatorId;
    newPodcaster.account = msg.sender;
    newPodcaster.channelName = channelName;
    newPodcaster.name = name;
    newPodcaster.averageEngagement = averageEngagement;
    emit RegisterationSuccess(msg.sender, nextPodcastCreatorId);
    //increment the next podcaster ID
    nextPodcastCreatorId++;
  }

  /**@dev Function to withdraw funds for podcasters */
  function withdrawPodFunds() external onlyPodcastCreator onlyVerifiedPodcastCreator whenNotPaused nonReentrant {
    uint amount = pcWalletBalance[msg.sender];
    payable(address(this)).transfer(amount);
  }

  /**
   * @dev Subscribes to an ad by a advert creator.
   * @param adId The ID of the ad to be subscribed.
   */
  function subscribeToAd(uint adId) external onlyPodcastCreator onlyVerifiedPodcastCreator whenNotPaused nonReentrant {
    Ad storage ad = adverts[adId];
    PodcastCreator storage pc = podcastCreators[msg.sender];
    SubsribedAd storage sAd = subsribedAds[msg.sender][adId];
    require(sAd.expirationDate < block.timestamp, "ADVERTS_IS_CURRENT_RUNNING");
    require(ad.minimumeTargetEngagement >= pc.averageEngagement, "MINIMUM_ENGAGEMENT_FOR_RUNNING_AD_NOT_MET");
    if ((ad.runnerFunds - ad.cost) <= 0) {
      revert FundsForAdsUnavailable();
    }
    ad.runnerFunds = ad.runnerFunds - ad.cost;
    pcWalletBalance[msg.sender] = pcWalletBalance[msg.sender] + ad.cost;
    sAd.expirationDate = block.timestamp * ad.numberOfDays * 1 days;
    sAd.id = ad.id;
    emit AdSubscribed(adId);
  }

  //******************************* ADMIN FUNCTIONS  *********************/
  /**
   * @dev Verifies a podcast creator. Only the contract admins can call this function.
   * @param podcastCreator The address of the podcast creator to be verified.
   */
  function verifyPodcastCreator(address podcastCreator) external onlyAdmin {
    podcastCreators[podcastCreator].isVerified = true;
  }

  /**
   * @dev Verifies an advertiser. Only the contract admins can call this function.
   * @param advertiser The address of the advertiser to be verified.
   */
  function verifyAdvertiser(address advertiser) external onlyAdmin {
    advertisers[advertiser].isVerified = true;
  }

  /**@dev Function to Unpause Contract */
  function unpausePMP() external whenPaused onlyAdmin {
    _unpause();
  }

  /**@dev Function to pause Contract */
  function pausePMP() external whenNotPaused onlyAdmin {
    _pause();
  }
}
