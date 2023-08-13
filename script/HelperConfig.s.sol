// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.5;

// import {Script} from "forge-std/Script.sol";

// contract HelperConfig is Script {
//     NetworkConfig public activeNetworkConfig;

//     struct NetworkConfig {
//         address XDomainMessangerAddress;
//     }
    
//     event CrossDomainMock(address crossDomain);
    
//     constructor() {
//         if (block.chainid == 5) {
//             activeNetworkConfig = getGoerliEthConfig();
//         } else {
//             activeNetworkConfig = getOrCreateAnvilEthConfig();
//         }
// }

// function getGoerliEthConfig() public returns (NetworkConfig memory goerliEthConfig)
//     goerliEthConfig = NetworkConfig(
//         xDomainMessageSender: XDomainMessangerAddress
//     )
// }
