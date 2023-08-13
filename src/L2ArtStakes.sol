// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721X} from "./AS_ERC721X.sol";
import {AS_ERC20} from "./AS_ERC20.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ArtStakes_Factory {
    using Clones for address;
    using Strings for uint256;
    error xNFT_AlreadyDeployed();

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
    event ERC20Deployed(address indexed erc20Address);
    event ERC721Deployed(ERC721X indexed _L2NFTContract);

    address public L1NFTContract;
    address public xorigin;
    address public crossDomainMessengerAddr =
        0x4200000000000000000000000000000000000007;
    address public deployer;
    address public erc20_master;
    address public erc721_master;
    bytes32 public RAND_SALT =
        bytes32(uint256(keccak256(abi.encodePacked(block.difficulty))));

    mapping(address => mapping(uint256 => AS_ERC20)) ERC20ToIdMapping;
    mapping(address => ERC721X) L1L2AddrToMapping;
    mapping(address => mapping(address => bool)) public ERC20Claimer;
    mapping(address => bool) public hasMetadata;
    mapping(uint256 => mapping(address => uint256)) public tokenType;
    mapping(address => bool) public L1NftCloneDeployed;
    mapping(address => mapping(uint256 => bool)) public mintedTokens;
    mapping(uint256 => uint256) public L1ToL2TokenId;
    mapping(address => bytes) public userMetadata;
    mapping(address => bytes) public burnerMetadata;

    constructor(address _erc20_master, address _erc721_master) {
        erc20_master = _erc20_master;
        erc721_master = _erc721_master;
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(deployer == msg.sender, "not deployer");
        _;
    }

    modifier onlyApprovedAddressXOrigin() {
        require(xorigin == getXorig(), "not permitted xchainMessanger");
        _;
    }

    function setXorigin(address _xorigin) public onlyDeployer {
        xorigin = _xorigin;
    }

    function mintXNFT() public returns (bool) {
        require(hasMetadata[msg.sender], "no metadata registered");

        bytes memory data = userMetadata[msg.sender];
        (
            uint256 _tokenId,
            ,
            ,
            ,
            ,
            string memory _uri,
            ,
            address _NFTAddr
        ) = getUserMetadata(data);

        require(
            L1NftCloneDeployed[_NFTAddr] = true,
            "you must deploy l2 Nft First"
        );
        require(!mintedTokens[_NFTAddr][_tokenId], "Token ID already minted");

        ERC721X deployed = L1L2AddrToMapping[_NFTAddr];

        uint256 L2TokenId = deployed.safeMint(msg.sender, _uri);

        L1ToL2TokenId[_tokenId] = L2TokenId;
        mintedTokens[_NFTAddr][_tokenId] = true;
        return true;
    }

    function _burnERC721(ERC721X _L2ERC721Addr, uint256 _L1tokenId) internal {
        uint256 L2TokenId = L1ToL2TokenId[_L1tokenId];
        _L2ERC721Addr.burn(L2TokenId);
    }

    function burnERC721(ERC721X _L2ERC721Addr, uint256 _L1tokenId) public {
        uint256 _type = tokenType[_L1tokenId][address(_L2ERC721Addr)];
        require(_type == 1, "wrong tokenType");

        address L1Collection = _L2ERC721Addr.L1CollectionAddress();
        require(mintedTokens[L1Collection][_L1tokenId], "Token ID not minted");

        uint256 L2TokenId = L1ToL2TokenId[_L1tokenId];
        address tokenOwner = _L2ERC721Addr.ownerOf(L2TokenId);
        require(tokenOwner == msg.sender, "not owner");

        mintedTokens[L1Collection][_L1tokenId] = false;

        _burnERC721(_L2ERC721Addr, _L1tokenId);

        encodeBurnerMetadata(_L1tokenId, L1Collection, tokenOwner);
        sendBurnerMetaDataX(msg.sender);
    }

    function _burnMajorityERC20(AS_ERC20 _erc20) internal {
        uint256 balance = _erc20.balanceOf(msg.sender);
        uint256 totalSupply = _erc20.totalSupply();
        uint256 minimumBalance = (totalSupply * 75) / 100;

        require(balance >= minimumBalance, "insufficient balance");

        _erc20.burnFrom(msg.sender, balance);
        _erc20.pause();
    }

    function BurnERC20TokenMajority(
        AS_ERC20 _erc20,
        uint256 _L1tokenId
    ) public {
        require(
            tokenType[_L1tokenId][address(_erc20)] == 2,
            "wrong tokenType to burn"
        );
        address L1collectionAddress = _erc20.L1CollectionAddress();

        AS_ERC20 erc20 = ERC20ToIdMapping[L1collectionAddress][_L1tokenId];

        require(erc20 == _erc20, "incorrect token");

        _burnMajorityERC20(_erc20);

        encodeBurnerMetadata(_L1tokenId, L1collectionAddress, msg.sender);
        sendBurnerMetaDataX(msg.sender);
    }

    function registerMetadata(
        bytes memory _Data
    ) public onlyApprovedAddressXOrigin {
        bytes memory data = _Data;
        (, , , , , , address _owner, ) = getUserMetadata(data);
        userMetadata[_owner] = data;
        hasMetadata[_owner] = true;
        emit MetadataSet(msg.sender, tx.origin, getXorig(), _owner, data);
    }

    function deployCorrospondingToken() public returns (address) {
        require(hasMetadata[msg.sender] == true, "no metadata registered");
        bytes32 _salt = RAND_SALT;
        bytes memory data = userMetadata[msg.sender];
        (
            uint256 _tokenId,
            uint256 _totalSupply,
            uint256 _type,
            string memory _name,
            string memory _symbol,
            ,
            address _Owner,
            address _NFTAddr
        ) = getUserMetadata(data);

        address collectionAddress = _NFTAddr;
        address deployed;
        if (_type == 1) {
            if (L1NftCloneDeployed[collectionAddress] == true) {
                revert xNFT_AlreadyDeployed();
            }
            deployed = FactorydeployXERC721Clone(
                _salt,
                _name,
                _symbol,
                _NFTAddr
            );
            L1NftCloneDeployed[collectionAddress] = true;
            L1L2AddrToMapping[_NFTAddr] = ERC721X(deployed);
            tokenType[_tokenId][deployed] = 1;
        } else if (_type == 2) {
            require(ERC20Claimer[collectionAddress][_Owner] == false);
            deployed = FactoryDeployERC20Clone(
                _salt,
                _name,
                _symbol,
                _totalSupply,
                _tokenId,
                address(this),
                _Owner,
                collectionAddress
            );
            tokenType[_tokenId][deployed] = 2;
            ERC20ToIdMapping[_NFTAddr][_tokenId] = AS_ERC20(deployed);
        } else {
            revert();
        }
        return deployed;
    }

    function FactorydeployXERC721Clone(
        bytes32 _salt,
        string memory _name,
        string memory _symbol,
        address _collectionAddress
    ) private returns (address) {
        require(erc721_master != address(0), "master must be set");
        ERC721X erc721Address = ERC721X(
            erc721_master.cloneDeterministic(_salt)
        );
        erc721Address = new ERC721X(_name, _symbol, address(this));
        erc721Address.setNftL1Address(_collectionAddress);
        emit ERC721Deployed(erc721Address);
        return address(erc721Address);
    }

    function FactoryDeployERC20Clone(
        bytes32 _salt,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _tokenId,
        address _owner,
        address _claimer,
        address _collectionAddress
    ) private returns (address) {
        require(erc20_master != address(0), "master must be set");
        AS_ERC20 erc20xAddress = AS_ERC20(
            erc20_master.cloneDeterministic(_salt)
        );
        erc20xAddress = new AS_ERC20(
            _name,
            _symbol,
            _totalSupply,
            _owner,
            _claimer,
            _collectionAddress
        );
        ERC20ToIdMapping[_collectionAddress][_tokenId] = erc20xAddress;
        ERC20Claimer[_collectionAddress][_owner] = true;
        emit ERC20Deployed(address(erc20xAddress));
        return address(erc20xAddress);
    }

    function encodeBurnerMetadata(
        uint256 _tokenId,
        address _collectionAddress,
        address _burnerOwner
    ) internal {
        bytes memory encodedData = abi.encode(
            _tokenId,
            _collectionAddress,
            _burnerOwner
        );
        burnerMetadata[_burnerOwner] = encodedData;
    }

    function sendBurnerMetaDataX(address _user) internal {
        bytes memory message;
        bytes memory encodedData = burnerMetadata[_user];
        message = abi.encodeWithSignature("ReceiveMessage(bytes)", encodedData);

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            xorigin,
            message,
            1000000
        );
        emit burnMetadata(msg.sender, tx.origin, getXorig(), _user, message);
    }

    function getXorig() private view returns (address) {
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
    }

    function getUserMetadata(
        bytes memory _data
    )
        public
        pure
        returns (
            uint256 _tokenId,
            uint256 _totalSupply,
            uint256 _type,
            string memory _name,
            string memory _symbol,
            string memory _uri,
            address _Owner,
            address _L1NFTAddr
        )
    {
        return
            abi.decode(
                _data,
                (
                    uint256,
                    uint256,
                    uint256,
                    string,
                    string,
                    string,
                    address,
                    address
                )
            );
    }
}
