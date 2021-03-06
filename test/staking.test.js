const {ethers, deployments} = require("hardhat")

describe("Staking Test", async function(){
    let staking, rewardToken, deployer, stakeAmount

    beforeEach(async function() {
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        await deployments.fixture(["all"])
        rewardToken = await ethers.getContract(["RewardToken"])
        staking = await ethers.getContract(["staking"])
        stakeAmount = ethers.utils.parseEther('100000')
    })

    it("Allows users to stake and claim rewards", async function(){
        await rewardToken.approve(staking.address, stakeAmount)
        console.log(stakeAmount)
        await staking.stake(stakeAmount)
        const startingEarned = await staking.earned(deployer.address)
        console.log(`Earned ${startingEarned}`)


    })
})