## ArtStakes

ArtStakes is a protocol seeking to empower NFT collectors and holders alike to do things that at first didn't seem possiable.

**Components**

- **StakerFactory**: Contract that deploys a staker contract, here the user can deposit their erc721 on an L1 chain and select a type of token bridged over to corrosponding OP L2 chain(Optimism/Zora/Base/Mode), sends a message to ERC721XFactory through L1CrossdomainMessanger.
- **Staker**: Staker contract where the user can stake their erc721 token, it only accepts the tokenId matching to the one inputted in StakerFactory.
- **ERC721XF**: Cloned ERC721 token representing the erc721 staked on the L1 chain, user can choose between an erc20 or an erc721, and this is the erc721 bridged over to L2 with the matching metadata, with subtle differences such as totalSupply and tokenId, which are still saved
- **ERC721XFactory**: factory to deploy ERC721, recieves message from StakerFactory through L2CrossDomainMessanger that carries over the metadata of the corrosponding token on the L1 chain.

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
