// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract ArtStakes_Staker {
    event StakerRegistered(
        address indexed stakedUser,
        uint256 tokenId,
        uint256 totalSupply,
        uint256 tokenType,
        string name
    );
    event burnMetadata(
        address sender, // msg.sender
        address origin, // tx.origin
        address xorigin, // cross domain origin, if any
        address user, // user address, if given
        bytes metadata // The greeting
    );
    event MetadataSet(
        address sender, // msg.sender
        address origin, // tx.origin
        address xorigin, // cross domain origin, if any
        address user, // user address, if given
        bytes metadata // The greeting
    );
    address public crossDomainMessengerAddr =
        0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;
    address public xorigin = 0x6322314cbc00EE1220E6eacdE5C0555296B14dF7;

    // ATTENTION, THIS CONTRACT ASSUMES ONLY ONE NFT PER USER IS DEPOSITED,
    // DO NOT DEPOSIT AONTHER NFT FROM THE SAME WALLET!!!!
    // Map the user to their metadata
    mapping(address => bytes) public userMetadata;
    mapping(address => bytes) public UnstakerMetadata;
    mapping(ERC721 => mapping(uint256 => bool)) public stakedTokens;
    mapping(address => mapping(ERC721 => mapping(uint256 => bool)))
        public unstakeRequests;
    mapping(address => bool) public registeredMetadata; // Mapping to track registered metadata

    modifier onlyApprovedAddressXOrigin() {
        require(xorigin == getXorig(), "not expected xorigin");
        _;
    }

    function stakeNFT() public {
        _stakeNFT();
        sendMetaData(msg.sender); //l2 message
    }

    function _stakeNFT() internal {
        require(
            registeredMetadata[msg.sender] == true,
            "Unregistered Metadata"
        );
        (uint256 _tokenId, , , , , , , ERC721 _NFTAddr) = getUserMetadata(
            msg.sender
        );
        require(!stakedTokens[_NFTAddr][_tokenId], "Token already staked");
        stakedTokens[_NFTAddr][_tokenId] = true; //mark tokenStaked
        _NFTAddr.safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    function BurnerunStakeNFT() public {
        (uint256 _tokenId, ERC721 _NFTAddr, address _owner) = getUnstakerMetada(
            msg.sender
        );
        require(msg.sender == _owner, "not owner");
        require(_tokenId != 0, "no tokenId exists");
        require(
            unstakeRequests[_owner][_NFTAddr][_tokenId] == true,
            "no message received"
        );
        require(
            stakedTokens[_NFTAddr][_tokenId],
            "Token is not already staked"
        );
        stakedTokens[_NFTAddr][_tokenId] = false; //token unStaked

        _NFTAddr.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function emergancyWithdrawNFTOwner() public {
        require(
            registeredMetadata[msg.sender] == true,
            "Unregistered Metadata"
        );
        (uint256 _tokenId, , , , , , , ERC721 _NFTAddr) = getUserMetadata(
            msg.sender
        );
        require(stakedTokens[_NFTAddr][_tokenId] == true, "Token not staked");
        stakedTokens[_NFTAddr][_tokenId] = false;
        _NFTAddr.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function ReceiveMessage(
        bytes memory _encodedData
    ) public onlyApprovedAddressXOrigin {
        (
            uint256 _tokenId,
            address _collectionAddress,
            address _owner
        ) = storeBurnerMetadata(_encodedData);
        UnstakerMetadata[_owner] = _encodedData;
        unstakeRequests[_owner][ERC721(_collectionAddress)][_tokenId] = true;
        emit burnMetadata(
            msg.sender,
            tx.origin,
            getXorig(),
            _owner,
            _encodedData
        );
    }

    function tokenSymbol(ERC721 _erc721) public view returns (string memory) {
        return _erc721.symbol();
    }

    function tokenName(ERC721 _erc721) public view returns (string memory) {
        return _erc721.name();
    }

    function tokenUri(
        ERC721 _erc721,
        uint256 _tokenId
    ) public view returns (string memory) {
        return _erc721.tokenURI(_tokenId);
    }

    function tokenOwner(
        uint256 _tokenId,
        ERC721 _erc721
    ) public view returns (address) {
        return _erc721.ownerOf(_tokenId);
    }

    function getUnstakerMetada(
        address user
    ) public view returns (uint256, ERC721, address) {
        bytes memory encodedData = UnstakerMetadata[user];
        return abi.decode(encodedData, (uint256, ERC721, address));
    }

    function registerMetaData(
        ERC721 _NFTAddr, // NFT contract instance
        uint256 _tokenId, // NFT token ID
        uint256 _totalSupply, //for nft this value is omitted,
        uint256 _type // type 1 or for nft, type 2 for erc20
    ) external {
        address _owner = msg.sender;
        // Check if the user owns the specified token
        require(tokenOwner(_tokenId, _NFTAddr) == _owner, "tokenId not caller");
        require(_owner != address(this), "cant register this address as owner"); // this happened before, therefore must be prevented
        require(_type == 1 || _type == 2, "choose 1 for nft, 2 for erc20");
        storeMetadata(
            _tokenId,
            _totalSupply,
            _type,
            tokenName(_NFTAddr),
            tokenSymbol(_NFTAddr),
            tokenUri(_NFTAddr, _tokenId),
            _owner,
            address(_NFTAddr)
        );
        // // Store the token ID in the collectionToTokenId mapping
        registeredMetadata[_owner] = true;
        emit StakerRegistered(
            _owner,
            _tokenId,
            _totalSupply,
            _type,
            tokenName(_NFTAddr)
        );
    }

    function storeMetadata(
        //TODO RENAME to encodeMetadata and fix accordingly
        uint256 _tokenId,
        uint256 _totalSupply,
        uint256 _type,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _Owner,
        address _NFTAddr
    ) internal {
        bytes memory encodedData = abi.encode(
            _tokenId,
            _totalSupply,
            _type,
            _name,
            _symbol,
            _uri,
            _Owner,
            _NFTAddr
        );
        userMetadata[msg.sender] = encodedData;
    }

    function storeBurnerMetadata(
        bytes memory data
    )
        internal
        pure
        returns (uint256 _tokenId, address collection, address _burnerOwner)
    {
        return abi.decode(data, (uint256, address, address));
    }

    function getUserMetadata(
        address user
    )
        public
        view
        returns (
            uint256 _tokenId,
            uint256 _totalSupply,
            uint256 _type,
            string memory _name,
            string memory _symbol,
            string memory _uri,
            address _Owner,
            ERC721 _NFTAddr
        )
    {
        bytes memory encodedData = userMetadata[user];
        return
            abi.decode(
                encodedData,
                (
                    uint256,
                    uint256,
                    uint256,
                    string,
                    string,
                    string,
                    address,
                    ERC721
                )
            );
    }

    function sendMetaData(address _user) internal {
        bytes memory message;
        bytes memory encodedData = userMetadata[_user];
        //Assign ERC721-COMPATIBLE METADATA
        message = abi.encodeWithSignature(
            "registerMetadata(bytes)",
            encodedData
        );

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            xorigin,
            message,
            1000000 // irrelevant here
        );
        emit MetadataSet(msg.sender, tx.origin, getXorig(), _user, message);
    }

    function getXorig() public view returns (address) {
        // Get the cross domain messenger's address each time.
        // This is less resource intensive than writing to storage.
        address cdmAddr = address(0);

        // Mainnet
        if (block.chainid == 1)
            cdmAddr = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;

        // Goerli
        if (block.chainid == 5)
            cdmAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

        // L2 (same address on every network)
        if (block.chainid == 10 || block.chainid == 420)
            cdmAddr = 0x4200000000000000000000000000000000000007;

        // If this isn't a cross domain message
        if (msg.sender != cdmAddr) return address(0);

        // If it is a cross domain message, find out where it is from
        return ICrossDomainMessenger(cdmAddr).xDomainMessageSender();
    } // getXorig()

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
