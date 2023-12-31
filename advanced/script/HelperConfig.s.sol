//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {

    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSeploiaEthConfig();
        }else{
            activeNetworkConfig = getorCreateAnvilEthConfig();
        }
    }

    function getSeploiaEthConfig() public view returns(NetworkConfig memory) {
        return NetworkConfig({
            wethUsdPriceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcUsdPriceFeed : 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth : 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc : 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey : vm.envUint("PRIVATE_KEY") 
        });
    }

    function getorCreateAnvilEthConfig() public view returns(NetworkConfig memory)  {
        if(activeNetworkConfig.wethUsdPriceFeed != address(0)){
            return activeNetworkConfig;
        }
        // deploy some mock v3 aggreagtors
    }
}