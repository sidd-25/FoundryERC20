// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {DeployOurToken} from "../../script/DeployOurToken.s.sol";
import {OurToken} from "../../src/OurToken.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployOurToken;
    OurToken public ourToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {

        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();
     /* For next piece of code very important note to refer to in notes/prankVSbroadcast */
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobStartingBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 allowingBalance = 10 ether ;

        // bob approves alice to spend on his behalf
        vm.prank(bob);
        ourToken.approve(alice, allowingBalance);

        uint256 transferAmount = 5 ether;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }



}