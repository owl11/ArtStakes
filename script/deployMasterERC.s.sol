// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import "../src/AS_ERC20.sol";
import "../src/AS_ERC721X.sol";

contract deployXtokens is Script {
    AS_ERC20 public erc20;
    ERC721X public erc721x;
    string name;
    string symbol;
    string uri =
        "ipfs://QmTX4qgXszxfvSL2WQYqQBaoXcfJZwRUb3LbaY8RQfPm5m?filename=PKB.json";
    uint256 totalSupply;
    address owner = msg.sender;
    address l1Collection = address(0x01);

    function run() public returns (AS_ERC20, ERC721X) {
        vm.startBroadcast();
        erc20 = new AS_ERC20(
            name,
            symbol,
            totalSupply,
            address(0x6),
            owner,
            l1Collection
        );
        erc721x = new ERC721X(name, symbol, owner);
        erc721x.safeMint(owner, uri);
        return (erc20, erc721x);
    }
}
