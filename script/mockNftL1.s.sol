// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import {Script} from "forge-std/Script.sol";
import "../src/mocks/mockERC721.sol";

contract deployMockNft is Script {
    Mock_ERC721 public erc721;
    string uri =
        "ipfs://QmfSbK5EbEDKSQwjiv6imhYLg5Te3TynEFHLMNEizYv4k9?filename=PKB.png";

    function run() public returns (Mock_ERC721) {
        vm.startBroadcast();
        erc721 = new Mock_ERC721();
        erc721.mint(msg.sender, 100, uri);
        return erc721;
    }
}
