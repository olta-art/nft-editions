# Olta NFT Editions [WIP]

These are a fork of [Zora NFT Editions](https://github.com/ourzora/nft-editions) with a few additions with a specific focus on NFT's with webpage content.

## This is still a work in progress!
We are currently testing these contracts locally along with a Dutch Auction House and a subgraph. Mumbai deployments coming soon!

Contributions are very welcome, you can reach out to us on discord or take a look at the current issues and create a pull request.

### What have we changed?
1. Added versioning for the animation and image urls. The implementation makes use of `Versions.sol` library contract to store a history of versions
2. The contract address to the animation url for easier querying of subgraphs from within the NFT content.
3. Support interface check for `IEditionSingleMintable.sol` useful for checking sales contracts.

### How does versioning work?
- Each version consist of an animation url, animation content hash, image url, image content hash and a version label.
- The last added version is assumed to be the latest and used for generating the metadata (this may change)
- It is still possible to update urls of a version.
- The versioning label follows the [semantic versioning](https://semver.org/) specification. This is to keep things neat and more easily order versions off-chain. The exact implementation uses is an array `[uint8, uint8, uint8]` limiting the max increment to 255.

### How to query the subgraph?
- TODO:

### What are these contracts?
1. `SingleEditionMintable`
   Each edition is a unique contract.
   This allows for easy royalty collection, clear ownership of the collection, and your own contract 🎉
2. `SingleEditionMintableCreator`
   Gas-optimized factory contract allowing you to easily + for a low gas transaction create your own edition mintable contract.
3. `SharedNFTLogic`
   Contract that includes dynamic metadata generation for your editions removing the need for a centralized server.
   imageUrl and animationUrl can be base64-encoded data-uris for these contracts totally removing the need for IPFS

### Where is the factory contract deployed:

**Mumbai**: [0xc95B8a16F31030b303DE1082fd90c4e02795F34e](https://mumbai.polygonscan.com/address/0xc95B8a16F31030b303DE1082fd90c4e02795F34e)

### How do I create a new edition?

call `createEdition` with the given arguments to create a new editions contract:

- Name: Token Name Symbol (shows in etherscan)
- Symbol: Symbol of the Token (shows in etherscan)
- Description: Description of the Token (shows in the NFT description)
- Animation URL: IPFS/Arweave URL of the animation (video, webpage, audio, etc)
- Animation Hash: sha-256 hash of the animation, 0x0 if no animation url provided
- Image URL: IPFS/Arweave URL of the image (image/, gifs are good for previewing images)
- Image Hash: sha-256 hash of the image, 0x0 if no image url provided
- Edition Size: Number of this edition, if set to 0 edition is not capped/limited
- BPS Royalty: 500 = 5%, 1000 = 10%, so on and so forth, set to 0 for no on-chain royalty (not supported by all marketplaces)

### How do I sell/distribute editions?

Now that you have a edition, there are multiple options for lazy-minting and sales:

1. To sell editions for ETH you can call `setSalePrice`
2. To allow certain accounts to mint `setApprovedMinter(address, approved)`.
3. To mint yourself to a list of addresses you can call `mintEditions(addresses[])` to mint an edition to each address in the list.

### Benefits of these contracts:

* Full ownership of your own created minting contract
* Each serial gets its own minting contract
* Gas-optimized over creating individual NFTs
* Fully compatible with ERC721 marketplaces / auction houses / tools
* Supports tracking unique parts (edition 1 vs 24 may have different pricing implications) of editions
* Supports free public minting (by approving the 0x0 (zeroaddress) to mint)
* Supports smart-contract based minting (by approving the custom minting smart contract) using an interface.
* All metadata is stored/generated on-chain -- only image/video assets are stored off-chain
* Permissionless and open-source
* Simple integrated ethereum-based sales, can be easily extended with custom interface code
