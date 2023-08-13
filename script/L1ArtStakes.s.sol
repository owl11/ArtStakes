// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import {Script} from "forge-std/Script.sol";
import "../src/L1ArtStakes.sol";

contract deployStakerFactory is Script {
    ArtStakes_Staker public factory;
    address public deployer;

    function run() public returns (ArtStakes_Staker) {
        vm.startBroadcast();
        factory = new ArtStakes_Staker();
        return (factory);
    }
}
