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
        vm.prank(randomOwner);
        factory = new ERC721Factory(randomOwner);
    }

    // function testDeployERC721() public {
    //     vm.prank(randomOwner);
    //     factory.deployERC721_L2Clone(
    //         SALT1,
    //         tokenId,
    //         erc721.name(),
    //         erc721.symbol(),
    //         address(erc721)
    //     );
    // }

    function testDeployERC721() public returns (ERC721X) {
        vm.prank(randomOwner);
        ERC721X erc721x = factory.deployERC721_L2Clone(
            SALT1,
            tokenId,
            erc721.name(),
            erc721.symbol(),
            address(erc721)
        );
        console.log(erc721x.name());
        console.log(erc721x.symbol());
        return erc721x;
    }

    function testComputedAddressEqualsDeployedAddress() public {
        address computedAddress = factory.computeERC721TokenAddress(
            type(ERC721X).creationCode,
            address(factory),
            erc721.name(),
            erc721.symbol(),
            uint256(SALT1)
        );
        vm.startPrank(address(factory));
        ERC721X erc721x = new ERC721X{salt: SALT1}(
            erc721.name(),
            erc721.symbol(),
            randomOwner
        );
        vm.stopPrank();
        assertEq(computedAddress, address(erc721x));
    }
}
