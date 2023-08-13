// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract AS_ERC20 is ERC20, Pausable, Ownable, ERC20Burnable, Initializable {
    address private L1NftAddr;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _owner,
        address _claimer,
        address _L1CollectoinAddress
    ) ERC20(_name, _symbol) {
        initialize(_owner);
        L1NftAddr = _L1CollectoinAddress;
        _mint(_claimer, _totalSupply);
    }

    function initialize(address _owner) public initializer {
        transferOwnership(_owner);
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

    function L1CollectionAddress() public view returns (address) {
        return L1NftAddr;
    }
}
