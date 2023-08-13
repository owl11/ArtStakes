// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/L1ArtStakes.sol";
import "../src/mocks/mockERC721.sol";

contract StakerFactoryTest is Test {
    // Staker public staker;
    ArtStakes_Staker staker;
    Mock_ERC721 public erc721;
    uint256 public tokenId = 1;
    uint256 public totalSupply = 100 ether;
    address public randomOwner = address(0x11);

    function setUp() public {
        erc721 = new Mock_ERC721();
        erc721.mint(randomOwner, 3, "test.org");
        staker = new ArtStakes_Staker();
    }

    function testRegisterNFTMetadata() public {
        vm.prank(randomOwner);
        staker.registerMetaData(erc721, tokenId, totalSupply, 1);
        (
            uint256 _tokenId,
            uint256 _totalSupply,
            uint256 _type,
            ,
            ,
            string memory _uri,
            address _owner,
            ERC721 _NFTAddr
        ) = staker.getUserMetadata(randomOwner);
        assertEq(address(erc721), address(_NFTAddr));
        assertEq(_uri, "test.org");
        assertEq(tokenId, _tokenId);
        assertEq(totalSupply, _totalSupply);
        assertEq(randomOwner, _owner);
        assertEq(_type, 1);
    }

    modifier registerNFTMetadata() {
        vm.prank(randomOwner);
        staker.registerMetaData(erc721, tokenId, totalSupply, 2);
        _;
    }

    function testRegisterERC20Metadata() public {
        vm.prank(randomOwner);
        staker.registerMetaData(erc721, tokenId, totalSupply, 2);
    }

    function testRegisterRandomTypemetadata() public {
        vm.prank(randomOwner);
        vm.expectRevert();
        staker.registerMetaData(erc721, tokenId, 123, 444);
    }

    modifier registerMetaERC20data() {
        vm.prank(randomOwner);
        staker.registerMetaData(erc721, tokenId, totalSupply, 2);
        _;
    }

    function testNFTMetadataStake() public registerNFTMetadata {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stakeNFT();
    }

    modifier stakedNFTType() {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stakeNFT();
        _;
    }

    function testERC20MetadataStake() public registerMetaERC20data {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stakeNFT();
    }

    modifier stakedERC20Type() {
        vm.startPrank(randomOwner);
        erc721.approve(address(staker), 1);
        staker.stakeNFT();
        _;
    }

    function testReceiveMessage() public {
        bytes memory data = encodeBurnerMetadata(
            tokenId,
            address(erc721),
            randomOwner
        );
        staker.ReceiveMessage(data);
        (uint256 _tokenId, ERC721 _collectionAddress, address _owner) = staker
            .getUnstakerMetada(randomOwner);
        assertEq(_tokenId, tokenId);
        assertEq(randomOwner, _owner);
        assertEq(address(erc721), address(_collectionAddress));
    }

    modifier ReceivedMessage() {
        bytes memory data = encodeBurnerMetadata(
            tokenId,
            address(erc721),
            address(0x99)
        );
        staker.ReceiveMessage(data);
        _;
    }

    function testunstakeType1()
        public
        registerNFTMetadata
        stakedNFTType
        ReceivedMessage
    {
        vm.prank(address(0x99));
        staker.unStakeNFT();
    }

    function testunstakeType2()
        public
        registerMetaERC20data
        stakedERC20Type
        ReceivedMessage
    {
        vm.prank(address(0x99));
        staker.unStakeNFT();
    }

    function encodeBurnerMetadata(
        uint256 _tokenId,
        address _collectionAddress,
        address _burnerOwner
    ) internal pure returns (bytes memory data) {
        bytes memory encodedData = abi.encode(
            _tokenId,
            _collectionAddress,
            _burnerOwner
        );
        data = encodedData;
    }
}
