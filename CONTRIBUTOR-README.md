# Podfi Smart Contract Contributor README

## Welcome Note
Welcome to the Podfi Smart Contract! We appreciate your contribution to this project. To maintain code clarity and understanding, we encourage you to use NatSpec commenting style to document your code thoroughly.

## Contract Overview
#### Podfi Contract
The Podfi contract facilitates interactions between advertisers and podcast creators in a decentralized marketplace, Rewards users who interacts with the podcast (listeners,sharers & commentors) with tokenized assets / NFTs. With the power of `Chainlink` oracles, podfi provide real-time analytics to podcasters and advertisers, including listener demographics and engagement metrics. Podfi implements a decentralized governance system where listeners and creators collectively make decisions on platform development progression, tokenomics, and partnerships. To make Podfi accessible to all customers from any chain, Podfi implements interoperability utilizing the power of chainlink to make cross chain communication(assets transfer ,ads creation,governance, staking, etc). Podfi PodTokens for event participation and exclusive access for live shows.



##Contributing Guidelines
1. **Code Organization:**

    - Please organize your code logically and follow existing patterns.
    Use appropriate modifiers to restrict access to functions when necessary.
    - Make sure related contracts are properly grouped. Make it as clean and simple as possible. Files and directories names should not conflict with any other names & overall it should make sense as to what it contains.

2. **NatSpec Comments:**

    Add NatSpec comments to describe the overall purpose of the contract and each function.
    Clearly explain the parameters, return values, and any specific conditions.

3. **Security Considerations:**

    Be mindful of security best practices.
    Avoid vulnerabilities such as reentrancy, overflow, and underflow.

4. **Testing:**

    Include comprehensive tests for new functionalities.
    Ensure that existing tests are not broken.
5. **Pushing To Remote:**
    Create a different branch for your workspace: this branch will state clearly what features you worked on with your initails eg `SC_ft_marketplace_CCIP` where `SC` is the initail , `FT` is the feature tag and `marketplace and ccip` is the actual feature.



### NatSpec Commenting Style

[NatSpec](https://docs.soliditylang.org/en/v0.8.0/natspec-format.html) is a documentation system used in Solidity for adding inline documentation. It helps in generating human-readable documentation directly from the code.

**Please follow these guidelines for NatSpec comments:**

- **Top-Level Comment:** Provide a high-level description of the purpose and functionality of the contract.
Here's an example of how to use NatSpec comments for a contract:
```solidity
/**
 * @title Ads Decentralized Marketplace Smart Contract
 * @dev This contract manages the interactions between advertisers and podcast creators.
 * It allows advertisers to create and manage ads, and podcast creators to approve or reject ads.
 */
contract PodfiAdsMarketplace {
    // Contract logic...
}


```

- **Function Comments:** Add NatSpec comments for each function explaining its purpose, parameters, return values, and any other relevant information.

Here's an example of how to use NatSpec comments for a function:

```solidity
/**
 * @dev Registers a new advertiser in the marketplace.
 * @param name The name of the advertiser.
 */
function registerAdvertiser(string memory name) external {
    // Function logic...
}

```
**That's all champs**
Thank you for contributing to the Podfi Smart Contract. Your dedication to clear documentation and adherence to best practices make this project better for everyone. If you have any questions or need assistance, feel free to reach out to the project maintainers.

Happy coding! 🚀