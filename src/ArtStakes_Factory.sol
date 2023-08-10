// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721X} from "./AS_ERC721X.sol";
import {AS_ERC20} from "./AS_ERC20.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import "./ERC20Factory.sol";
import "./ERC721Factory.sol";

contract ArtStakes_Factory {
    error xNFT_AlreadyDeployed();
    ERC20Factory erc20factory;
    ERC721Factory erc721factory;
    ERC721 public nftContract;
    address public xorigin;
    struct StakerMetadata {
        uint256 tokenId;
        uint256 tokenType;
        uint256 totalSupply;
        string name;
        string symbol;
        string uri;
        address owner;
        address collectionAddress;
    }

    mapping(address => StakerMetadata) public stakerMetadata;
    mapping(address => bool) public hasMetadata;
    mapping(uint256 => uint256) public tokenType;
    mapping(address => bool) public L1NftCloneDeployed;
    mapping(address => mapping(uint256 => bool)) public mintedTokens;

    constructor(
        ERC721Factory _ERC721Factory,
        ERC20Factory _ERC20Factory // , // address _xorigin
    ) {
        erc721factory = _ERC721Factory;
        erc20factory = _ERC20Factory;
        // xorigin = _xorigin;
    }

    modifier onlyApprovedAddressXOrigin() {
        require(xorigin == getXorig());
        _;
    }

    function mint(ERC721X _erc721, address _to) public returns (bool) {
        StakerMetadata memory metadata = stakerMetadata[msg.sender];
        // require(
        //     L1NftCloneDeployed[metadata.collectionAddress] = true,
        //     "you must deploy l2 Nft First"
        // );
        // require(
        //     !mintedTokens[metadata.collectionAddress][metadata.tokenId],
        //     "Token ID already minted"
        // );
        _erc721.safeMint(_to, metadata.uri);
        mintedTokens[metadata.collectionAddress][metadata.tokenId];
        return true;
    }

    function deployCorrospondingToken(bytes32 _salt) public returns (address) {
        require(hasMetadata[msg.sender], "no metadata registered");

        StakerMetadata memory metadata = stakerMetadata[msg.sender];
        address collectionAddr = metadata.collectionAddress;
        address deployed;
        if (L1NftCloneDeployed[collectionAddr]) {
            revert xNFT_AlreadyDeployed();
        }
        if (metadata.tokenType == 1) {
            deployed = deployXERC721(
                _salt,
                metadata.tokenId,
                metadata.name,
                metadata.symbol,
                metadata.collectionAddress
            );
            L1NftCloneDeployed[collectionAddr] = true;
            tokenType[metadata.tokenId] = 1;
        } else if (metadata.tokenType == 2) {
            deployed = deployERC20(
                _salt,
                metadata.name,
                metadata.symbol,
                metadata.totalSupply,
                metadata.owner
            );
            tokenType[metadata.tokenId] = 2;
        }
        return deployed;
    }

    function deployXERC721(
        bytes32 _salt,
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        address _collectionAddress
    ) private returns (address) {
        ERC721X erc721x = erc721factory.deployERC721_L2Clone(
            _salt,
            _tokenId,
            _name,
            _symbol,
            _collectionAddress
        );
        return address(erc721x);
    }

    function deployERC20(
        bytes32 _salt,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _owner
    ) private returns (address) {
        AS_ERC20 erc20 = erc20factory.deployERC20(
            _salt,
            _name,
            _symbol,
            _totalSupply,
            _owner
        );
        return address(erc20);
    }

    function registerMetadata(
        uint256 _tokenId,
        uint256 _type,
        uint256 _totalSupply,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _owner,
        address _collectionAddress
    ) public {
        stakerMetadata[_owner] = StakerMetadata({
            tokenId: _tokenId,
            tokenType: _type,
            totalSupply: _totalSupply,
            name: _name,
            symbol: _symbol,
            uri: _uri,
            owner: _owner,
            collectionAddress: _collectionAddress
        });
        hasMetadata[_owner] = true;
    }

    // onlyApprovedAddressXOrigin
    function getXorig() private view returns (address) {
        // Get the cross domain messenger's address each time.
        // This is less resource intensive than writing to storage.
        address cdmAddr = address(0);

        // Mainnet
        if (block.chainid == 1)
            cdmAddr = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;

        // Goerli
        if (block.chainid == 5)
            cdmAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

        // L2 (same address on every network)
        if (block.chainid == 10 || block.chainid == 420)
            cdmAddr = 0x4200000000000000000000000000000000000007;

        // If this isn't a cross domain message
        if (msg.sender != cdmAddr) return address(0);

        // If it is a cross domain message, find out where it is from
        return ICrossDomainMessenger(cdmAddr).xDomainMessageSender();
    } // getXorig()
}
