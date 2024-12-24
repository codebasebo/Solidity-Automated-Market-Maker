const main = async () => {

    const [deployer] = await hre.ethers.getSigners();
    const accountBalance = await hre.ethers.provider.getBalance(deployer.address);

    const MockPriceFeed = await ethers.getContractFactory('MockPriceOracle');
    const mockPriceFeed = await MockPriceFeed.deploy();
    await mockPriceFeed.waitForDeployment();
    await mockPriceFeed.setPrice("ETH", 1000);
    console.log("MockPriceFeed deployed to: ", await mockPriceFeed.getAddress());

    const ETHPrice = await mockPriceFeed.getETHPrice();
    console.log("ETH Price: ", ETHPrice.toString());


    console.log("deploying contract with account ", await deployer.getAddress());
    console.log("Account balance ", accountBalance.toString());

    const initialSupply = 1000;
    const slope = 1;

    const Pool = await ethers.getContractFactory('Pool');
    const pool = await Pool.deploy(initialSupply, slope, mockPriceFeed.getAddress());
    await pool.waitForDeployment();
    console.log("Contract deployed to: ", await pool.getAddress());





}

const runMain = async () => {
    try {
        await main();
        process.exit(0);

    } catch (error) {
        console.log(error)
        process.exit(1);
    }
}

runMain();