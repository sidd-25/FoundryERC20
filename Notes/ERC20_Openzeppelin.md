
# ERC-20 Token with OpenZeppelin

This document provides a realistic example of creating and using an ERC-20 token using OpenZeppelin's `ERC20` contract, including minting, burning, transferring tokens, and handling allowances. The following example uses **important functions** and explains them with practical code.

---

## 🎯 Realistic Example: ERC-20 Token with Custom Logic

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1000 * 10**18;  // 1000 tokens with 18 decimals

    // Event for tracking token burns (optional, but can be useful)
    event TokensBurned(address indexed account, uint256 amount);

    constructor() ERC20("MyToken", "MTK") {
        // Mint initial supply to the contract owner
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // Mint new tokens (can be restricted to owner)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens (only owner can burn)
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // Transfer tokens to an address (override _transfer to add custom logic)
    // Example: 1% fee on transfers to a specified address (e.g., a charity or tax wallet)
    address public taxWallet = 0x1234567890abcdef1234567890abcdef12345678;

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 fee = amount.mul(1).div(100);  // 1% fee
        uint256 amountAfterFee = amount.sub(fee);

        super._transfer(sender, recipient, amountAfterFee);  // Transfer the remaining amount
        super._transfer(sender, taxWallet, fee);  // Transfer the fee to the tax wallet
    }

    // Allow spender to spend tokens on behalf of the owner
    function approveSpender(address spender, uint256 amount) external {
        approve(spender, amount);
    }

    // Transfer tokens on behalf of the owner (using transferFrom)
    function transferTokens(address from, address to, uint256 amount) external {
        transferFrom(from, to, amount);
    }

    // Example of using SafeMath for calculations to prevent overflow issues
    function safeTransfer(address recipient, uint256 amount) external {
        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance");
        
        // Using SafeMath to safely subtract the transfer amount
        uint256 newBalance = senderBalance.sub(amount);
        
        _transfer(msg.sender, recipient, amount);
    }
}
```

---

## 🧩 Key Concepts Explained in the Code

### 1. **Minting Tokens**
- **Function**: `mint(address to, uint256 amount)`
- **Why Important**: This function allows the contract owner to create new tokens. `mint()` is essential for expanding the token supply after initial deployment.
  
  ```solidity
  function mint(address to, uint256 amount) external onlyOwner {
      _mint(to, amount);
  }
  ```

### 2. **Burning Tokens**
- **Function**: `burn(uint256 amount)`
- **Why Important**: Burning tokens reduces the total supply. This is often used in deflationary tokens or for mechanics like buybacks and token burns.
  
  ```solidity
  function burn(uint256 amount) external onlyOwner {
      _burn(msg.sender, amount);
      emit TokensBurned(msg.sender, amount);
  }
  ```

### 3. **Transfer Tokens**
- **Function**: `transfer(address to, uint256 amount)`
- **Why Important**: The `transfer()` function allows the owner (or any authorized spender) to send tokens to others. It's a fundamental part of any ERC-20 token.
  
  ```solidity
  function _transfer(address sender, address recipient, uint256 amount) internal override {
      uint256 fee = amount.mul(1).div(100);  // 1% fee
      uint256 amountAfterFee = amount.sub(fee);

      super._transfer(sender, recipient, amountAfterFee);  // Transfer the remaining amount
      super._transfer(sender, taxWallet, fee);  // Transfer the fee to the tax wallet
  }
  ```

### 4. **Approve and Allowance**
- **Function**: `approve(address spender, uint256 amount)` and `transferFrom(address from, address to, uint256 amount)`
- **Why Important**: These functions allow one account to approve another to spend tokens on its behalf. This is used in cases like decentralized exchanges or vaults where third-party spending is required.
  
  ```solidity
  function approveSpender(address spender, uint256 amount) external {
      approve(spender, amount);
  }
  ```

### 5. **Custom Logic with `_transfer()`**
- **Function**: `_transfer(address sender, address recipient, uint256 amount)` – this internal function is overridden to include custom logic for token transfers.
- **Why Important**: This is where you can add hooks, such as transaction fees, time-based restrictions, or other custom logic (like fee on transfers). It's important when creating tokenomics or when you want to modify how tokens are transferred.
  
  ```solidity
  function _transfer(address sender, address recipient, uint256 amount) internal override {
      uint256 fee = amount.mul(1).div(100);  // 1% fee
      uint256 amountAfterFee = amount.sub(fee);

      super._transfer(sender, recipient, amountAfterFee);  // Transfer the remaining amount
      super._transfer(sender, taxWallet, fee);  // Transfer the fee to the tax wallet
  }
  ```

### 6. **SafeMath for Overflow Prevention**
- **Function**: Using `SafeMath` for arithmetic calculations (like subtracting balances) to prevent overflows or underflows.
- **Why Important**: This is especially important when dealing with large numbers in token transfers to avoid any unexpected behavior.

  ```solidity
  function safeTransfer(address recipient, uint256 amount) external {
      uint256 senderBalance = balanceOf(msg.sender);
      require(senderBalance >= amount, "Insufficient balance");
      
      // Using SafeMath to safely subtract the transfer amount
      uint256 newBalance = senderBalance.sub(amount);
      
      _transfer(msg.sender, recipient, amount);
  }
  ```

---

## 🧩 Summary of Key Methods

- **Very Important**:  
  - `transfer()`, `approve()`, `transferFrom()`
  - `_mint()`, `_burn()`
  - `balanceOf()`, `allowance()`

- **Important**:  
  - `_transfer()`: Overriding for custom transfer logic
  - Hooks like `_beforeTokenTransfer()` (for more advanced use-cases)

- **Optional/Advanced**:  
  - `decimals()`, `name()`, `symbol()`
  - Use of `SafeMath` for safe calculations, although Solidity 0.8+ includes built-in overflow/underflow checks

---

## 📚 Conclusion

This example demonstrates the core ERC-20 functionality in OpenZeppelin, with added features like minting, burning, transaction fees, and allowance mechanisms. Understanding these methods will give you a solid foundation to build any custom token based on ERC-20, and you can extend this logic further as needed!

Let me know if you'd like more details or further examples!
