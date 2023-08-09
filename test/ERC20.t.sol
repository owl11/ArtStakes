// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20.sol";
import "../src/mocks/mockERC721.sol";

contract ERC20_OZ_deploy_Test is Test {
    string public _name = "MOCK-AS-TOKEN";
    string public _symbol = "MAST";
    uint256 public _totalSupply = 100 ether;
    address public _owner = address(0x1);
    ArtStakes_ERC20 public erc20;

    function setUp() public {
        erc20 = new ArtStakes_ERC20(_name, _symbol, _totalSupply, _owner);
    }

    function testClaim() public {
        vm.prank(_owner);
        erc20.claim();
        assertEq(erc20.balanceOf(_owner), _totalSupply * 10 ** 18);
    }

    modifier claimed() {
        vm.prank(_owner);
        erc20.claim();
        _;
    }

    function testPauseNoTransfer() public claimed {
        vm.prank(_owner);
        erc20.pause();
        vm.expectRevert();
        erc20.transfer(address(erc20), 1 ether);
    }

    modifier paused() {
        vm.prank(_owner);
        erc20.pause();
        _;
    }

    function testUnpausedTransfersWork() public claimed paused {
        vm.prank(_owner);
        erc20.unpause();
        vm.prank(_owner);
        erc20.transfer(address(0x69), 1 ether);
        console.log(erc20.balanceOf(_owner));
        assertEq(erc20.balanceOf(address(0x69)), 1 ether);
    }
}
