# JKLabsRPGTextGamePrototype

Version 1.0
Last Updated: 2024-08-11
**Author:** [JackyKit](https://3jk.net)

Tested : https://sepolia.etherscan.io/address/0xdfe4cc19adc0e4b117f926e3bd5788d92dc44925
Opensea: https://testnets.opensea.io/collection/jkrpg

![](https://raw.seadn.io/files/86726b3bcec153069f776c4318fda378.svg)

## Overview

The **JKLabsRPGTextGamePrototype** is a dynamic NFT game that allows users to mint characters and engage in random events that alter character attributes, grant items, or unlock special missions. The character's state is stored on-chain and rendered as an SVG image, providing a truly dynamic and immutable gaming experience.

---

## Key Functionalities

### 1. **Minting Characters**
   - Players can mint a new character by paying a small fee (0.001 ether).
   - Each character starts with basic attributes such as:
     - Health: 100
     - Attack: 10
     - Defense: 5
     - Gold: 0
     - Level: 1
   - The character's NFT is generated with its state encoded in an on-chain SVG image.

### 2. **Engaging in Gameplay**
   - Players pay a play fee (0.0002 ether) to engage in the game.
   - Each play session triggers random events that can:
     - Increase experience points
     - Award gold or items
     - Unlock special chapters or dungeons
   - Players have a chance to level up when experience exceeds the threshold.

### 3. **Random Events**
   - Events include gaining gold, losing health, increasing attack or defense, and finding or upgrading items.
   - A 2% chance to enter a special dungeon, with unique rewards such as powerful items.
   - A sophisticated randomization technique ensures that outcomes are unpredictable and fair.

### 4. **Special Dungeons**
   - Players in special dungeons have a 1% chance to receive a rare item, such as a "Legendary Sword" that increases attack.
   - After the dungeon, the player's status updates and they exit the dungeon.

### 5. **On-Chain Metadata & SVG Rendering**
   - All character attributes and game states are stored on-chain, ensuring data permanence.
   - The character's current state is reflected in an SVG image, dynamically generated from the on-chain data.
   - The use of SVG allows for a highly customizable and visually appealing representation of each NFT.

### 6. **PVP Battles**
   - Players can engage in Player vs. Player (PVP) battles.
   - The winner gains experience and gold, while the loser may lose a portion of their gold.

### 7. **Daily Rewards**
   - Players receive a daily reward for their first play session each day, adding an incentive for regular gameplay.

## Randomization Technique

To ensure unpredictability and fairness in gameplay outcomes, the prototype uses a comprehensive randomization method that incorporates:
- Block timestamp
- Block difficulty
- Miner address
- Previous block hash
- Sender's address
- Nonce (incremented with each random number generation)

---

## Key Sections of the Code

### 1. **Attaching Libraries**
Openzeppelin solidity ^0.8.20
The contract leverages several libraries from OpenZeppelin for key functionalities, such as:
- **ERC721URIStorage:** For storing and updating token URIs.
- **Ownable:** To manage ownership permissions.
- **Strings:** Utility library for string operations.
- **Base64:** To handle base64 encoding for metadata.

```solidity
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
```

### 2. **Declarations**
This section contains the core declarations, including the owner address, game version, and structures to store player and item data. The declarations also set the mint and play fees and initialize various mappings to manage player stats, items, and chapters.

```solidity
address public owner;
uint256 public gameVersion;
uint256 public nextPlayerId = 1;
uint256 private nonce;
uint256 constant MINT_PRICE = 0.001 ether;
uint256 constant PLAY_FEE = 0.0002 ether;
uint256 public collectedFees;

struct Player {
    uint256 level;
    uint256 experience;
    uint256 gold;
    uint256 health;
    uint256 attack;
    uint256 defense;
    uint256 chapter;
    uint256 lastPlayTime;
    bool inSpecialDungeon;
}

mapping(uint256 => Player) public players;
mapping(uint256 => string) public itemNames;
mapping(uint256 => uint256) public itemAttack;
mapping(uint256 => uint256) public itemDefense;
mapping(uint256 => uint256) public itemLevel;
mapping(uint256 => mapping(uint256 => uint256)) public chapterEffects;
mapping(uint256 => string) public chapterDescriptions;
```

### 3. **Events**
Events are emitted to notify external interfaces of important game actions, such as leveling up, item upgrades, and PVP engagements. These events help in tracking the game's progression and player interactions.

```solidity
event PlayerLeveledUp(address indexed player, uint256 newLevel);
event ItemUpgraded(uint256 indexed itemId, uint256 newLevel);
event ChapterUnlocked(address indexed player, uint256 chapterId);
event PlayerEngagedInPVP(address indexed player1, address indexed player2, uint256 winnerId);
event ItemDropped(address indexed player, uint256 itemId, string itemName);
event DailyRewardClaimed(address indexed player, uint256 rewardAmount);
event SpecialDungeonEntered(address indexed player);
event SpecialRewardClaimed(address indexed player, string rewardDescription);
event FundsWithdrawn(address indexed admin, uint256 amount);
```

### 4. **Modifiers**
Modifiers are used to control access and enforce specific conditions within functions, such as ensuring that only the contract owner can perform certain actions.

```solidity
modifier onlyOwner {
    require(msg.sender == owner, "Only the owner");
    _;
}
```

### 5. **Admin Functions**
Admin functions allow the contract owner to manage the game, including setting the game version, creating items, adding chapters, and minting player characters. These functions ensure that the game can be updated and expanded over time.

```solidity
function setGameVersion(uint256 version) external onlyOwner {
    gameVersion = version;
}

function createItem(uint256 itemId, string memory name, uint256 attack, uint256 defense, uint256 level) external onlyOwner {
    itemNames[itemId] = name;
    itemAttack[itemId] = attack;
    itemDefense[itemId] = defense;
    itemLevel[itemId] = level;
}

function addChapter(uint256 chapterId, string memory description) external onlyOwner {
    chapterDescriptions[chapterId] = description;
}

function addChapterEffect(uint256 chapterId, uint256 effectType, uint256 effectValue) external onlyOwner {
    chapterEffects[chapterId][effectType] = effectValue;
}

function mintPlayer(address to) external onlyOwner {
    uint256 playerId = nextPlayerId;
    nextPlayerId++;

    players[playerId] = Player({
        level: 1,
        experience: 0,
        gold: 0,
        health: 100,
        attack: 10,
        defense: 5,
        chapter: 1,
        lastPlayTime: 0,
        inSpecialDungeon: false
    });

    _safeMint(to, playerId);
    _setTokenURI(playerId, generateTokenURI(playerId));
}

function withdrawFunds() external onlyOwner {
    uint256 amount = collectedFees;
    collectedFees = 0;
    payable(owner).transfer(amount);
    emit FundsWithdrawn(owner, amount);
}
```

### 6. **Getter Functions**
These functions provide read-only access to important player and item stats, ensuring that external interfaces can easily retrieve and display relevant information.

```solidity
function getPlayerStats(uint256 playerId) external view returns (uint256 level, uint256 experience, uint256 gold, uint256 health, uint256 attack, uint256 defense, uint256 chapter) {
    Player memory player = players[playerId];
    level = player.level;
    experience = player.experience;
    gold = player.gold;
    health = player.health;
    attack = player.attack;
    defense = player.defense;
    chapter = player.chapter;
}

function getItemStats(uint256 itemId) external view returns (string memory name, uint256 attack, uint256 defense, uint256 level) {
    name = itemNames[itemId];
    attack = itemAttack[itemId];
    defense = itemDefense[itemId];
    level = itemLevel[itemId];
}
```

### 7. **Setter Functions**
Setter functions allow the game's state to be modified, such as adding experience to players, engaging in gameplay, triggering random events, and managing PVP battles. These functions drive the core gameplay mechanics.

```solidity
function addExperience(uint256 playerId) external onlyOwner {
    Player storage player = players[playerId];
    uint256 steps = random(1, 10);
    uint256 experienceGained = steps * 10;
    player.experience += experienceGained;

    if (player.experience >= player.level * 100) {
        player.level++;
        player.health += 10;
        player.attack += 5;
        player.defense += 5;
        emit PlayerLeveledUp(ownerOf(playerId), player.level);
    }

    if (random(1, 100) <= 2) {
        player.inSpecialDungeon = true;
        emit SpecialDungeonEntered(ownerOf(playerId));
    }

    triggerRandomEvent(playerId);
    _setTokenURI(playerId, generateTokenURI(playerId));
}

function play(uint256 playerId) external payable {
    require(ownerOf(playerId) == msg.sender, "Only the player can play");
    require(msg.value == PLAY_FEE, "Incorrect ETH amount sent");

    collectedFees += msg.value;

    Player storage player = players[playerId];
    uint256 steps = random(1, 10);
    uint256 experienceGained = steps * 10;
    player.experience += experienceGained;

    if (player.experience >= player.level * 100) {
        player.level++;
        player.health += 10;
        player.attack += 5;
        player.defense += 5;
        emit PlayerLeveledUp(ownerOf(playerId), player.level);
    }

    if (block.timestamp > player.lastPlayTime + 1 days) {
        uint256 dailyReward = random(5, 20);
        player.gold += dailyReward;
        player.lastPlayTime = block.timestamp;
        emit DailyRewardClaimed(ownerOf(playerId), dailyReward);
    }

    if (random(1, 100) <= 2) {
        player.inSpecialDungeon = true;
        emit SpecialDungeonEntered(ownerOf(playerId));
    }

    triggerRandomEvent(playerId);
    _setTokenURI(playerId, generateTokenURI(playerId));
}

function engageInPVP(uint256 playerId1, uint256 playerId2) external {
    Player storage player1 = players[playerId1];
    Player storage player2 = players[playerId2];

    uint256 attack1 = player1.attack + random(1, 10);
    uint256 attack2 = player2.attack + random(1, 10);

    if (attack1 > attack2) {
        player1.experience += 50;
        player1.gold += 10;
        player2.gold = player2.gold > 10 ? player2.gold - 10 : 0;
        emit PlayerEngagedInPVP(ownerOf(playerId1), ownerOf(playerId2), playerId1);
    } else {
        player2.experience += 50;
        player2.gold += 10;
        player1.gold = player1.gold > 10 ? player1.gold - 10 : 0;
        emit PlayerEngagedInPVP(ownerOf(playerId1), ownerOf(playerId2), playerId2);
    }

    _setTokenURI(playerId1, generateTokenURI(playerId1));
    _setTokenURI(playerId2, generateTokenURI(playerId2));
}

function enterSpecialDungeon(uint256 playerId) external {
    require(ownerOf(playerId) == msg.sender, "Only the player can enter

 the dungeon");
    Player storage player = players[playerId];
    require(player.inSpecialDungeon, "Not in a special dungeon");

    if (random(1, 100) <= 1) {
        string memory specialReward = "Legendary Sword";
        player.attack += 20;
        emit SpecialRewardClaimed(ownerOf(playerId), specialReward);
    }

    player.inSpecialDungeon = false;
    _setTokenURI(playerId, generateTokenURI(playerId));
}
```


---

## Collaborate and Support
If you support this project or are interested in collaborating, I can develop a complete text-based game smart contract with a full storyline on the Ethereum network and issue a dedicated game coin. This would expand the game's universe and offer new and exciting possibilities for gameplay. Your involvement could help bring this vision to life.

Feel free to reach out to me if you're interested in working together or if you have any ideas that could enhance the project.

Hi everyone! I'm JackyKit, and I'm excited to have you here. If you'd like to connect or chat, feel free to reach out to me on [X (formerly Twitter)](https://x.com/kitjacky) :-P.


## Donations

### Support my work and my Labs

This project is a labor of love, created in my spare time to share something fun and useful with the community. While GitHub kindly hosts this project for free, the time and effort required to maintain and improve it are significant. If you’ve enjoyed using this project and would like to support its continued development, consider buying me a coffee!

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
