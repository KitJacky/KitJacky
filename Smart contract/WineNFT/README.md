# WineNFT Smart Contract

**File:** contracts/WineNFT.sol
**Author:** [JackyKit](https://3jk.net)

Opensea : https://opensea.io/collection/nftgiftdemo
Polygonscan : https://polygonscan.com/token/0xed12bd4441e414e0f6c295d11dbf7a849d50bbf8#code


## Overview

The `WineNFT` contract is a specialized ERC-721 token that represents a limited collection of wine-themed NFTs. The contract includes functionality for minting tokens, managing a whitelist, handling royalty payments, and pausing the sale. It is built with security and flexibility in mind, using OpenZeppelin's standard libraries and includes role-based access control.

## Metadata Management

In addition to the smart contract, a PHP-based metadata CMS and API system has been developed to manage all structural content of the metadata and demonstrate redeeming NFTs for physical items. The metadata system allows for detailed management of the NFTs, providing rich descriptions and attributes.

### Example Metadata API

Here’s an example of the metadata structure available through the API:

```json
{
    "name": "Picasso x Moutai Thematic Gift-Case NFTs #1",
    "description": "In memory of Picasso’s 50th Death Anniversary. Recreating an Art-piece by Integrating China’s National Brand, Western Art and Wine-tasting Culture With Advanced Technology.",
    "image": "ipfs://bafybeihkr7div2d7i4yoei27bm5rp3x5lhmihxrjzfsmxlawelwxuhkmqy/1.jpg",
    "edition": 1,
    "attributes": [
        {
            "trait_type": "Physical",
            "value": "Gift-Case NFTs"
        },
        {
            "trait_type": "Case",
            "value": "Picasso x Moutai"
        },
        {
            "trait_type": "Status",
            "value": "Unredeemed"
        }
    ]
}
```

You can access the API via the following URL:
[https://metadata-api.3jk.net/26b93f28-9dec-420d-a455-cb95e3877719/1](https://metadata-api.3jk.net/26b93f28-9dec-420d-a455-cb95e3877719/1)

## Smart Contract Structure

The smart contract is organized into several key sections:

### 1. Attaching Libraries

The contract utilizes several libraries and contracts from OpenZeppelin to provide standard functionalities such as token management, access control, and royalties:

```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
```

### 2. Declarations

This section includes the declaration of the `WineNFT` contract, including state variables and initial configurations:

```solidity
contract WineNFT is ERC721, Pausable, ERC2981, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 constant MAX_TOKENS = 10000;
    uint256 constant MINT_PRICE = 0.028 ether;
    string baseTokenURI;

    mapping(address => bool) whiteList;
}
```

### 3. Constructor

The constructor initializes the contract with the necessary roles, base URI, and default royalty information:

```solidity
constructor(
    string memory _URI,
    address _defaultAdmin,
    address _receiver,
    uint96 _feeNumerator
) ERC721("WineNFT", "WINE") {
    _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    _setupRole(ADMIN_ROLE, _defaultAdmin);
    _setDefaultRoyalty(_receiver, _feeNumerator);
    setBaseURI(_URI);
}
```

### 4. Modifiers

Modifiers are used to enforce certain conditions, such as ensuring the total minted tokens do not exceed the maximum supply:

```solidity
modifier collectionEnded(uint256 _count) {
    uint256 total = totalMinted();
    require(total + _count <= MAX_TOKENS, "Max limit");
    _;
}
```

### 5. Admin Functions

These functions are reserved for the contract's administrators, allowing them to manage critical aspects of the contract:

```solidity
function freeMintForAdmin(
    uint256 _count
) external onlyRole(ADMIN_ROLE) whenNotPaused collectionEnded(_count) {
    for (uint256 i = 0; i < _count; i++) {
        _mintAnElement(msg.sender);
    }
}

function addUserToWhiteList(address _user) external onlyRole(ADMIN_ROLE) {
    require(!whiteList[_user], "Already in WL");
    whiteList[_user] = true;
}

function saleOff() external onlyRole(ADMIN_ROLE) {
    _pause();
}

function saleOn() external onlyRole(ADMIN_ROLE) {
    _unpause();
}

function widthdraw(address _address) external onlyRole(ADMIN_ROLE) {
    uint256 amount = address(this).balance;
    (bool success, ) = _address.call{value: amount}("");
    require(success, "Transfer failed.");
}
```

### 6. Getter Functions

These functions provide read-only access to various aspects of the contract, such as the mint price, whitelist status, and total minted tokens:

```solidity
function mintPrice() public pure returns (uint256) {
    return MINT_PRICE;
}

function totalCollectionAmount() public pure returns (uint256) {
    return MAX_TOKENS;
}

function checkWhiteList(address _user) external view returns (bool) {
    return whiteList[_user];
}

function adminRole() public pure returns (bytes32) {
    return ADMIN_ROLE;
}

function totalMinted() public view returns (uint256) {
    return _tokenIdCounter.current();
}

function checkCollectionURI() external view returns (string memory) {
    return _baseURI();
}
```

### 7. Setter Functions

Setter functions allow for the modification of certain contract properties, such as the base URI for the token metadata:

```solidity
function setBaseURI(string memory baseURI) public {
    baseTokenURI = baseURI;
}
```

### 8. Main Functions

The main functions handle the core functionality of the contract, including minting new tokens and allowing whitelist members to mint for free:

```solidity
function mint(
    uint256 _count
) external payable whenNotPaused collectionEnded(_count) {
    require(
        msg.value >= (MINT_PRICE * _count),
        "Not enough Ether for mint"
    );
    for (uint256 i = 0; i < _count; i++) {
        _mintAnElement(msg.sender);
    }
}

function freeMintForUser(
    uint256 _count
) external whenNotPaused collectionEnded(_count) {
    require(whiteList[msg.sender], "You are not in WL");
    for (uint256 i = 0; i < _count; i++) {
        _mintAnElement(msg.sender);
    }
}
```

### 9. Internal Functions

Internal functions are used for operations that should not be directly accessible from outside the contract, such as minting a new element:

```solidity
function _mintAnElement(address _to) private {
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(_to, tokenId);
}

function _baseURI() internal view virtual override returns (string memory) {
    return baseTokenURI;
}
```

### 10. Overrides

Override functions are used to customize inherited functionality, such as token transfers and interface support:

```solidity
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
) internal override {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
}

function _transfer(
    address from,
    address to,
    uint256 tokenId
) internal virtual override {
    require(hasRole(ADMIN_ROLE, from), "Only admin can transfer NFTs");
    super._transfer(from, to, tokenId);
}

function supportsInterface(
    bytes4 interfaceId
) public view override(AccessControl, ERC2981, ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
}
```

## How to Use

1. **Deployment:** Deploy the contract to the Ethereum network with the initial parameters.
2. **Minting Tokens:** Users can mint tokens by paying the required Ether, provided the sale is not paused.
3. **Admin Functions:** Admins can manage the whitelist, pause the sale, and withdraw funds.
4. **Metadata API:** Utilize the PHP-based metadata CMS and API to manage and redeem NFT metadata.

## Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) for providing robust and secure libraries for smart contract development.

---
feel free to reach out to me on [X](https://x.com/kitjacky)  
JK Labs : https://3jk.net
