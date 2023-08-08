// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ERC20.sol";
import "./StakerFactory.sol";

contract ERC20Factory {
    event ERC20Deployed(address indexed erc20Address);
    event ERC20Permitted(address indexed nftContract);
    using Strings for uint256;
    ERC721 public nftContract; // Define NFT contract interface

    // mapping(address => mapping(address => mapping(uint256 => uint256)))
    //     public stakerTotalSupply;
    // mapping(address => mapping(address => mapping(uint256 => string)))
    //     public stakerNames;
    struct StakerMetadata {
        uint256 tokenId;
        uint256 totalSupply;
        string name;
        string symbol;
        address owner;
        address collectionAddress;
    }
    mapping(address => StakerMetadata) public stakerMetadata;
    address public owner;

    function deployERC20(bytes32 salt) public returns (ArtStakes_ERC20) {
        StakerMetadata memory metadata = stakerMetadata[msg.sender];
        require(metadata.tokenId != 0, "metadata not registered");
        // string memory tokenId = toString(metadata.tokenId);
        string memory tokenName = string(
            abi.encodePacked(
                "ArtStakes ERC20: ",
                metadata.name,
                "-",
                metadata.tokenId.toString() // Use the toString function from Strings library
            )
        );
        string memory symbol = string(abi.encodePacked("AS-", metadata.symbol));

        address computedAddress = computeTokenAddress(
            type(ArtStakes_ERC20).creationCode,
            address(this),
            tokenName,
            symbol,
            uint256(salt),
            metadata.totalSupply,
            metadata.owner
        );
        ArtStakes_ERC20 erc20 = new ArtStakes_ERC20{salt: salt}(
            tokenName,
            symbol,
            metadata.totalSupply,
            metadata.owner
        );

        require(address(erc20) == computedAddress, "Computed address mismatch");

        emit ERC20Deployed(address(erc20));
        return erc20;
    }

    function computeTokenAddress(
        bytes memory byteCode,
        address _deployer,
        string memory _name,
        string memory _symbol,
        uint256 salt,
        uint256 _totalSupply,
        address _owner
    ) public pure returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _deployer,
                            // collectionAddr,
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    byteCode,
                                    abi.encode(
                                        _name,
                                        _symbol,
                                        _totalSupply,
                                        _owner
                                    )
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
        uint256 _totalSupply,
        string memory _name,
        string memory _symbol,
        address _owner,
        address _collectionAddress
    ) public {
        stakerMetadata[_owner] = StakerMetadata({
            tokenId: _tokenId,
            totalSupply: _totalSupply,
            name: _name,
            symbol: _symbol,
            owner: _owner,
            collectionAddress: _collectionAddress
        });
    }
}
