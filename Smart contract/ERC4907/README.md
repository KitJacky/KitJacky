# ERC4907 Smart Contract

**File:** contracts/ERC4907.sol
Etherscan: https://etherscan.io/address/0x148c361030ed3768eefc2daf98fa0bc0a39bfa95#code

## Overview

The `ERC4907` contract is an extension of the ERC-721 standard, implementing the ERC-4907 interface which adds a "user" role to NFTs. This allows the owner of an NFT to delegate usage rights to another address for a specified period without transferring ownership. The contract is built using the `ERC721Base` from Thirdweb and includes functionality for setting and retrieving the user of an NFT, as well as checking the expiration of the user role.

## Smart Contract Structure

The smart contract is organized into several key sections:

### 1. Attaching Libraries

The contract imports the following libraries and contracts:

- **ERC721Base:** A base contract from Thirdweb for ERC-721 functionality.
- **IERC4907:** Interface for the ERC-4907 standard, adding the user role to NFTs.

```solidity
import "@thirdweb-dev/contracts/base/ERC721Base.sol";
import "./IERC4907.sol";
```

### 2. Declarations

This section includes the declaration of the `ERC4907` contract, along with its state variables and initial setup:

```solidity
contract ERC4907 is ERC721Base, IERC4907 {
    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping(uint256 => UserInfo) internal _users;

    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) ERC721Base(_name, _symbol, _royaltyRecipient, _royaltyBps) {}
}
```

### 3. Main Functions

These are the core functions of the contract that handle the primary functionality, such as setting and retrieving the user role and its expiration:

#### `setUser`

This function allows the owner or approved operator of an NFT to assign a user role to another address, along with an expiration timestamp.

```solidity
/**
 * @notice Set the user and expires of a NFT
 * @dev The zero address indicates there is no user
 * @param user The new user of the NFT
 * @param expires UNIX timestamp, The new user could use the NFT before expires
 */
function setUser(
    uint256 tokenId,
    address user,
    uint64 expires
) public virtual {
    require(
        isApprovedOrOwner(msg.sender, tokenId),
        "ERC721: transfer caller is not owner nor approved"
    );
    UserInfo storage info = _users[tokenId];
    info.user = user;
    info.expires = expires;
    emit UpdateUser(tokenId, user, expires);
}
```

#### `userOf`

This function returns the current user of the NFT if the user role has not expired. If expired or not set, it returns the zero address.

```solidity
/**
 * @notice Get the user address of an NFT
 * @param tokenId The NFT to get the user address for
 * @return The user address for this NFT
 */
function userOf(uint256 tokenId) public view virtual returns (address) {
    if (uint256(_users[tokenId].expires) >= block.timestamp) {
        return _users[tokenId].user;
    } else {
        return address(0);
    }
}
```

#### `userExpires`

This function returns the expiration timestamp of the current user role for the NFT.

```solidity
/**
 * @notice Get the user expires of an NFT
 * @param tokenId The NFT to get the user expires for
 * @return The user expires for this NFT
 */
function userExpires(uint256 tokenId)
    public
    view
    virtual
    returns (uint256)
{
    return _users[tokenId].expires;
}
```

### 4. Interface Support

The contract includes an override of the `supportsInterface` function to declare support for the ERC-4907 interface.

```solidity
/**
 * @dev See {IERC165-supportsInterface}.
 */
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
{
    return
        interfaceId == type(IERC4907).interfaceId ||
        super.supportsInterface(interfaceId);
}
```

---
feel free to reach out to me on [X](https://x.com/kitjacky)  
JK Labs : https://3jk.net
