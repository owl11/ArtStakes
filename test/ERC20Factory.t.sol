// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Factory.sol";
import "../src/mocks/mockERC721.sol";

contract ERC20FactoryTest is Test {
    bytes32 public constant SALT1 =
        bytes32(uint256(keccak256(abi.encodePacked("test"))));
    ERC20Factory factory;
    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public totalSupply = 100 ether;
    address public randomOwner = address(0x11);

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 1);

        factory = new ERC20Factory();
    }

    function testRegisteredMetadataAndDeployERC20() public {
        vm.prank(randomOwner);
        factory.deployERC20(
            SALT1,
            erc721.name(),
            erc721.symbol(),
            totalSupply,
            randomOwner
        );
        //     // Retrieve and assert struct values from logs
        //     (
        //         ,
        //         uint256 _totalSupply,
        //         string memory name,
        //         string memory symbol,
        //         address owner,
        //         address collectionAddr
        //     ) = factory.stakerMetadata(randomOwner);

        //     console.log(tokenId);
        //     assertEq(_totalSupply, totalSupply);

        //     console.log(name);
        //     console.log(symbol);
        //     assertEq(owner, randomOwner);
        //     assertEq(collectionAddr, address(erc721));
    }

    // modifier DeployedMetadata() {
    //     factory.registerMetadata(
    //         tokenId,
    //         totalSupply,
    //         erc721.name(),
    //         erc721.symbol(),
    //         randomOwner,
    //         address(erc721)
    //     );
    //     _;
    // }

    function testDeployERC20() public returns (AS_ERC20) {
        vm.prank(randomOwner);
        AS_ERC20 erc20 = factory.deployERC20(
            SALT1,
            erc721.name(),
            erc721.symbol(),
            totalSupply,
            randomOwner
        );
        console.log(erc20.name());
        console.log(erc20.symbol());
        return erc20;
    }

    function testComputedAddressEqualsDeployedAddress() public {
        // (
        //     ,
        //     ,
        //     string memory name,
        //     string memory symbol,
        //     address owner,

        // ) = factory.stakerMetadata(randomOwner);
        address computedAddress = factory.computeTokenAddress(
            type(AS_ERC20).creationCode,
            address(factory),
            erc721.name(),
            erc721.symbol(),
            uint256(SALT1),
            totalSupply,
            randomOwner
        );
        vm.startPrank(address(factory));
        AS_ERC20 erc20 = new AS_ERC20{salt: SALT1}(
            erc721.name(),
            erc721.symbol(),
            totalSupply,
            randomOwner
        );
        vm.stopPrank();
        assertEq(computedAddress, address(erc20));
    }
}
