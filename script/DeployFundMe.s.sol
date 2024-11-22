// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external returns (FundMe){
        //Anything before vm.startBroadcast is not real transaction, 
        //it is only local, thus do not cost us money.
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        //new FundMe();   this version was before refactoring
        //Following version still use hardcoded address. It will be refactored again.
        //Mock price feed will be on adress that is provide by anvil, so that
        //we can test our code completely locally
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        
        vm.stopBroadcast();
        return fundMe;
    }
}