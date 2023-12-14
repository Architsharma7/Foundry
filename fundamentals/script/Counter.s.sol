// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    // function setUp() public {}

    function run() external returns (Counter) {
        vm.broadcast();
        // every transaction should be inside broadcast and stopbroadcast, define your vairables and constants before broadcast
        Counter counter = new Counter();
        // vm.stopBroadcast();
        return counter;
    }
}
