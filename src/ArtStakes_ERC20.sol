// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

contract ArtStakes_ERC20 is ERC20, Pausable, Ownable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _owner
    ) ERC20(_name, _symbol) {
        transferOwnership(_owner);
        _mint(address(this), _totalSupply * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function claim() public onlyOwner returns (uint256) {
        approveWithin();
        transferFrom(address(this), owner(), totalSupply());
        return balanceOf(address(this));
    }

    function approveWithin() private {
        _approve(address(this), owner(), totalSupply());
    }
}
