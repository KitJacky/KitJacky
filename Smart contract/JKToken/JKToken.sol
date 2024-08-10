// File: contracts/JKToken.sol

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Declarations
contract JKToken is ERC20Burnable, Ownable {
    /**
     * @notice Constructs the JKToken token ERC-20 contract.
     */
    constructor() public ERC20('JKToken', 'JKT') {}

    // Main Functions
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

    function burn(uint256 amount) public override onlyOwner {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        onlyOwner
    {
        super.burnFrom(account, amount);
    }
}
