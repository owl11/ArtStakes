// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error address__zero();
error Invalid__tokenId();

contract Staker is IERC721Receiver, Ownable {
    ERC721 private nftAddress;
    uint256 private expectedTokenId;
    uint256 public totalSupply;

    bool public staked;

    constructor(
        ERC721 _NFTAddr,
        uint256 _tokenId,
        uint256 _totalSupply,
        address _Owner
    ) {
        nftAddress = _NFTAddr;
        expectedTokenId = _tokenId;
        totalSupply = _totalSupply;
        transferOwnership(_Owner);
    }

    function stake() public onlyOwner {
        require(!staked, "Token is already staked");

        ERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            expectedTokenId
        );

        staked = true;
    }

    function unstake() public onlyOwner {
        require(staked, "Token is not already staked");

        ERC721(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            expectedTokenId
        );

        staked = false;
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes calldata
    ) external view override returns (bytes4) {
        require(_tokenId == expectedTokenId, "Invalid token ID");
        return IERC721Receiver.onERC721Received.selector;
    }
}
