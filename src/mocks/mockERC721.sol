// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Mock_ERC721 is ERC721, ERC721Enumerable, ERC721URIStorage {
    uint256 currentSupply;

    constructor() ERC721("MOCK_NFT", "MNFT") {}

    function mint(
        address _to,
        uint256 amount,
        string memory uri
    ) external payable {
        uint256 startingIndex;
        unchecked {
            startingIndex = currentSupply + 1;
            currentSupply += amount;
        }
        for (uint256 i; i < amount; ) {
            _mint(_to, startingIndex + i);
            _setTokenURI((startingIndex + i), uri);
            unchecked {
                i++;
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
