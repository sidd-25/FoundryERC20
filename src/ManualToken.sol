// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ManualToken {
    
    mapping (address => uint256) public s_balances;

    function name() public pure returns (string memory) {
        return "ManualToken";
    }
    // OR can use instead of function name -->
    // string public name = "ManualToken";

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimal() public pure returns (uint256) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 totalInitialBalance = balanceOf(msg.sender) + balanceOf(_to);

        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;

        uint256 totalFinalBalance = balanceOf(msg.sender) + balanceOf(_to);

        require(totalInitialBalance == totalFinalBalance);
    }

}
