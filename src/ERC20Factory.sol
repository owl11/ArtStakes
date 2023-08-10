// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AS_ERC20} from "./AS_ERC20.sol";

contract ERC20Factory {
    event ERC20Deployed(address indexed erc20Address);
    event ERC20Permitted(address indexed nftContract);
    using Strings for uint256;
    ERC721 public nftContract; // Define NFT contract interface

    address public owner;

    function deployERC20(
        bytes32 _salt,
        string memory _tokenName,
        string memory _symbol,
        uint256 _totalSupply,
        address _owner
    ) public returns (AS_ERC20) {
        address computedAddress = computeTokenAddress(
            type(AS_ERC20).creationCode,
            address(this),
            _tokenName,
            _symbol,
            uint256(_salt),
            _totalSupply,
            _owner
        );
        AS_ERC20 erc20 = new AS_ERC20{salt: _salt}(
            _tokenName,
            _symbol,
            _totalSupply,
            _owner
        );

        require(address(erc20) == computedAddress, "Computed address mismatch");

        emit ERC20Deployed(address(erc20));
        return erc20;
    }

    function computeTokenAddress(
        bytes memory byteCode,
        address _deployer,
        string memory _name,
        string memory _symbol,
        uint256 salt,
        uint256 _totalSupply,
        address _owner
    ) public pure returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _deployer,
                            // collectionAddr,
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    byteCode,
                                    abi.encode(
                                        _name,
                                        _symbol,
                                        _totalSupply,
                                        _owner
                                    )
                                )
                            )
                        )
                    )
                )
            )
        );
        return predictedAddress;
    }
}
