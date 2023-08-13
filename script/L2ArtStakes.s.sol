// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import "../src/L2ArtStakes.sol";
import "../script/deployMasterERC.s.sol";

contract deployArtStakes_Factory is Script {
    ArtStakes_Factory public factory;
    deployXtokens deployer;
    AS_ERC20 public erc20_master;
    ERC721X public erc721_master;

    function run() public returns (ArtStakes_Factory) {
        vm.startBroadcast();

        deployer = new deployXtokens();
        (erc20_master, erc721_master) = deployer.run();
        factory = new ArtStakes_Factory(
            address(erc20_master),
            address(erc721_master)
        );
        return factory;
    }
}
