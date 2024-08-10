# JKToken Smart Contract

**File:** contracts/JKToken.sol
https://etherscan.io/address/0x2dfa626d8cd1428aa72e5306c4b999e7754c8d6d

## Overview

The "JKToken" contract is an ERC-20 compliant token that is still functioning properly despite being many years old. The token has additional features such as minting and burning. The contract is built using OpenZeppelin's secure and well-tested libraries to ensure that tokens are ERC-20 compliant, while providing enhanced functionality through owner-controlled minting and burning.

## Smart Contract Structure

The smart contract is organized into several key sections:

### 1. Attaching Libraries

The contract imports the following libraries from OpenZeppelin:

- **ERC20Burnable:** Provides the functionality to burn tokens, reducing the total supply.
- **Ownable:** Restricts certain functions to the contract owner.

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

### 2. Declarations

This section includes the declaration of the `JKToken` contract, inheriting from `ERC20Burnable` and `Ownable`.

```solidity
contract JKToken is ERC20Burnable, Ownable {
    /**
     * @notice Constructs the JKToken token ERC-20 contract.
     */
    constructor() public ERC20('JKToken', 'JKT') {}
}
```

### 3. Main Functions

The main functions of the contract include minting and burning tokens. These functions are restricted to the contract owner, ensuring controlled issuance and destruction of tokens.

#### Mint Function

This function allows the owner to mint new tokens and send them to a specified recipient.

```solidity
/**
 * @notice Operator mints JKToken token to a recipient
 * @param recipient_ The address of recipient
 * @param amount_ The amount of JKToken token to mint to
 * @return whether the process has been done
 */
function mint(address recipient_, uint256 amount_)
    public
    onlyOwner
    returns (bool)
{
    uint256 balanceBefore = balanceOf(recipient_);
    _mint(recipient_, amount_);
    uint256 balanceAfter = balanceOf(recipient_);

    return balanceAfter > balanceBefore;
}
```

#### Burn Function

The `burn` function allows the owner to destroy a specific amount of tokens from their balance, reducing the total supply.

```solidity
function burn(uint256 amount) public override onlyOwner {
    super.burn(amount);
}
```

#### BurnFrom Function

This function allows the owner to burn tokens from another account, provided that the account has allowed the owner to do so.

```solidity
function burnFrom(address account, uint256 amount)
    public
    override
    onlyOwner
{
    super.burnFrom(account, amount);
}
```

## How to Use

1. **Deployment:** Deploy the contract on an Ethereum network.
2. **Minting Tokens:** The contract owner can mint new tokens using the `mint` function.
3. **Burning Tokens:** The owner can reduce the total supply by burning their tokens or by burning tokens from other accounts with `burnFrom`.

## Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) for providing the libraries that ensure the security and functionality of the token contract.

---

JK Labs : https://3jk.net
