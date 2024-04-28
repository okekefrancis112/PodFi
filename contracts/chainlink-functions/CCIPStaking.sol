// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/CCIPInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrossChainStaking is Ownable {
    CCIPInterface public ccip;
    IERC20 public podToken;

    mapping(address => uint256) public stakedAmounts;

    event Staked(address indexed staker, uint256 amount);
    event CrossChainUnstaked(address indexed staker, uint256 amount, uint16 targetChainId);

    constructor(address _ccipAddress, address _nativeTokenAddress) {
        ccip = CCIPInterface(_ccipAddress);
        podToken = IERC20(_nativeTokenAddress);
    }


    function crossChainStake(uint256 amount, uint16 targetChainId) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        podToken.transferFrom(owner(), address(this), amount);

        // Encode specific data for cross-chain stake based on CCIP specifications
        bytes memory data = abi.encode(amount, targetChainId);

        // Initiate a cross-chain message to record the stake on the target blockchain
        ccip.sendMessage(targetChainId, data, /* nonce */);

        emit Staked(owner(), amount);
    }

    function crossChainUnstake(uint256 amount, uint16 targetChainId) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");

        // Encode specific data for cross-chain unstake based on CCIP specifications
        bytes memory data = abi.encode(amount, targetChainId);

        // Initiate a cross-chain message to record the unstake on the target blockchain
        ccip.sendMessage(targetChainId, data, /* nonce */);

        // Perform the unstaking action on the current blockchain
        stakedAmounts[msg.sender] -= amount;

        emit CrossChainUnstaked(msg.sender, amount, targetChainId);
    }

    function _ccipReceive(
        uint16 _srcChainId,
        bytes memory _data,
        uint64 _nonce,
        bytes memory _payload
    ) external onlyOwner {
        // Decode and process the cross-chain message
        (uint256 amount, uint16 targetChainId) = abi.decode(_data, (uint256, uint16));

        // Perform the staking or unstaking action on the current blockchain based on the received message
        if (_srcChainId == targetChainId) {
            stakedAmounts[msg.sender] += amount;
            emit Staked(msg.sender, amount);
        } else {
            stakedAmounts[msg.sender] -= amount;
            emit CrossChainUnstaked(msg.sender, amount, targetChainId);
        }
    }

}
