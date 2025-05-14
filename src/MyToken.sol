// SPDX-License-Identifier: MIT

//Powered by ChatGPT - Manual ERC-20 Standard Token

pragma solidity ^0.8.0;

contract MyToken {
    string public name = "MyToken";        // Optional: token name
    string public symbol = "MTK";          // Optional: token symbol
    uint8 public decimals = 18;            // Optional: token decimals
    uint256 public totalSupply;            // Total tokens in circulation

    mapping(address => uint256) private balances;                  // Stores balance of each user
    mapping(address => mapping(address => uint256)) private allowed; // Stores allowance: owner => spender => amount

    // EVENTS 🔽
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // CONSTRUCTOR 🔽
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals)); // e.g., 1000 tokens -> 1000 * 10^18
        balances[msg.sender] = totalSupply; // Assign all tokens to contract deployer
        emit Transfer(address(0), msg.sender, totalSupply); // Emit minting event
    }

    // ✅ balanceOf(): Check account balance
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // ✅ transfer(): Send tokens from caller to someone else
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // ✅ approve(): Allow spender to spend tokens on behalf of msg.sender
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // ✅ allowance(): Check how much spender can still spend
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    // ✅ transferFrom(): Spender transfers tokens from owner to another address
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_from != address(0) && _to != address(0), "Invalid address");
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _amount, "Allowance exceeded");

        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowed[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }
}
