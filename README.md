## ArtStakes (WIP)

ArtStakes is a protocol seeking to unlock usecases for NFT's

**Components**

- **AS_ERC721X**: Cloned ERC721 token representing the erc721 staked on the L1 chain, user can choose between an ERC20 or an ERC721, and this is the ERC721 bridged over to L2 with the matching metadata, with subtle differences such as totalSupply and tokenId, which are still saved.

- **AS_ERC20**: Cloneable ERC20 Token contract following the spec, has the L2artStakes contract set as owner, with limited capabilities such as burning, minting under certain conditions.

- **L1ArtStakes**:
  This is the beginning of the user-flow, here you can set your NFT metadata, you can choose `type: 1` for ERC721 cloned NFT on the L2 Chain or `type: 2` for ERC20 tokens that you can specify the totalSupply for, once the transaction for setting the metadata is confirmed, you can stake your token (after giving approval to this contract on your NFT's contract) and have it ready for you to mint on the L2 of your choice.

- **L2ArtStakes**: This is where the user-flow continues, after your Nft was staked on the L1ArtStakes, it's clone will be unlocked here, you can then mint the corresponding token, which will be the token choice you've made already on the L1, additionally, the holder of the Cloned NFT, or a certain threshold of the ERC20 tokens, a user can burn the L2 Contract, and claim the Original NFT on the L1ArtStakes, working as an intermediary that facilitates permissionless fractionalization, Cloning as well as hopefully inspiring new ideas to be built on top.

### Build

```shell
$ forge install openzeppelin/openzeppelin-contracts@v4.9.2
$ cd lib
$ yarn
$ cd ..
```

### Test

```shell
$ forge test
```
