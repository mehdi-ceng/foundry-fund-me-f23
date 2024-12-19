//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
/*After refactoring FundMe.sol and PriceConvertor.sol, 
our deployment and test scripts is also needed to change.
But we can refactor our test script by importing DeployFundMe, 
so that we do not change it after we make changes to deploy scripts.
changed. W 
*/
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); //returns FundMe contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        //us(i.e. msg.sender) -> FundMeTest(this)-> fundMe
        //msg.sender is not equal to fundMe.i_owner
        //assertEq(fundMe.i_owner(), msg.sender); will fail
        assertEq(fundMe.getOwner(), msg.sender);
        //BUT: after refactoring above code will fail, now msg.sender will work...not important for now.
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughUSD() public{
        vm.expectRevert(); //next line should revert
        fundMe.fund(); //Calling fund with 0 usd
    }

    function testFundUpdatedFundedDataStructure() public{
        vm.prank(USER);//The next transaction is sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToFundersArray() public{
        vm.prank(USER);//The next transaction is sent by USER
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);

    }

    /*It seems we use following code:
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
    repeatedly...best practice is to use modifier to minimize code writing.
    */
   modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); 
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
 
        vm.expectRevert(); //next transaction with revert, it ignore lines related to vm
        vm.prank(USER);
        fundMe.withdraw();   
    }

    function testWithdrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        /*
        uint256 gasStart = gasleft(); //buit-in function that returns remaining gas
        vm.txGasPrice(GAS_PRICE);  //cheatcode that sets gas price for the transaction
        */
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        /*
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart-gasEnd)*tx.gasprice; //here we calculate gas used by withdraw() function call
        console.log(gasUsed);
        */

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleUserCheaper() public funded{
        //Copy pasted following test to check how much gas saved 
        //when using cheaperWithdraw() function instead of withdraw() function
        //Arrange
        //When creating address with address(num), num should be type uint160
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i =startingFunderIndex; i<numberOfFunders; i++){
            //hoax function wraps vm.prank and vm.deal
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        
        //Assert
        assert(address(fundMe).balance== 0);
        assert(startingOwnerBalance+startingFundMeBalance == fundMe.getOwner().balance);

    }

    function testWithdrawFromMultipleUser() public funded{
        //Arrange
        //When creating address with address(num), num should be type uint160
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i =startingFunderIndex; i<numberOfFunders; i++){
            //hoax function wraps vm.prank and vm.deal
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        
        //Assert
        assert(address(fundMe).balance== 0);
        assert(startingOwnerBalance+startingFundMeBalance == fundMe.getOwner().balance);

    }

}