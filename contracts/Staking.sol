// Lock tokens into smart contracts
// Withdraw: pull out
// claimReward: users get their reward tokens
// What is a good reward mechanism?

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Straking__NeedsMoreThanZero();

contract staking{
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    mapping(address => uint256) public s_balances;

    mapping(address => uint256) public s_userReward;

    mapping(address => uint256) public s_rewards;

    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public REWARD_RATE = 100;

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userReward[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreTZ(uint256 amount) {
        if (amount <= 0){
            revert Straking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_balances[account];
        uint256 amountPaid = s_userReward[account];

        uint256 currentPeriod = rewardPerToken();
        uint256 pastPeriod = s_rewards[account];

        uint256 _earned = ((currentBalance * (currentPeriod - amountPaid))/1e18) + pastPeriod;
        return _earned;
    }

    function rewardPerToken() public view returns(uint256){
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime)* REWARD_RATE * 1e18)/s_totalSupply);
    }

    function stake(uint256 amount) external updateReward(msg.sender) moreTZ(amount){
        // keep track of how much this user has staked
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        bool succ = s_stakingToken.transferFrom(msg.sender, address(this),amount);
        if  (!succ) {
            revert Staking__TransferFailed();
        }
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) moreTZ(amount){
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        bool succy = s_stakingToken.transfer(msg.sender, amount);
        if (!succy) {
            revert Staking__TransferFailed();
        }

    }

    function claimReward() external updateReward(msg.sender){
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
        // how much reward do they get?

        // the contract is going to emit x tokens per second
        // then disperse them to all token stakers

        // 100 rewardTokens / second
        // a has 50 staked tokens, b has 30, c has 20
        // a would receicve 50 rewardTokens, ....
    }

    

}
