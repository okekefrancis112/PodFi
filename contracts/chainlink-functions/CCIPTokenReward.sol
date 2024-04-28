// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/CCIPInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CCIPTokenRewards is Ownable {
    CCIPInterface public ccip;
    IERC20 public podToken;

    mapping(address => uint256) public earnedTokens;

    event CrossChainTransferInitiated(address indexed recipient, uint256 amount, uint16 targetChainId);

    constructor(address _ccipAddress, address _nativeTokenAddress) {
        ccip = CCIPInterface(_ccipAddress);
        podToken = IERC20(_nativeTokenAddress);
    }


    function initiateCrossChainTransfer(uint256 amount, uint16 targetChainId) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");

        // Encode specific data for cross-chain transfer based on CCIP specifications
        bytes memory data = abi.encode(amount, targetChainId);

        // Initiate a cross-chain message to transfer tokens to the target blockchain
        ccip.sendMessage(targetChainId, data, /* nonce */);

        emit CrossChainTransferInitiated(msg.sender, amount, targetChainId);
    }

    function _ccipReceive(
        uint16 _srcChainId,
        bytes memory _data,
        uint64 _nonce,
        bytes memory _payload
    ) external onlyOwner {
        // Decode and process the cross-chain message
        (uint256 amount, uint16 targetChainId) = abi.decode(_data, (uint256, uint16));

        // Perform the token transfer on the current blockchain
        require(_srcChainId != targetChainId, "Invalid cross-chain transfer");
        podToken.transfer(msg.sender, amount);
    }

}
