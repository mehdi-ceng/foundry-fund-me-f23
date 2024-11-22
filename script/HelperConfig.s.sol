//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//1. Will be used to deploy mocks when we are on local chain (using anvil)
//2. Will be used to keep track of address across different chains
// such as Sepolia ETH/USD, Mainnet ETH/USD and so on

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //If  we are on local anvil chain, deploy mocks
    //Otherwise grab the existing addres from the live network
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor(){
        if(block.chainid == 11155111){ //every chain has their own chain id. 11155111 belongs to sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if(block.chainid==1){
           activeNetworkConfig =  getMainnetEthConfig();
        }else{
            activeNetworkConfig = getAnvilEthConfig();
        }

    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return mainnetConfig;
    }

    function getAnvilEthConfig() public returns(NetworkConfig memory){ //not pure function, 
        //1. Create mocks
        //2. Return mock address

        //to be able deploy contracts to anvil change
        vm.startBroadcast();
        //By looking at constructor() in ../test/mocks/MockV3Aggregator.sol file,
        //we know how to create MockV3Aggregator type
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
 
}