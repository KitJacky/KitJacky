# JK Labs Bingo NFT

**Date:** 2021-09-27  
**Authors:**  
- [JK Labs](https://3jk.net)  
- [JackyKit on X](https://x.com/kitjacky)  

Bingo : https://opensea.io/collection/bingocard
Horoscope : https://opensea.io/collection/horoscope-loot

![](https://openseauserdata.com/files/73d1b346cb51e4a0b57ab83785699ed7.svg)

## Introduction
In 2021, it was still difficult to make smart contracts work properly. I started a project to create a game using smart contracts, with a focus on a decentralised bingo game. The aim was to use blockchain technology to store game data on-chain, making it secure and verifiable.

### Project Overview
The project, called JK Labs Bingo NFT v1.0, was an attempt to create a game fully integrated with the Ethereum blockchain. The idea was to use NFTs to represent bingo cards, with each card's data and image stored on the blockchain. The game used a random method to generate the Bingo card numbers, colours, and other attributes, which were then encoded into an SVG image format on the blockchain.

### Challenges in Randomness
One of the main challenges in making this game was adding random elements. It is hard to get true randomness on the blockchain because all blockchain operations are deterministic. If the method used is not complex enough, the outcome can be predicted. I used a simple method to generate random values by hashing various inputs. This approach could be predictable, which could compromise the game.

### Metadata on-chain and SVG rendering
This project was also able to store metadata on-chain and create SVG images based on this metadata. The smart contract made SVG images of the bingo cards, with random numbers and colours. This approach made the game logic and visuals decentralised, without using any external servers or databases.

### Limitations and Future Implications
The random number generation in the Bingo game on the blockchain was predictable, which was a limitation. I didn't extend the game further. The framework and methodologies developed during this project can be used for future blockchain-based game development. The experience gained in handling on-chain data, NFTs and SVG rendering is useful for future projects that may need similar things.

## Overview

This project is a decentralized Bingo game built on the Ethereum blockchain. It utilizes smart contracts to generate Bingo game cards as NFTs, with all metadata stored on-chain. The game features dynamic SVG generation, ensuring that each Bingo card is unique and fully decentralized.

## Smart Contract Structure

The smart contract is organized into several key sections, each serving a specific purpose:

### 1. Attaching Libraries

To ensure robust functionality and security, the following libraries are included:

- **ERC721:** Implements the standard interface for NFTs.
- **Ownable:** Provides ownership control over the contract.
- **ReentrancyGuard:** Protects against reentrancy attacks.
- **ERC721Enumerable:** Extends ERC721 to allow enumeration of tokens.

```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
```

### 2. Declarations

The core contract is declared here, with all necessary variables and initial setup defined:

```solidity
contract Bingo is ERC721Enumerable, ReentrancyGuard, Ownable {
    constructor() ERC721("Bingo game card", "Bingo") Ownable() {}
}
```

### 3. Events

No Events

### 4. Modifiers

Modifiers are used to enforce specific rules and conditions on functions:

```solidity
// Example Modifier
modifier onlyOwnerOrApproved() {
    require(owner() == _msgSender() || getApproved(tokenId) == _msgSender(), "Not authorized");
    _;
}
```

### 5. Admin Functions

These functions are restricted to the contract owner and allow for administrative control over the contract:

```solidity
function JKClaim(uint256 tokenId) public nonReentrant onlyOwner {
    _safeMint(owner(), tokenId);
}
```

### 6. Getter Functions

Getter functions allow users to retrieve data from the contract, such as Bingo card details or colors:

```solidity
function JKColor(uint256 tokenId) public pure returns (string memory) {
    uint256 rand = random(string(abi.encodePacked('88', toString(tokenId))));
    return string(abi.encodePacked('#', toString(rand % 7), '2', toString(rand % 9), toString(rand % 8), toString(rand % 6), '3'));
}
```

### 7. Setter Functions

No Setter functions

## How to Use

1. **Deployment:** Deploy the contract to the Ethereum network.
2. **Claiming Bingo Cards:** Use the `claim` function to mint a Bingo card NFT.
3. **Viewing Metadata:** Call the `tokenURI` function with a token ID to view its metadata.


---
feel free to reach out to me on [X](https://x.com/kitjacky)  
JK Labs : https://3jk.net
