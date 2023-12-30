## Tourney for Loot Survivor

This provides a basic guide on expanding Loot Survivor into a 1000-block tournament.

> NOTE: This is unaudited and not thoroughly tested. Copy at your own risk.

### Tournament

Players can submit their high score to the tournament if it exceeds the previous highest score, or if 1000 blocks have passed since the last winner's start_block.

If a player achieves the high score, they can claim the ERC20 or ERC721 balance of the contract every hour! Anyone can deposit any value or stream any value into this contract. The example includes a basic ERC20 token which gradually increases the tournament's funds over time.

#### Contracts

In the example, there is a contract named EliteGold. It is a basic ERC20 contract that allows players above level 15 to harvest the token. This is the only method to acquire this token, as it requires being elite, of course.

This example shows how you can read the value of the Loot Survivor contract.

#### Client

There is a basic UI showing how to integrate the contracts with Starknet React.
