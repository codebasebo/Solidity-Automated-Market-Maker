// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MockPriceOracle} from "./MorkPriceOracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Pool is ERC20 {
    MockPriceOracle public priceOracle;
    uint32 public slope;

    uint32 public constant DECAY_FACTOR = 100000;
    uint256 public constant BASE_PRICE = 100000; // Base price in USDT (scaled)
    uint256 public constant K = 1000; // Exponential growth factor (scaled)

    event Price(uint256 price);
    event Tokens(uint256 tokens);
    event SellPenaltyApplied(uint256 penalty, uint256 netETHTransferred);
    event PoolBalance(uint256 ethBalance);

    constructor(uint256 initialSupply, uint32 _slope, address _priceOracle) ERC20("Pool Token", "POOL") {
        _mint(msg.sender, initialSupply);
        
        slope = _slope;
        priceOracle = MockPriceOracle(_priceOracle);
    }

    function sell(uint256 tokensToSell) public {
        require(tokensToSell > 0, "Must sell at least one token");
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient token balance");

        uint256 tokenPrice = calculateTokenPrice();
        uint256 amountUSDT = tokensToSell * tokenPrice;

        uint256 penalty = (amountUSDT * slope) / 10000;
        uint256 netAmountUSDT = amountUSDT - penalty;
        require(netAmountUSDT > 0, "Net amount after penalty is zero");

        uint256 priceETH = priceOracle.getETHPrice();
        uint256 amountETH = (netAmountUSDT / priceETH) / 1e12; // Convert to wei
        require(amountETH > 0, "Invalid ETH amount from oracle");
        require(address(this).balance >= amountETH, "Insufficient ETH liquidity in pool");

        emit PoolBalance(address(this).balance);
        _burn(msg.sender, tokensToSell);

        payable(msg.sender).transfer(amountETH);

        emit Tokens(tokensToSell);
        emit Price(amountETH);
        emit SellPenaltyApplied(penalty, amountETH);
    }

    function buy() public payable {
        require(msg.value > 0, "Insufficient Ether sent");

        uint256 amountUSDT = priceOracle.getPrice(msg.value, "ETH");
        require(amountUSDT > 0, "Invalid price from oracle");

        emit Price(amountUSDT);

        uint256 tokensToMint = calculatePurchase(amountUSDT);
        require(tokensToMint > 0, "Insufficient USDT for token purchase");


        _mint(msg.sender, tokensToMint);

        emit Tokens(tokensToMint);
    }

    function calculatePurchase(uint256 amountUSDT) public view returns (uint256) {
        uint256 currentPrice = calculateTokenPrice();
        return (amountUSDT / currentPrice) * BASE_PRICE;
    }

    function calculateTokenPrice() public view returns (uint256) {
        uint256 scaledTotalSupply = (totalSupply() * K) / DECAY_FACTOR;
        uint256 price = (BASE_PRICE * exp(scaledTotalSupply)) / 1e18;
        require(price > 0, "Calculated price is zero");
        return price;
    }

    function exp(uint256 x) public pure returns (uint256) {
        if (x == 0) return 1e18; // e^0 = 1
        if (x > 10e18) {
            uint256 halfExp = exp(x / 2);
            return (halfExp * halfExp) / 1e18;
        }

        uint256 result = 1e18; // 1 in fixed-point (18 decimals)
        uint256 term = 1e18; // Initial term is 1 (in fixed-point)

        for (uint256 i = 1; i <= 10; i++) {
            term = (term * x) / (i * 1e18); // x^i / i!
            if (term == 0) break; // Avoid unnecessary computation
            result += term;
        }

        return result;
    }

    receive() external payable {}

    fallback() external payable {}
}
