# JKLabsStaking Smart Contract

**File:** contracts/JKLabsStaking.sol  
**Author:** [JackyKit](https://3jk.net) ([X: JackyKit](https://x.com/kitjacky))

Etherscan : https://etherscan.io/address/0x5febfa4dc6e5e9aaace0484a50baf341c44b7073#code

## Overview

The `JKLabsStaking` contract is a simplified staking mechanism for the `JKLabsJKCoin` ERC-20 token. Drawing inspiration from the Cosmos SDK, this contract offers a streamlined staking experience with essential features like staking, reward calculation, and a 14-day unlock mechanism. Designed with security in mind, `JKLabsStaking` uses OpenZeppelin's libraries to ensure a robust and efficient staking process.

## Cosmos SDK Inspiration

The `JKLabsStaking` contract was developed with a deep understanding of the Cosmos SDK, serving as a simplified version of its staking module. While the Cosmos SDK provides a comprehensive and complex staking system, `JKLabsStaking` focuses on the core functionalities, making it easier to integrate within a smart contract environment. The 14-day unlock mechanism, a key feature in this contract, is directly inspired by the unbonding period in the Cosmos SDK, offering users a familiar and secure staking experience.

## Key Similarities with Cosmos SDK

### 1. **Staking and Unstaking Mechanism**
   - **Cosmos SDK:** Validators and delegators can stake tokens to participate in network security. When they choose to unstake (unbond), there is a mandatory unbonding period during which tokens remain locked.
   - **JKLabsStaking:** Users can stake their tokens, and when they wish to unstake, a 14-day unlock (unstake) period is enforced, during which the tokens are locked before they can be withdrawn.

### 2. **Reward Calculation**
   - **Cosmos SDK:** Rewards are calculated based on the amount staked and the duration of staking, typically distributed periodically.
   - **JKLabsStaking:** Rewards are calculated based on the staked amount and the time staked, distributed at the end of the unstaking process.

### 3. **Security and Locking Mechanisms**
   - **Cosmos SDK:** Staked tokens are bonded to a validator, locked for the duration of staking, and subject to slashing in case of validator misbehavior.
   - **JKLabsStaking:** Staked tokens are securely locked in the contract for the staking duration, with the added protection of OpenZeppelin’s `ReentrancyGuard` to prevent attacks during the staking and unstaking processes.

### 4. **Event Logging**
   - **Cosmos SDK:** Events are emitted for key actions such as staking, unbonding, and reward distribution, which can be used for monitoring and off-chain processes.
   - **JKLabsStaking:** The contract emits events when users stake, initiate unstaking, and complete unstaking, facilitating easy tracking and integration with off-chain systems.

## Smart Contract Structure

The smart contract is organized into several key sections:

### 1. Attaching Libraries

The contract imports essential libraries from OpenZeppelin for managing ERC-20 tokens, preventing reentrancy attacks, and handling ownership:

```solidity
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

### 2. Declarations

This section includes the declaration of the `JKLabsStaking` contract and its state variables, which define the token, reward rate, and staking mechanics:

```solidity
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
}
```

### 3. Constructor

The constructor initializes the contract with the specified token, reward rate, and owner:

```solidity
constructor(IERC20 _JKCoin, uint256 _rewardRate, address initialOwner) Ownable(initialOwner) {
    JKLabsJKCoin = _JKCoin;
    JKLabsRewardRate = _rewardRate;
}
```

### 4. Events

Events are used to log significant actions within the contract, such as staking, initiating unstaking, and completing unstaking:

```solidity
event Staked(address indexed user, uint256 amount);
event UnstakeInitiated(address indexed user, uint256 amount);
event Unstaked(address indexed user, uint256 amount, uint256 reward);
```

### 5. Admin Functions

These functions are reserved for the contract owner, allowing them to manage the reward pool by depositing tokens:

```solidity
function depositRewards(uint256 amount) external onlyOwner nonReentrant {
    require(JKLabsJKCoin.transferFrom(msg.sender, address(this), amount), "Deposit failed");
}
```

### 6. Setter Functions

Setter functions allow users to stake their tokens, initiate the unstaking process, and complete unstaking to receive their tokens along with rewards:

#### `stake`

This function allows users to stake their tokens, recording the amount and the block number at which staking begins:

```solidity
function stake(uint256 amount) external nonReentrant {
    require(JKLabsJKCoin.transferFrom(msg.sender, address(this), amount), "Staking failed");

    Stake storage stakeData = stakes[msg.sender];
    stakeData.amount += amount;
    stakeData.startBlock = block.number;

    emit Staked(msg.sender, amount);
}
```

#### `initiateUnstake`

This function allows users to initiate the unstaking process, setting the block number at which they can complete the unstaking:

```solidity
function initiateUnstake() external nonReentrant {
    Stake storage stakeData = stakes[msg.sender];
    require(stakeData.amount > 0, "No stake found");
    require(!stakeData.isUnstaking, "Unstaking already initiated");

    stakeData.unstakeBlock = block.number + JKLabsUnstakePeriodBlocks;
    stakeData.isUnstaking = true;

    emit UnstakeInitiated(msg.sender, stakeData.amount);
}
```

#### `completeUnstake`

This function allows users to complete the unstaking process after the unstaking period has passed, receiving their staked amount and the accumulated reward:

```solidity
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
```

## How to Use

1. **Deployment:** Deploy the contract with the token address, reward rate, and initial owner address.
2. **Staking Tokens:** Users can stake their tokens using the `stake` function.
3. **Unstaking Tokens:** Users can initiate unstaking with the `initiateUnstake` function and complete it after the 14-day unlock period using the `completeUnstake` function.
4. **Depositing Rewards:** The contract owner can deposit rewards into the staking pool using the `depositRewards` function.

## Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) for providing robust and secure libraries for smart contract development.
- [Cosmos SDK](https://docs.cosmos.network/) for inspiring the design and implementation of this simplified staking mechanism.



## Donations

Hi everyone! I'm JackyKit, and I'm really happy to have you here. If you'd like to connect or chat, please don't hesitate to reach out to me. I'd love to hear from you! >> Find me on [X](https://x.com/kitjacky) :-P.

### Support my work and my labs

This project was created in my spare time to share something interesting and useful with the community. Although GitHub hosts this project for free, the backend is using its own server and rented data centre, so maintaining and improving this project and my own lab requires a lot of time, effort and money. If you enjoy using this project and would like to support its continued development, please consider buying me a cup of coffee! I must have two cups a day, so every cup counts!

You can donate via Ethereum to the following address:

**ETH Address:** `0x5b6DB94a3c92Cc8095CeE065265412A700a07405`

Your contributions, no matter how small, go a long way in keeping this project alive and thriving. I genuinely appreciate any support you can offer, whether it’s through a donation, spreading the word, or contributing directly to the project. Thank you so much!

### Other Ways to Support

If you re unable to donate but still want to help, there are several other ways you can contribute:

- **Star the Repository:** If you find this project helpful or interesting, please consider starring the repository. It helps increase visibility and signals to others that this is a project worth exploring.
- **Contribute:** Have an idea, a suggestion, or improvements in mind? Feel free to fork the repo and submit a pull request. Contributions are always welcome and appreciated!
- **Share:** Spread the word by sharing this project with others who might benefit from it. Every share helps grow the community.

Thank you for your support in whatever form it takes. Together, we can continue to make this project even better!


---
feel free to reach out to me on [X](https://x.com/kitjacky)
JK Labs : https://3jk.net
