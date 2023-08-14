// SPDX-License-Identifier: MIT

pragma solidity = 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is ReentrancyGuard, Ownable {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    uint256 public s_rewardRate = 100; // Now it's adjustable
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public s_totalRewardsDistributed;
    uint256 public s_stakingStartTime = block.timestamp;

    mapping(address => uint256) public s_balances;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function setRewardRate(uint256 newRate) external onlyOwner {
        s_rewardRate = newRate;
    }

    function earned(address account) public view returns (uint256) {
        return (s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account]) / 1e18) + s_rewards[account];
    }

    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + ((block.timestamp - s_lastUpdateTime) * s_rewardRate * 1e18 / s_totalSupply);
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        s_balances[msg.sender] += amount;
        s_totalSupply += amount;
        require(s_stakingToken.transferFrom(msg.sender, address(this), amount), "Staking failed");
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        require(s_stakingToken.transfer(msg.sender, amount), "Withdraw failed");
        emit Withdrawn(msg.sender, amount);
    }

    function claimReward() external updateReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        if (reward > 0) {
            s_rewards[msg.sender] = 0;
            s_totalRewardsDistributed += reward;
            require(s_rewardToken.transfer(msg.sender, reward), "Reward claim failed");
            emit RewardClaimed(msg.sender, reward);
        }
    }

    function totalRewardsDistributed() external view returns (uint256) {
        return s_totalRewardsDistributed;
    }

    function totalStaked() external view returns (uint256) {
        return s_totalSupply;
    }

    function stakingStartTime() external view returns (uint256) {
        return s_stakingStartTime;
    }

    function rescueTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(s_stakingToken), "Cannot rescue staking token");
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Rescue failed");
    }
}
