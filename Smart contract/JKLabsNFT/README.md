# JKLabNFT Smart Contract

**Date:** 2023-09-20
**Author:** [JackyKit](https://3jk.net)

https://polygonscan.com/address/0xa147730f7e52d91a6be5636d1a70163230afcf1a#code

## Overview

The `JKLabNFT` smart contract is a modular and upgradeable ERC721 implementation. It manages NFT minting and ownership within event-driven scenarios, allowing event managers to create and distribute NFTs based on specific participation criteria and secret phrases. This contract supports a range of functions to interact with the NFTs.

## Smart Contract Structure

The smart contract is made up of several sections.

### 1. Attaching Libraries

The contract utilizes various libraries and external contracts to enhance functionality:

```solidity
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";
import "./lib/Hashing.sol";
import "./ERC2771ContextUpgradeable.sol";
import "./IEvent.sol";
import "./ISecretPhraseVerifier.sol";
```

### 2. Declarations

This section includes all the core declarations and initializations, including state variables, structures, and mappings:

```solidity
contract JKLabNFT is
    ERC721EnumerableUpgradeable,
    ERC2771ContextUpgradeable,
    OwnableUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private eventManagerAddr;
    address private secretPhraseVerifierAddr;

    struct NFTAttribute {
        string metaDataURL;
        uint256 requiredParticipateCount;
    }

    struct NFTHolder {
        address holderAddress;
        uint256 tokenId;
    }

    struct NFTHolderWithEventId {
        address holderAddress;
        uint256 eventId;
        uint256 tokenId;
    }

    // NFT meta data url via tokenId
    mapping(uint256 => string) private nftMetaDataURL;
    // Holding NFT via hash of eventId and address
    mapping(bytes32 => bool) private isHoldingEventNFT;
    // Participate count via hash of groupId and address hash
    mapping(bytes32 => uint256) private countOfParticipation;
    // NFT attribute location (ex. ipfs, centralized storage) via hash of participateCount, eventId
    mapping(bytes32 => string) private eventNftAttributes;
    // remaining mint count of Event
    mapping(uint256 => uint256) private remainingEventNftCount;
    // secretPhrase via EventId
    mapping(uint256 => bytes32) private eventSecretPhrases;
    // is mint locked via EventId
    mapping(uint256 => bool) private isMintLocked;

    // Create a mapping to store NFT holders by event ID
    mapping(uint256 => uint256[]) private tokenIdsByEvent;
}
```

### 3. Events

Events log key actions and are essential for off-chain applications to track contract activity:

```solidity
event MintedNFTAttributeURL(address indexed holder, string url);
event MintLocked(uint256 indexed eventId, bool isLocked);
event ResetSecretPhrase(address indexed executor, uint256 indexed eventId);
```

### 4. Modifiers

Modifiers are used to control access and enforce rules for specific functions:

```solidity
modifier onlyGroupOwner(uint256 _eventId) {
    IEventManager eventManager = IEventManager(eventManagerAddr);
    require(
        eventManager.isGroupOwnerByEventId(msg.sender, _eventId),
        "you are not event group owner"
    );
    _;
}
```

### 5. Admin Functions

Admin functions are reserved for contract owners or designated administrators to manage critical aspects of the contract:

```solidity
function setEventManagerAddr(address _addr) public onlyOwner {
    require(_addr != address(0), "event manager address is blank");
    eventManagerAddr = _addr;
}

function changeMintLocked(
    uint256 _eventId,
    bool _locked
) external onlyGroupOwner(_eventId) {
    isMintLocked[_eventId] = _locked;
    emit MintLocked(_eventId, _locked);
}

function resetSecretPhrase(
    uint256 _eventId,
    bytes32 _secretPhrase
) external onlyGroupOwner(_eventId) {
    eventSecretPhrases[_eventId] = _secretPhrase;
    emit ResetSecretPhrase(_msgSender(), _eventId);
}

function setEventInfo(
    uint256 _eventId,
    uint256 _mintLimit,
    bytes32 _secretPhrase,
    NFTAttribute[] memory attributes
) external {
    require(_msgSender() == eventManagerAddr, "unauthorized");
    remainingEventNftCount[_eventId] = _mintLimit;
    eventSecretPhrases[_eventId] = _secretPhrase;
    for (uint256 index = 0; index < attributes.length; index++) {
        eventNftAttributes[
            Hashing.hashingDoubleUint256(
                _eventId,
                attributes[index].requiredParticipateCount
            )
        ] = attributes[index].metaDataURL;
    }
}

function burn(uint256 tokenId) public onlyOwner {
    _burn(tokenId);
}
```

### 6. Getter Functions

Getter functions allow retrieval of specific contract data, aiding in transparency and interaction:

```solidity
function getIsMintLocked(uint256 _eventId) external view returns (bool) {
    return isMintLocked[_eventId];
}

function isHoldingEventNFTByAddress(
    address _addr,
    uint256 _eventId
) public view returns (bool) {
    return
        isHoldingEventNFT[Hashing.hashingAddressUint256(_addr, _eventId)];
}

function getRemainingNFTCount(
    uint256 _eventId
) external view returns (uint256) {
    return remainingEventNftCount[_eventId];
}

function tokenURI(
    uint256 _tokenId
) public view override returns (string memory) {
    string memory metaDataURL = nftMetaDataURL[_tokenId];
    return metaDataURL;
}
```

### 7. Main Functions

These are the primary functions that handle the minting process and other core operations:

```solidity
function mintParticipateNFT(
    uint256 _groupId,
    uint256 _eventId,
    uint256[24] memory _proof
) external {
    canMint(_eventId, _proof);
    remainingEventNftCount[_eventId] = remainingEventNftCount[_eventId] - 1;

    ISecretPhraseVerifier secretPhraseVerifier = ISecretPhraseVerifier(
        secretPhraseVerifierAddr
    );
    secretPhraseVerifier.submitProof(_proof, _eventId);

    isHoldingEventNFT[
        Hashing.hashingAddressUint256(_msgSender(), _eventId)
    ] = true;

    bytes32 groupHash = Hashing.hashingAddressUint256(
        _msgSender(),
        _groupId
    );
    uint256 participationCount = countOfParticipation[groupHash];
    countOfParticipation[groupHash] = participationCount + 1;

    string memory metaDataURL = eventNftAttributes[
        Hashing.hashingDoubleUint256(_eventId, 0)
    ];
    string memory specialMetaDataURL = eventNftAttributes[
        Hashing.hashingDoubleUint256(_eventId, participationCount)
    ];
    if (
        keccak256(abi.encodePacked(specialMetaDataURL)) !=
        keccak256(abi.encodePacked(""))
    ) {
        metaDataURL = specialMetaDataURL;
    }

    nftMetaDataURL[_tokenIds.current()] = metaDataURL;
    tokenIdsByEvent[_eventId].push(_tokenIds.current());
    _safeMint(_msgSender(), _tokenIds.current());

    _tokenIds.increment();
    emit MintedNFTAttributeURL(_msgSender(), metaDataURL);
}

function canMint(
    uint256 _eventId,
    uint256[24] memory _proof
) public view returns (bool) {
    require(verifySecretPhrase(_proof, _eventId), "invalid secret phrase");
    require(
        remainingEventNftCount[_eventId] != 0,
        "remaining count is zero"
    );

    require(
        !isHoldingEventNFTByAddress(_msgSender(), _eventId),
        "already minted"
    );

    require(!isMintLocked[_eventId], "mint is locked");

    return true;
}
```

### 8. Internal Functions

Internal functions handle verification processes and other behind-the-scenes logic:

```solidity
function verifySecretPhrase(
    uint256[24] memory _proof,
    uint256 _eventId
) internal view returns (bool) {
    ISecretPhraseVerifier secretPhraseVerifier = ISecretPhraseVerifier(
        secretPhraseVerifierAddr
    );
    uint256[1] memory publicInput = [uint256(eventSecretPhrases[_eventId])];
    bool result = secretPhraseVerifier.verifyProof(
        _proof,
        publicInput,
        _eventId
    );
    return result;
}
```

### 9. Utility Functions

Utility functions provide additional functionality for interacting with the NFTs and retrieving data:

```solidity
function _msgSender()
    internal
    view
    virtual
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (address sender)
{
    if (isTrustedForwarder(msg.sender)) {
        // The assembly code is more direct than the Solidity version using `abi.decode`.
        /// @solidity memory-safe-assembly
        assembly {
            sender := shr(96, calldataload

(sub(calldatasize(), 20)))
        }
    } else {
        return super._msgSender();
    }
}

function _msgData()
    internal
    view
    virtual
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (bytes calldata)
{
    if (isTrustedForwarder(msg.sender)) {
        return msg.data[:msg.data.length - 20];
    } else {
        return super._msgData();
    }
}

// Function to return a list of owners from an array of token IDs
function ownerOfTokens(
    uint256[] memory _tokenIdArray
) public view returns (NFTHolder[] memory) {
    NFTHolder[] memory holders = new NFTHolder[](_tokenIdArray.length);
    for (uint256 index = 0; index < _tokenIdArray.length; index++) {
        holders[index] = NFTHolder(
            ownerOf(_tokenIdArray[index]),
            _tokenIdArray[index]
        );
    }
    return holders;
}

// Function to return a list of NFT holders for a specific event ID
function getNFTHoldersByEvent(
    uint256 _eventId
) public view returns (NFTHolder[] memory) {
    return ownerOfTokens(tokenIdsByEvent[_eventId]);
}

// Function to return a list of NFT holders for a specific event group ID
function getNFTHoldersByEventGroup(
    uint256 _groupId
) public view returns (NFTHolderWithEventId[] memory) {
    IEventManager eventManager = IEventManager(eventManagerAddr);
    EventRecord[] memory eventIds = eventManager.getEventRecordsByGroupId(
        _groupId
    );
    NFTHolder[][] memory tempHolders = new NFTHolder[][](eventIds.length);
    uint256 tokenidsLength = 0;
    for (uint256 index = 0; index < eventIds.length; index++) {
        tempHolders[index] = getNFTHoldersByEvent(
            eventIds[index].eventRecordId
        );
        tokenidsLength = tokenidsLength + tempHolders[index].length;
    }
    NFTHolderWithEventId[] memory holders = new NFTHolderWithEventId[](
        tokenidsLength
    );
    uint256 counter = 0;
    while (counter < tokenidsLength) {
        for (uint256 index = 0; index < eventIds.length; index++) {
            for (
                uint256 index2 = 0;
                index2 < tempHolders[index].length;
                index2++
            ) {
                holders[counter] = NFTHolderWithEventId(
                    tempHolders[index][index2].holderAddress,
                    eventIds[index].eventRecordId,
                    tempHolders[index][index2].tokenId
                );
                counter++;
            }
        }
    }
    return holders;
}
```

## How to Use

1. **Deployment:** Deploy the contract to the Ethereum network.
2. **Minting NFTs:** Use the `mintParticipateNFT` function to mint event-based NFTs.
3. **Admin Functions:** Admins can manage events, lock minting, and reset secret phrases using the provided admin functions.

## Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) for their extensive and secure contract libraries.
- The Ethereum community for ongoing development and support.

---
feel free to reach out to me on [X](https://x.com/kitjacky)  
JK Labs : https://3jk.net
