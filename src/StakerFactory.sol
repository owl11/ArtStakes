// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Staker} from "./Staker.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract StakerFactory {
    error address_Missmatch();
    event StakerDeployed(address);
    event StakerRegistered(
        address indexed StakerFactory,
        uint256 tokenId,
        uint256 totalSupply,
        string name,
        address owner
    );
    address crossDomainMessengerAddr =
        0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;
    address greeterL2Addr = 0xE8B462EEF7Cbd4C855Ea4B65De65a5c5Bab650A9;

    function deployStaker(
        ERC721 _NFTAddr,
        uint256 _tokenId,
        uint256 _totalSupply,
        bytes32 salt,
        uint256 _type
    ) public {
        address computedAddress = computeStakerAddress(
            type(Staker).creationCode,
            address(this),
            _NFTAddr,
            _tokenId,
            _totalSupply,
            _NFTAddr.ownerOf(_tokenId),
            uint256(salt)
        );

        Staker staker = new Staker{salt: salt}(
            _NFTAddr,
            _tokenId,
            _totalSupply,
            _NFTAddr.ownerOf(_tokenId)
        );
        sendMetaData(
            _tokenId,
            _totalSupply,
            _type,
            _NFTAddr.name(),
            _NFTAddr.symbol(),
            _NFTAddr.tokenURI(_tokenId),
            _NFTAddr.ownerOf(_tokenId),
            _NFTAddr
        );

        if (address(staker) != computedAddress) {
            revert address_Missmatch();
        }
        emit StakerDeployed(address(staker));
    }

    function computeStakerAddress(
        bytes memory byteCode,
        address _deployer,
        ERC721 _NFTAddr,
        uint256 _tokenId,
        uint256 _totalSupply,
        address _Owner,
        uint256 salt
    ) public pure returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _deployer,
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    byteCode,
                                    abi.encode(
                                        _NFTAddr,
                                        _tokenId,
                                        _totalSupply,
                                        _Owner
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

    function sendMetaData(
        uint256 _tokenId,
        uint256 _totalSupply,
        uint256 _type,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _Owner,
        ERC721 _NFTAddr
    ) internal {
        bytes memory message;
        if (_type == 0) {
            //Assign ERC721-COMPATIBLE METADATA
            message = abi.encodeWithSignature(
                "registerMetadata(uint256,uint256,string,string,string,address,address)",
                _tokenId,
                _name,
                _symbol,
                _uri,
                _Owner,
                address(_NFTAddr)
            );
        } else if (_type == 1) {
            //Assign ERC20-COMPAITBLE METADATA
            message = abi.encodeWithSignature(
                "registerMetadata(uint256,uint256,string,string,address,address)",
                _tokenId,
                _totalSupply,
                _name,
                _symbol,
                _Owner,
                address(_NFTAddr)
            );
        }
        // ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
        //     greeterL2Addr,
        //     message,
        //     1000000
        // );
    }
}
