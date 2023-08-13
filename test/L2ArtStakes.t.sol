// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import {Test, console} from "forge-std/Test.sol";
import "../src/L2ArtStakes.sol";
import "../src/mocks/mockERC721.sol";
import "../../script/L2ArtStakes.s.sol";

contract ArtStakes_Factory_Test is Test {
    ArtStakes_Factory public factory;
    address public erc20_master = 0xf3174A6b44e3Cd073F3beB0ee543c5383dBb553F;
    address public erc721_master = 0x82C8B2b7B72FA98d252C34129F66ec995be88747;

    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public totalSupply = 100 ether;
    address public randomOwner = address(0x11);

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 3, "test.org");
        factory = new ArtStakes_Factory(erc20_master, erc721_master);
    }

    function testRegisterMetadata() public {
        bytes memory data = storeMetadata(
            tokenId,
            1,
            1,
            erc721.name(),
            erc721.symbol(),
            erc721.tokenURI(tokenId),
            erc721.ownerOf(tokenId),
            address(erc721)
        );
        (
            uint256 _tokenId,
            uint256 _totalSupply,
            uint256 _type,
            ,
            ,
            string memory _uri,
            address _owner,
            address _L1NFTAddr
        ) = factory.getUserMetadata(data);
        assertEq(address(erc721), address(_L1NFTAddr));
        assertEq(_uri, "test.org");
        assertEq(tokenId, _tokenId);
        assertEq(1, _totalSupply);
        assertEq(randomOwner, _owner);
        assertEq(_type, 1);
        factory.registerMetadata(data);
    }

    modifier registeredNFTMetadata() {
        bytes memory data = storeMetadata(
            tokenId,
            1,
            1,
            erc721.name(),
            erc721.symbol(),
            erc721.tokenURI(tokenId),
            erc721.ownerOf(tokenId),
            address(erc721)
        );
        factory.registerMetadata(data);
        _;
    }
    modifier registeredERC20Metadata() {
        bytes memory data = storeMetadata(
            tokenId,
            10000000 ether,
            2,
            erc721.name(),
            erc721.symbol(),
            erc721.tokenURI(tokenId),
            erc721.ownerOf(tokenId),
            address(erc721)
        );
        factory.registerMetadata(data);
        _;
    }

    function testDeployNFTMetadataToken() public registeredNFTMetadata {
        vm.prank(randomOwner);
        factory.deployCorrospondingToken();
    }

    function testMintXNFT() public registeredNFTMetadata {
        vm.startPrank(randomOwner);
        factory.deployCorrospondingToken();
        bool success = factory.mintXNFT();
        require(success);
    }

    function testBurnXNFT() public registeredNFTMetadata {
        vm.startPrank(randomOwner);
        address deployed = factory.deployCorrospondingToken();
        bool success = factory.mintXNFT();
        require(success);

        vm.prank(randomOwner);
        factory.burnERC721(ERC721X(deployed), tokenId);
    }

    function testBurnERC20() public registeredERC20Metadata {
        vm.startPrank(randomOwner);
        address deployed = factory.deployCorrospondingToken();
        uint256 balance = AS_ERC20(deployed).balanceOf(randomOwner);
        AS_ERC20(deployed).approve(address(factory), balance);
        factory.BurnERC20TokenMajority(AS_ERC20(deployed), tokenId);
    }

    function testDeployERC20MetadataToken() public registeredERC20Metadata {
        vm.prank(randomOwner);
        factory.deployCorrospondingToken();
    }

    // function testBurnerMetadata() public {
    //     vm.prank(randomOwner);
    //     address deployed = factory.deployCorrospondingToken();
    //     bytes memory data = encodeBurnerMetadata(
    //         tokenId,
    //         deployed,
    //         randomOwner
    //     );
    // }

    function storeMetadata(
        //TODO RENAME to encodeMetadata and fix accordingly
        uint256 _tokenId,
        uint256 _totalSupply,
        uint256 _type,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _Owner,
        address _NFTAddr
    ) internal pure returns (bytes memory) {
        bytes memory encodedData = abi.encode(
            _tokenId,
            _totalSupply,
            _type,
            _name,
            _symbol,
            _uri,
            _Owner,
            _NFTAddr
        );
        return encodedData;
    }

    function encodeBurnerMetadata(
        uint256 _tokenId,
        address _collectionAddress,
        address _burnerOwner
    ) internal pure returns (bytes memory) {
        bytes memory encodedData = abi.encode(
            _tokenId,
            _collectionAddress,
            _burnerOwner
        );
        return encodedData;
    }
}
