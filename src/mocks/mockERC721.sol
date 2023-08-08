// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Mock_ERC721 is ERC721Enumerable {
  uint256 currentSupply;

  constructor() ERC721("MOCK_NFT", "MNFT") {}

  function mint(address _to, uint256 amount) external payable {
    uint256 startingIndex;
    unchecked {
      startingIndex = currentSupply + 1;
      currentSupply += amount;
    }
    for (uint256 i; i < amount; ) {
      _mint(_to, startingIndex + i);
      unchecked {
        i++;
      }
    }
  }

  function safeMint(address to, uint256 amount) external payable {
    uint256 startingIndex;
    unchecked {
      startingIndex = currentSupply + 1;
      currentSupply += amount;
    }

    for (uint256 i; i < amount; ) {
      _safeMint(to, startingIndex + i);
      unchecked {
        i++;
      }
    }
  }

  // function burn(uint256 tokenId) external {
  //   _burn(tokenId);
  // }
}
