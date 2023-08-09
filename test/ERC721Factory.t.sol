// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC721Factory.sol";
import "../src/mocks/mockERC721.sol";

contract ERC721FactoryTest is Test {
    bytes32 public constant SALT1 =
        bytes32(uint256(keccak256(abi.encodePacked("test"))));
    ERC721Factory factory;
    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public totalSupply = 0;
    address public randomOwner = address(0x11);
    uint256 public tokenType = 0;

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 1);
        factory = new ERC721Factory();
    }

    function testRegisterMetadataAndDeployERC721() public DeployedMetadata {
        vm.prank(randomOwner);
        factory.deployERC721L2Clone(SALT1);
        // Retrieve and assert struct values from logs
        (
            ,
            string memory name,
            string memory symbol,
            ,
            address owner,
            address collectionAddr
        ) = factory.stakerMetadata(randomOwner);

        console.log(tokenId);
        console.log(name);
        console.log(symbol);
        assertEq(owner, randomOwner);
        assertEq(collectionAddr, address(erc721));
    }

    modifier DeployedMetadata() {
        factory.registerMetadata(
            tokenId,
            erc721.name(),
            erc721.symbol(),
            "test.org",
            randomOwner,
            address(erc721)
        );
        _;
    }

    function testDeployERC721() public DeployedMetadata returns (ERC721X) {
        vm.prank(randomOwner);
        ERC721X erc721x = factory.deployERC721L2Clone(SALT1);
        console.log(erc721x.name());
        console.log(erc721x.symbol());
        return erc721x;
    }

    function testComputedAddressEqualsDeployedAddress()
        public
        DeployedMetadata
    {
        (, , string memory name, string memory symbol, , ) = factory
            .stakerMetadata(randomOwner);
        address computedAddress = factory.computeERC721TokenAddress(
            type(ERC721X).creationCode,
            address(factory),
            name,
            symbol,
            uint256(SALT1)
        );
        vm.startPrank(address(factory));
        ERC721X erc721x = new ERC721X{salt: SALT1}(
            name,
            symbol,
            address(factory)
        );
        vm.stopPrank();
        assertEq(computedAddress, address(erc721x));
    }
}
