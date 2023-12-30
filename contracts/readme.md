# onchain NFT Market

Simple Starknet onchain Market

### Environment Configuration

```bash
# Set the StarkNet network to mainnet
export STARKNET_NETWORK="goerli"

# Starkli commands
starkli
starkli account oz init ./account
starkli account deploy ./account

# Set StarkNet RPC for mainnet and goerli
export STARKNET_RPC="https://starknet-mainnet.g.alchemy.com/v2/G9wJH34O_F038b_k329lcjOd_o38JA3j"
export STARKNET_RPC="https://starknet-testnet.public.blastapi.io/rpc/v0_6"

# Set the keystore path
export STARKNET_KEYSTORE=<PATH>

# Declare and deploy contracts
starkli declare /Users/os/Documents/code/loaf/leetgold/contracts/target/dev/elite_gold_EliteGold.contract_class.json --account ./account --keystore ./keys
starkli deploy 0x05a3f02c29613a729de1065a67f8106532347477fc4d90d45b53b149ed3387d7 $GAME_ADDRESS $TOURNEY_ADDRESS --account ./account --keystore ./keys

# elite gold
0x078a40f824dabaca126a9a0cff57e25d7b0b66df011adfb87092de4acc0819e6

# tourney
starkli declare /Users/os/Documents/code/loaf/leetgold/contracts/target/dev/tourney_tourney.contract_class.json --account ./account --keystore ./keys
starkli deploy 0x02f1d67ed2b3ee1712d67ef748c11dcae9e36a40a971cd2b8c42324527954ff0 $GAME_ADDRESS --account ./account --keystore ./keys

# tourney
0x0095a666f6e44b25000efe6ff67f13bf581f8eca732ce6403b6c2ea7a986a724

# then
export MARKET_ADDRESS=0x07724c0cc6d78237b0c6103eb545c4f8560389145d87e02057c093bc9c275cd0
```

### Configuration for Goerli and Mainnet

```bash
# mainnet
export GAME_ADDRESS=0x03c10537fa0073b2dd5120242697dbf76d6173eb9f384d3bf3d284d53388a0b0
export TOURNEY_ADDRESS=0x65ce28a1d99a085a0d5b4d07ceb9b80a9ef0e64a525bf526cff678c619fc4b1

# goerli
export GAME_ADDRESS=0x071d07b1217cdcc334739a3f28da75db05d62672ad04b9204ee11b88f2f9f61c
export TOURNEY_ADDRESS=0x0095a666f6e44b25000efe6ff67f13bf581f8eca732ce6403b6c2ea7a986a724
```

### Whitelist Collections

```bash
# Add whitelist
starkli invoke $MARKET_ADDRESS whitelist_collection $GOLDEN_TOKEN_ADDRESS --account ./account --keystore ./keys

starkli invoke $MARKET_ADDRESS whitelist_collection $BEASTS_ADDRESS --account ./account --keystore ./keys
```

### test

```bash
starkli declare /Users/os/Documents/code/biblio/onchain-nft-market/target/dev/marketplace_MyNFT.contract_class.json --account ./account --keystore ./keys
```
