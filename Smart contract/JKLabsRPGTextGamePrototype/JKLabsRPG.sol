// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @author JackyKit (https://3jk.net)
/// @author X : JackyKit (https://x.com/kitjacky)

// Attaching Libraries
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract JKLabsRPGTextGamePrototype is ERC721URIStorage {
    // Declarations
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
        uint256 lastPlayTime; // Timestamp of the last play action
        bool inSpecialDungeon; // Indicates if the player is in a special dungeon
    }

    mapping(uint256 => Player) public players;
    mapping(uint256 => string) public itemNames;
    mapping(uint256 => uint256) public itemAttack;
    mapping(uint256 => uint256) public itemDefense;
    mapping(uint256 => uint256) public itemLevel;
    mapping(uint256 => mapping(uint256 => uint256)) public chapterEffects; // chapterId => effectType => effectValue
    mapping(uint256 => string) public chapterDescriptions;

    // Events
    event PlayerLeveledUp(address indexed player, uint256 newLevel);
    event ItemUpgraded(uint256 indexed itemId, uint256 newLevel);
    event ChapterUnlocked(address indexed player, uint256 chapterId);
    event PlayerEngagedInPVP(address indexed player1, address indexed player2, uint256 winnerId);
    event ItemDropped(address indexed player, uint256 itemId, string itemName);
    event DailyRewardClaimed(address indexed player, uint256 rewardAmount);
    event SpecialDungeonEntered(address indexed player);
    event SpecialRewardClaimed(address indexed player, string rewardDescription);
    event FundsWithdrawn(address indexed admin, uint256 amount);

    // Modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner");
        _;
    }

    // Constructor
    constructor() ERC721("JKRPG", "RPG") {
        owner = msg.sender;
    }

    // Admin Functions
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

    function mintPrice() public pure returns (uint256) {
        return MINT_PRICE;
    }

    function playFee() public pure returns (uint256) {
    return PLAY_FEE;
    }

    // Public Functions
    function mint() external payable {
        require(msg.value == MINT_PRICE, "Not enough Ether for mint");

        collectedFees += msg.value;

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

        _safeMint(msg.sender, playerId);
        _setTokenURI(playerId, generateTokenURI(playerId));
    }

    // Getter Functions
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

    // Setter Functions
    function addExperience(uint256 playerId) external onlyOwner {
        Player storage player = players[playerId];
        uint256 steps = random(1, 10); // Random number of steps
        uint256 experienceGained = steps * 10; // 10 experience points per step
        player.experience += experienceGained;

        if (player.experience >= player.level * 100) {
            player.level++;
            player.health += 10;
            player.attack += 5;
            player.defense += 5;
            emit PlayerLeveledUp(ownerOf(playerId), player.level);
        }

        // Check if the player enters a special dungeon
        if (random(1, 100) <= 2) { // 2% chance to enter a special dungeon
            player.inSpecialDungeon = true;
            emit SpecialDungeonEntered(ownerOf(playerId));
        }

        // Trigger a random event
        triggerRandomEvent(playerId);
        _setTokenURI(playerId, generateTokenURI(playerId));
    }

    function play(uint256 playerId) external payable {
        require(ownerOf(playerId) == msg.sender, "Only the player can play");
        require(msg.value == PLAY_FEE, "Incorrect ETH amount sent");

        collectedFees += msg.value;

        Player storage player = players[playerId];
        uint256 steps = random(1, 10); // Random number of steps
        uint256 experienceGained = steps * 10; // 10 experience points per step
        player.experience += experienceGained;

        if (player.experience >= player.level * 100) {
            player.level++;
            player.health += 10;
            player.attack += 5;
            player.defense += 5;
            emit PlayerLeveledUp(ownerOf(playerId), player.level);
        }

        // Daily reward for the first play of the day
        if (block.timestamp > player.lastPlayTime + 1 days) {
            uint256 dailyReward = random(5, 20);
            player.gold += dailyReward;
            player.lastPlayTime = block.timestamp;
            emit DailyRewardClaimed(ownerOf(playerId), dailyReward);
        }

        // Check if the player enters a special dungeon
        if (random(1, 100) <= 2) { // 2% chance to enter a special dungeon
            player.inSpecialDungeon = true;
            emit SpecialDungeonEntered(ownerOf(playerId));
        }

        // Trigger a random event
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
        require(ownerOf(playerId) == msg.sender, "Only the player can enter the dungeon");
        Player storage player = players[playerId];
        require(player.inSpecialDungeon, "Not in a special dungeon");

        // 1% chance to receive a special reward
        if (random(1, 100) <= 1) {
            string memory specialReward = "Legendary Sword";
            player.attack += 20; // Special reward increases attack
            emit SpecialRewardClaimed(ownerOf(playerId), specialReward);
        }

        player.inSpecialDungeon = false; // Exit the dungeon
        _setTokenURI(playerId, generateTokenURI(playerId));
    }

    // Helper Functions
    function applyChapterEffects(uint256 playerId) internal {
        Player storage player = players[playerId];
        uint256 chapterId = player.chapter;

        player.health += chapterEffects[chapterId][1]; // Increase health
        player.attack += chapterEffects[chapterId][2]; // Increase attack
        player.defense += chapterEffects[chapterId][3]; // Increase defense
    }

    function triggerRandomEvent(uint256 playerId) internal {
        Player storage player = players[playerId];
        uint256 eventType = random(1, 6); // A new random event type

        if (eventType == 1) {
            player.gold += 10; // Random event rewards gold
        } else if (eventType == 2) {
            player.health = player.health > 10 ? player.health - 10 : 0; // Random event decreases health
        } else if (eventType == 3) {
            player.attack += 2; // Random event increases attack
        } else if (eventType == 4) {
            dropRandomItem(playerId); // Random item drop
        } else if (eventType == 5) {
            player.gold += 50; // Treasure found
        } else if (eventType == 6) {
            player.defense += 3; // Random event increases defense
        }
    }

    function addRandomChapter() internal {
        uint256 chapterId = nextPlayerId; // Use nextPlayerId as the new chapter ID
        string memory description = string(abi.encodePacked("Randomly generated chapter #", Strings.toString(chapterId)));
        chapterDescriptions[chapterId] = description;

        chapterEffects[chapterId][1] = random(5, 20); // Random health increase
        chapterEffects[chapterId][2] = random(1, 10); // Random attack increase
        chapterEffects[chapterId][3] = random(1, 10); // Random defense increase
    }

    function dropRandomItem(uint256 playerId) internal {
        uint256 itemId = random(1000, 10000); // Generate a random item ID
        string memory itemName = string(abi.encodePacked("Mystery Item #", Strings.toString(itemId)));
        uint256 itemAttackValue = random(1, 10);
        uint256 itemDefenseValue = random(1, 10);
        uint256 itemLevelValue = random(1, 5);

        itemNames[itemId] = itemName;
        itemAttack[itemId] = itemAttackValue;
        itemDefense[itemId] = itemDefenseValue;
        itemLevel[itemId] = itemLevelValue;

        emit ItemDropped(ownerOf(playerId), itemId, itemName);
    }

