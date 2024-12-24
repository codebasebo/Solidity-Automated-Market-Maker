// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MockPriceOracle {
    mapping(string => uint256) public tokenPrices; // Prices in USD with 6 decimals (e.g., 1 ETH = 2000 * 10^6)
    uint256 public constant DECIMALS = 1e6; // Scaling factor for USD prices
    address public owner;

    event PriceUpdated(string indexed tokenName, uint256 newPrice);

    /**
     * @notice Set the price of a token in USD (with 6 decimals of precision).
     * @param tokenName The name of the token (e.g., "ETH", "BTC").
     * @param price The price of the token in USD (scaled by DECIMALS, e.g., 1 ETH = 2000 * 10^6).
     */
    function setPrice(string calldata tokenName, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        tokenPrices[tokenName] = price;
        emit PriceUpdated(tokenName, price);
    }

    /**
     * @notice Get the value of an ETH amount in USD (with 6 decimals of precision).
     * @param ethAmount The amount of ETH in wei (1 ETH = 10^18 wei).
     * @param tokenName The name of the token to get the price for (e.g., "ETH").
     * @return ethAmountInUsd The value of the ETH amount in USD (scaled by DECIMALS).
     */
    function getPrice(uint256 ethAmount, string calldata tokenName) external view returns (uint256) {
        uint256 ethPrice = tokenPrices[tokenName];

        require(ethPrice > 0, "Price not set for the token");
        uint256 ethAmountInUsd = (ethPrice * ethAmount); // Convert wei to USD
        return ethAmountInUsd;
    }

    function getETHPrice() external view returns (uint256) {
        return tokenPrices["ETH"];
    }
}
