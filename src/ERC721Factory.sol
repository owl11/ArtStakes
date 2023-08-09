// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721X} from "./ERC721X.sol";
import {StakerFactory} from "./StakerFactory.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract ERC721Factory {
    error NFTAlreadyDeployed();
    event ERC721Deployed(address indexed erc20Address);
    event ERC721Permitted(address indexed nftContract);
    using Strings for uint256;
    string public greeting;
    address public xorigin;
    address public deployer;

    ERC721 public nftContract;
    struct StakerMetadata {
        uint256 tokenId;
        string name;
        string symbol;
        string uri;
        address owner;
        address collectionAddress;
    }

    //   mapping(address => bool) public hasMetadata;

    mapping(address => StakerMetadata) public stakerMetadata;
    mapping(address => bool) public L2NftDeployed;

    address public owner;

    modifier onlyApprovedAddressXOrigin() {
        // require(xorigin == getXorig());
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    function mint(ERC721X _erc721) public returns (bool) {
        StakerMetadata memory metadata = stakerMetadata[msg.sender];
        _erc721.safeMint(msg.sender, metadata.uri);
        return true;
    }

    function deployERC721L2Clone(bytes32 salt) public returns (ERC721X) {
        StakerMetadata memory metadata = stakerMetadata[msg.sender];

        string memory tokenName = string(
            abi.encodePacked(
                "ArtStakes ERC721: ",
                metadata.name,
                "-",
                metadata.tokenId.toString() // Use the toString function from Strings library
            )
        );
        string memory symbol = string(abi.encodePacked("AS-", metadata.symbol));

        address computedAddress = computeERC721TokenAddress(
            type(ERC721X).creationCode,
            address(this),
            tokenName,
            symbol,
            uint256(salt)
        );
        ERC721X erc721 = new ERC721X{salt: salt}(
            tokenName,
            symbol,
            address(this)
        );

        require(
            address(erc721) == computedAddress,
            "Computed address mismatch"
        );

        emit ERC721Deployed(address(erc721));
        L2NftDeployed[address(erc721)] = true;
        return erc721;
    }

    function computeERC721TokenAddress(
        bytes memory byteCode,
        address _deployer,
        string memory _name,
        string memory _symbol,
        uint256 _salt
    ) public pure returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _deployer,
                            _salt,
                            keccak256(
                                abi.encodePacked(
                                    byteCode,
                                    abi.encode(_name, _symbol, _deployer)
                                )
                            )
                        )
                    )
                )
            )
        );
        return predictedAddress;
    }

    function registerMetadata(
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _owner,
        address _collectionAddress
    ) public onlyApprovedAddressXOrigin {
        stakerMetadata[_owner] = StakerMetadata({
            tokenId: _tokenId,
            name: _name,
            symbol: _symbol,
            uri: _uri,
            owner: _owner,
            collectionAddress: _collectionAddress
        });
    }

    function setXOrigin(address _xorigin) public onlyDeployer {
        xorigin = _xorigin;
    }

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