function generateSVG(uint256 playerId) internal view returns (string memory) {
    Player memory player = players[playerId];
    string memory svg = string(abi.encodePacked(
        _getSVGHeader(),
        _getPlayerInfo(playerId, player),
        _getPlayerBars(player),
        _getSVGFooter()
    ));
    return svg;
}

function _getSVGHeader() internal pure returns (string memory) {
    return string(abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" style="background-color:#001f3f;">',
        '<rect x="10" y="10" width="480" height="480" fill="#001f3f" stroke="#FFDC00" stroke-width="2"/>',
        '<text x="20" y="40" font-family="Courier New" font-size="15" fill="#FFDC00">',
        'JK Labs RPG Game Prototype</text>'
    ));
}

function _getPlayerInfo(uint256 playerId, Player memory player) internal pure returns (string memory) {
    return string(abi.encodePacked(
        '<text x="20" y="70" font-family="Courier New" font-size="14" fill="#FFFFFF">',
        'Player ID: ', Strings.toString(playerId), '</text>',
        '<text x="20" y="90" font-family="Courier New" font-size="14" fill="#FFFFFF">',
        'Level: ', Strings.toString(player.level), '</text>',
        '<text x="20" y="110" font-family="Courier New" font-size="14" fill="#FFFFFF">',
        'Gold: ', Strings.toString(player.gold), '</text>'
    ));
}

function _getPlayerBars(Player memory player) internal pure returns (string memory) {
    return string(abi.encodePacked(
        '<rect x="20" y="140" width="', Strings.toString(player.health * 2), '" height="15" fill="#FF851B"/>',
        '<text x="20" y="160" font-family="Courier New" font-size="12" fill="#FFFFFF">',
        'Health: ', Strings.toString(player.health), '</text>',
        '<rect x="20" y="180" width="', Strings.toString(player.attack * 2), '" height="15" fill="#FF851B"/>',
        '<text x="20" y="200" font-family="Courier New" font-size="12" fill="#FFFFFF">',
        'Attack: ', Strings.toString(player.attack), '</text>',
        '<rect x="20" y="220" width="', Strings.toString(player.defense * 2), '" height="15" fill="#FF851B"/>',
        '<text x="20" y="240" font-family="Courier New" font-size="12" fill="#FFFFFF">',
        'Defense: ', Strings.toString(player.defense), '</text>'
    ));
}

function _getSVGFooter() internal pure returns (string memory) {
    return '</svg>';
}


    function generateTokenURI(uint256 playerId) internal view returns (string memory) {
        string memory svg = generateSVG(playerId);
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "Player #', Strings.toString(playerId), '",',
            '"description": "A dynamic player NFT",',
            '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ))));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Utility Functions
    function random(uint256 min, uint256 max) public returns (uint256) {
        require(max > min, "Max must be greater than min");

        bytes32 jklabsRandomHash = keccak256(
            abi.encodePacked(
                block.timestamp,          // Current block timestamp
                block.difficulty,         // Current block difficulty
                block.coinbase,           // Address of the miner
                blockhash(block.number - 1), // Hash of the previous block
                msg.sender,               // Address of the sender
                nonce++                   // Incrementing nonce
            )
        );
        return (uint256(jklabsRandomHash) % (max - min + 1)) + min;
    }
}
