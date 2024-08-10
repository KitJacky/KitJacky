// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @author JackyKit (https://3jk.net)
/// @author X : JackyKit (https://x.com/kitjacky)

// Attaching libraries
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Declarations
contract JKLabsStaking is Ownable, ReentrancyGuard {
    IERC20 public JKLabsJKCoin;
    uint256 public JKLabsRewardRate; // (e.g., 1000 for 10%)
    uint256 public constant AVERAGE_BLOCK_TIME_SECONDS = 13;
    uint256 public constant UNSTAKE_PERIOD_SECONDS = 14 * 24 * 60 * 60;
    uint256 public JKLabsUnstakePeriodBlocks = UNSTAKE_PERIOD_SECONDS / AVERAGE_BLOCK_TIME_SECONDS;

    struct Stake {
        uint256 amount;
        uint256 startBlock;
        uint256 unstakeBlock;
        bool isUnstaking;
    }

    mapping(address => Stake) public stakes;

    // Events
    event Staked(address indexed user, uint256 amount);
    event UnstakeInitiated(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    constructor(IERC20 _JKCoin, uint256 _rewardRate, address initialOwner) Ownable(initialOwner) {
        JKLabsJKCoin = _JKCoin;
        JKLabsRewardRate = _rewardRate;
    }

    // Admin Functions
    function depositRewards(uint256 amount) external onlyOwner nonReentrant {
        require(JKLabsJKCoin.transferFrom(msg.sender, address(this), amount), "Deposit failed");
    }

    // Setter Functions
    function stake(uint256 amount) external nonReentrant {
        require(JKLabsJKCoin.transferFrom(msg.sender, address(this), amount), "Staking failed");

        Stake storage stakeData = stakes[msg.sender];
        stakeData.amount += amount;
        stakeData.startBlock = block.number;

        emit Staked(msg.sender, amount);
    }

    function initiateUnstake() external nonReentrant {
        Stake storage stakeData = stakes[msg.sender];
        require(stakeData.amount > 0, "No stake found");
        require(!stakeData.isUnstaking, "Unstaking already initiated");

        stakeData.unstakeBlock = block.number + JKLabsUnstakePeriodBlocks;
        stakeData.isUnstaking = true;

        emit UnstakeInitiated(msg.sender, stakeData.amount);
    }

    function completeUnstake() external nonReentrant {
        Stake storage stakeData = stakes[msg.sender];
        require(stakeData.isUnstaking, "Unstaking not initiated");
        require(block.number >= stakeData.unstakeBlock, "Unstaking period not over");

        uint256 durationBlocks = stakeData.unstakeBlock - stakeData.startBlock;
        uint256 durationSeconds = durationBlocks * AVERAGE_BLOCK_TIME_SECONDS;
        uint256 reward = (stakeData.amount * JKLabsRewardRate * durationSeconds) / (365 * 24 * 60 * 60 * 10000);
        uint256 totalAmount = stakeData.amount + reward;

        stakeData.amount = 0;
        stakeData.isUnstaking = false;

        require(JKLabsJKCoin.transfer(msg.sender, totalAmount), "Unstaking failed");

        emit Unstaked(msg.sender, stakeData.amount, reward);
    }
}
