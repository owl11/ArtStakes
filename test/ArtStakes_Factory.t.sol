// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ArtStakes_Factory.sol";
import "../src/mocks/mockERC721.sol";

contract ArtStakes_FactoryTest is Test {
    ERC20Factory erc20factory;
    ERC721Factory erc721factory;
    ArtStakes_Factory factory;
    bytes32 public constant SALT1 =
        bytes32(uint256(keccak256(abi.encodePacked("test"))));
    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public altTokenId = 2;
    uint256 public totalSupply = 0;
    address public randomOwner = address(0x24);
    address public altRandomOwner = address(0x420);
    uint256 public tokenType = 0;

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 1);
        erc721.mint(altRandomOwner, 1);
        erc721factory = new ERC721Factory();
        erc20factory = new ERC20Factory();
        factory = new ArtStakes_Factory(erc721factory, erc20factory);
    }

    function testDeployERC721() public metadataDeployedNFT returns (ERC721X) {
        vm.prank(randomOwner);
        address erc721x = factory.deployCorrospondingToken(SALT1);
        return ERC721X(erc721x);
    }

    function testDeployERC721AndMint() public metadataDeployedNFT {
        vm.prank(randomOwner);
        address erc721x = factory.deployCorrospondingToken(SALT1);
        address factoryAddr = (ERC721X(erc721x).factory).address;
        console.log(factoryAddr);
        // address handlerAddr = erc721factory.handler.address;
        // console.log(handlerAddr);
        vm.prank(randomOwner);
        factory.mint(ERC721X(erc721x), randomOwner);
    }

    modifier deployedxNFT() {
        // address factoryAddr = (ERC721X(erc721x).factory).address;
        // console.log(factoryAddr);
        // address handlerAddr = erc721factory.handler.address;
        // console.log(handlerAddr);

        _;
    }

    function testRegisteredMinterButNotDeployer()
        public
        metadataDeployedNFT
        metadataALTDeployedNFT
    {
        vm.prank(randomOwner);
        address erc721x = factory.deployCorrospondingToken(SALT1);
        factory.mint(ERC721X(erc721x), randomOwner);
        vm.prank(altRandomOwner);
        factory.mint(ERC721X(erc721x), randomOwner);
    }

    function testDeployERC20() public metadataDeployedERC20 returns (AS_ERC20) {
        vm.prank(randomOwner);
        address erc20c = factory.deployCorrospondingToken(SALT1);
        return AS_ERC20(erc20c);
    }

    modifier metadataDeployedNFT() {
        factory.registerMetadata(
            tokenId,
            1,
            1,
            erc721.name(),
            erc721.symbol(),
            "test.org",
            erc721.ownerOf(tokenId),
            address(erc721)
        );
        _;
    }

    modifier metadataALTDeployedNFT() {
        factory.registerMetadata(
            altTokenId,
            1,
            1,
            erc721.name(),
            erc721.symbol(),
            "test.org",
            altRandomOwner,
            address(erc721)
        );
        _;
    }

    modifier metadataDeployedERC20() {
        factory.registerMetadata(
            tokenId,
            1000 ether,
            2,
            erc721.name(),
            erc721.symbol(),
            "test.org",
            erc721.ownerOf(tokenId),
            address(erc721)
        );
        _;
    }
}
