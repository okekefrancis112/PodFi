require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-ethers")
require("@nomicfoundation/hardhat-verify")
require("hardhat-contract-sizer")

const ETHEREUM_SEPOLIA_RPC_URL = process.env.ETHEREUM_SEPOLIA_RPC_URL
const SCROLL_URL = process.env.SCROLL_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const SCROLL_SCAN_API_KEY = process.env.SCROLL_SCAN_API_KEY

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: ETHEREUM_SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
      // blockConfirmations: 6,
    },
    scrollSepolia: {
      url: SCROLL_URL,
      accounts: [PRIVATE_KEY],
      // chainId: 534351,
      // blockConfirmations: 6,
    }
  },
  etherscan: {
    sepolia: ETHERSCAN_API_KEY,
    scrollSepolia: SCROLL_SCAN_API_KEY
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  },
  customChains: [
    {
      network: 'scrollSepolia',
      chainId: 534351,
      urls: {
        apiURL: 'https://api-sepolia.scrollscan.com/api',
        browserURL: 'https://sepolia.scrollscan.com/',
      },
    },
  ],
  contractSizer: {
    runOnCompile: false,
    only: ["FunctionsConsumer", "AutomatedFunctionsConsumer", "FunctionsBillingRegistry"],
  },
  solidity: {
    compilers: [{ version: "0.8.20" }, { version: "0.8.9" }, { version: "0.6.6" }],
  },
};
