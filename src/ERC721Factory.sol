// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721X} from "./AS_ERC721X.sol";

contract ERC721Factory {
    event ERC721Deployed(address indexed nftContract);
    event ERC721Permitted(address indexed nftContract);
    using Strings for uint256;
    address public xorigin;

    // mapping(address => bool) public L1NftDeployed;
    // mapping(address => mapping(uint256 => bool)) public mintedTokens;
    // mapping(uint256 => uint256) public L1TokenIdMapping;

    function deployERC721_L2Clone(
        bytes32 _salt,
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        address collectionAddress
    ) public returns (ERC721X) {
        string memory tokenName = string(
            abi.encodePacked(
                "ArtStakes ERC721: ",
                _name,
                "-",
                _tokenId.toString() // Use the toString function from Strings library
            )
        );
        string memory symbol = string(abi.encodePacked("AS-", _symbol));

        address computedAddress = computeERC721TokenAddress(
            type(ERC721X).creationCode,
            address(this),
            tokenName,
            symbol,
            uint256(_salt)
        );
        ERC721X erc721 = new ERC721X{salt: _salt}(
            tokenName,
            symbol,
            msg.sender
        );

        require(
            address(erc721) == computedAddress,
            "Computed address mismatch"
        );
        erc721.setNftL1Address(collectionAddress);

        emit ERC721Deployed(address(erc721));
        return erc721;
    }

    function computeERC721TokenAddress(
        bytes memory byteCode,
        address _deployer,
        string memory _name,
        string memory _symbol,
        uint256 _salt
    ) public view returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _deployer,
                            _salt,
                            keccak256(
                                abi.encodePacked(
                                    byteCode,
                                    abi.encode(_name, _symbol, msg.sender)
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
