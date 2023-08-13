// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ERC721X is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    Initializable
{
    using Counters for Counters.Counter;
    address public factory;
    address public L1NftAddr;
    Counters.Counter private _tokenIdCounter;

    constructor(
        string memory _name,
        string memory _symbol,
        address _factory
    ) ERC721(_name, _symbol) {
        initialize(_factory);
    }

    function initialize(address _Owner) public initializer {
        factory = _Owner;
        transferOwnership(factory);
    }

    function setNftL1Address(address _L1NFTAddress) public onlyOwner {
        L1NftAddr = _L1NFTAddress;
    }

    function safeMint(
        address to,
        string memory uri
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        totalSupply();
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
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

    function L1CollectionAddress() public view returns (address) {
        return L1NftAddr;
    }
}
