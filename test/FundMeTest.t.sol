//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
/*After refactoring FundMe.sol and PriceConvertor.sol, 
our deployment and test scripts is also needed to change.
But we can refactor our test script by importing DeployFundMe, 
so that we do not change it after we make changes to deploy scripts.
changed. W 
*/
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    function setUp() external {
        //fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); //returns FundMe contract
    }

    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        //us(i.e. msg.sender) -> FundMeTest(this)-> fundMe
        //msg.sender is not equal to fundMe.i_owner
        //assertEq(fundMe.i_owner(), msg.sender); will fail
        assertEq(fundMe.i_owner(), address(this));
        //BUT: after refactoring above code will fail, now msg.sender will work...not important for now.
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}