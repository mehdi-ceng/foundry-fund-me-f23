//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        //us(i.e. msg.sender) -> FundMeTest(this)-> fundMe
        //msg.sender is not equal to fundMe.i_owner
        //assertEq(fundMe.i_owner(), msg.sender); will fail
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}