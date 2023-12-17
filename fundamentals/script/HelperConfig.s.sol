// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address something;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            something: address(0)
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // vm.startBroadcast();
        // deploy the contract, whose address you need
        // vm.stopBroadcast();
        // return address(0);   //return the address of deployed contract
        NetworkConfig memory anvilConfig = NetworkConfig({
            something: address(0)
        });
        return anvilConfig;
    }
}


// To use this in deploy script, you can do:
// import {HelperConfig} from "helper/HelperConfig.sol";
// HelperConfig helperConfig = new HelperConfig();
// (address helperConfigAddress) = helperConfig.activeNetworkConfig();      in parenthesises because it is a struct
// Counter counter = new Counter(helperConfigAddress);