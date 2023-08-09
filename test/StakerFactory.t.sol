// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// import "../src/Staker.sol";
import "../src/StakerFactory.sol";
import "../src/mocks/mockERC721.sol";

contract StakerFactoryTest is Test {
    // Staker public staker;
    bytes32 public constant SALT1 =
        bytes32(uint256(keccak256(abi.encodePacked("test"))));
    StakerFactory factory;
    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public totalSupply = 100 ether;
    address public randomOwner = address(0x11);

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 1);

        factory = new StakerFactory();
    }

    function testDeployStaker() public {
        factory.deployStaker(erc721, tokenId, totalSupply, SALT1, 1);
    }

    function testComputedAddressEqualsDeployedAddress() public {
        address computedAddress = factory.computeStakerAddress(
            type(Staker).creationCode,
            address(factory),
            erc721,
            tokenId,
            totalSupply,
            randomOwner,
            uint256(SALT1)
        );
        vm.startPrank(address(factory));
        Staker staker = new Staker{salt: SALT1}(
            erc721,
            tokenId,
            totalSupply,
            randomOwner
        );
        vm.stopPrank();
        assertEq(computedAddress, address(staker));
    }
}
