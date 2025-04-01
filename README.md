
# Solidity AMM Pool

## Overview
A decentralized Automated Market Maker (AMM) implementation in Solidity featuring exponential pricing, oracle integration, and a sell penalty mechanism.

## Features
- Dynamic token pricing using exponential model
- Price oracle integration for ETH/USD conversion
- Buy/sell functionality with penalty mechanism
- Comprehensive automated test suite

## Installation
```bash
npm install
```

## Usage

### Deploy Contracts
```bash
npx hardhat run scripts/deploy.js
```

### Interact with Contracts
```solidity
// Buy tokens
pool.buy({value: ethAmount});

// Sell tokens
pool.sell(tokenAmount);

// Check current price
uint256 price = pool.calculateTokenPrice();
```

## Contract Architecture
- `Pool.sol`: Core AMM implementation with pricing logic
- `MockPriceOracle.sol`: Price feed oracle for ETH/USD rates

## Development
Run tests:
```bash
npx hardhat test
```

## Technical Details
- Solidity: v0.8.28
- Framework: Hardhat
- Network: Local testnet

## License
UNLICENSED
