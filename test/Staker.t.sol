// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Staker.sol";
import "../src/mocks/mockERC721.sol";

contract StakerTest is Test {
    Mock_ERC721 public erc721;
    Staker public staker;
    address public erc721Address;
    address public randomOwner = address(0x11);

    function setUp() public {
        // vm.prank(randomOwner);
        erc721 = new Mock_ERC721();
        // erc721.mint(address(this), 1);
        erc721.mint(randomOwner, 1);

        vm.prank(randomOwner);

        staker = new Staker(erc721, 1, 100 ether, randomOwner);
        // erc721.approve(address(this), 0);
    }

    function testMint_1() public {
        erc721.mint(address(randomOwner), 1);
    }

    function testMint_2() public {
        erc721.mint(address(randomOwner), 2);
    }

    function testMint_3() public {
        erc721.safeMint(address(randomOwner), 3);
    }

    function testStake() public {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stake();
        assertEq(staker.staked(), true);
        vm.stopPrank();
    }

    function testFailStakeWrongId() public {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 2);
        // vm.expectRevert(staker);
        staker.stake();
        // assertEq(staker.staked(), true);
        vm.stopPrank();
    }

    modifier staked() {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stake();
        assertEq(staker.staked(), true);
        vm.stopPrank();
        _;
    }

    function testUnStake() public staked {
        // vm.wrap(1);
        vm.prank(randomOwner);
        staker.unstake();
        assertEq(staker.staked(), false);
    }
}
