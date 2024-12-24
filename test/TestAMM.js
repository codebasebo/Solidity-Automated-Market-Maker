// test/Box.test.js
// Load dependencies
const { expect } = require('chai');
const { ethers } = require("hardhat");
// Start test block
const initialSupply = 1000;
const slope = 1;

describe('Pool', function () {
  before(async function () {
    // Deploy the contract
    this.MockPriceFeed = await ethers.getContractFactory('MockPriceOracle');
    this.Pool = await ethers.getContractFactory('Pool');
  });

  beforeEach(async function () {
    // Deploy a new Box contract for each test
    const mockPriceFeed = await this.MockPriceFeed.deploy();
    await mockPriceFeed.waitForDeployment();
    await mockPriceFeed.setPrice("ETH", 1000);

    this.pool = await this.Pool.deploy(initialSupply, slope, mockPriceFeed.getAddress());
    await this.pool.waitForDeployment();
  });

  // Test case
  it('calculate Token Price', async function () {

    const tokenPrice = await this.pool.calculateTokenPrice();

    console.log(tokenPrice);


  });


  it('calculate Token Price', async function () {
    const tokenPrice = await this.pool.calculateTokenPrice();
    console.log("Token Price:", Number(tokenPrice) / 1e6);
    expect(tokenPrice).to.be.a('bigint');
    expect(tokenPrice).to.equal(100000n); // Replace with the expected price value
  });


  it('buy Token', async function () {
    const [owner] = await ethers.getSigners();
    const tx = await this.pool.buy({ value: ethers.parseEther("1") });
    await tx.wait();

    const balance = await this.pool.balanceOf(await owner.getAddress());
    console.log("Token Balance:", Number(balance) / 1e18);

    const poolAddress = await this.pool.getAddress();
    const contractBalance = await ethers.provider.getBalance(poolAddress);
    console.log("Contract Balance:", Number(contractBalance) / 1e18);

    expect(balance).to.be.a('bigint');
    expect(balance).to.be.greaterThan(0n); // Ensure tokens were minted
  });



  it("Sell Token", async function () {
    const [owner] = await ethers.getSigners();

    const poolAddress = await this.pool.getAddress();
    const contractBalance1 = await ethers.provider.getBalance(poolAddress);
    console.log("Contract Balance:", Number(contractBalance1) / 1e18);


    const tx = await this.pool.buy({ value: ethers.parseEther("0.05") });
    await tx.wait();

    const balance = await this.pool.balanceOf(await owner.getAddress());
    console.log("Token Balance:", Number(balance) / 1e18);


    const contractBalance = await ethers.provider.getBalance(poolAddress);
    console.log("Contract Balance:", Number(contractBalance) / 1e18);

    expect(balance).to.be.a('bigint');
    expect(balance).to.be.greaterThan(0n); // Ensure tokens were minted

    // Sell half of the tokens to reduce the required liquidity
    const sellTx = await this.pool.sell(balance);
    await sellTx.wait();

    const balanceAfterSell = await this.pool.balanceOf(owner.getAddress());
    console.log("Token Balance After Selling:", balanceAfterSell.toString());
    expect(balanceAfterSell).to.be.a('bigint');


    const contractBalanceAfterSell = await ethers.provider.getBalance(poolAddress);
    console.log("Contract Balance After Selling:", Number(contractBalanceAfterSell) / 1e18);





  });

  it("check if token price increase", async function () {
    const [owner] = await ethers.getSigners();
    const tx = await this.pool.buy({ value: ethers.parseEther("1") });
    await tx.wait();

    const tokenPrice = await this.pool.calculateTokenPrice();
    console.log("Token Price:", Number(tokenPrice) / 1e6);

    const tx2 = await this.pool.buy({ value: ethers.parseEther("1") });
    await tx2.wait();

    const tokenPrice2 = await this.pool.calculateTokenPrice();
    console.log("Token Price:", Number(tokenPrice2) / 1e6);

    expect(tokenPrice2).to.be.a('bigint');
    expect(tokenPrice2).to.be.greaterThan(tokenPrice); // Ensure tokens were minted
  })

});