#[starknet::interface]
trait ITourney<TContractState> {
    fn claim_erc20(ref self: TContractState, token_address: starknet::ContractAddress);
    fn claim_erc721(
        ref self: TContractState, token_address: starknet::ContractAddress, token_id: u256
    );
    fn set_high_score(ref self: TContractState, survivor_id: felt252, camel: bool);
    fn get_winner(self: @TContractState) -> starknet::ContractAddress;
    fn get_high_score(self: @TContractState) -> u16;
    fn get_survivor_id(self: @TContractState) -> felt252;
    fn get_blocks_till_end(self: @TContractState) -> u64;
}

//
// 1000 Block Tourney 
// @dev: This contract allows users to compete for the highest score within a 1000 block window
//      The winner can claim the balance of any token in the contract.

#[starknet::contract]
mod tourney {
    use openzeppelin::token::erc721::interface::ERC721ABIDispatcherTrait;
    use super::ITourney;

    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp, get_block_info,
        get_contract_address
    };

    use loot_survivor::{
        IGame, IGameDispatcher, IGameDispatcherTrait, IMasterControl, IMasterControlDispatcher,
        IMasterControlDispatcherTrait, ARCADE_ACCOUNT_ID
    };

    use openzeppelin::{
        token::erc20::{ERC20ABIDispatcherTrait, ERC20ABIDispatcher},
        token::erc721::{interface::{ERC721ABI, ERC721ABIDispatcher}},
        introspection::interface::{
            ISRC5Dispatcher, ISRC5DispatcherTrait, ISRC5CamelDispatcher, ISRC5CamelDispatcherTrait
        }
    };

    #[storage]
    struct Storage {
        survivor: IGameDispatcher,
        last_claimed_erc20: u64,
        last_claimed_erc721: u64,
        survivor_id: felt252,
        winner: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Claim: Claim,
        HighScore: HighScore
    }

    #[derive(Drop, starknet::Event)]
    struct Claim {
        claimer: ContractAddress,
        token_address: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct HighScore {
        survivor_id: felt252,
        winner: ContractAddress,
        score: u16
    }

    #[constructor]
    fn constructor(ref self: ContractState, game_address: ContractAddress) {
        self.survivor.write(IGameDispatcher { contract_address: game_address });
    }

    #[external(v0)]
    impl TourneyImpl of ITourney<ContractState> {
        // allows claiming of balance of any token in contract
        fn claim_erc20(ref self: ContractState, token_address: ContractAddress) {
            let caller = get_caller_address();

            // must be at least 1 hour since last claim
            assert(
                get_block_timestamp() - self.last_claimed_erc20.read() > 3600,
                'Claim Failed: Too soon to claim'
            );

            // caller must be winner
            assert(caller == self.winner.read(), 'Claim Failed: Not the winner');

            let token = ERC20ABIDispatcher { contract_address: token_address };

            // transfer balance to winner
            token.transfer(caller, token.balance_of(get_contract_address()));

            // update last claimed
            self.last_claimed_erc20.write(get_block_timestamp());

            self
                .emit(
                    Claim {
                        claimer: caller,
                        token_address,
                        amount: token.balance_of(get_contract_address())
                    }
                );
        }

        fn claim_erc721(ref self: ContractState, token_address: ContractAddress, token_id: u256) {
            let caller = get_caller_address();

            // must be at least 1 hour since last claim
            assert(
                get_block_timestamp() - self.last_claimed_erc721.read() > 3600,
                'Claim Failed: Too soon to claim'
            );

            // caller must be winner
            assert(caller == self.winner.read(), 'Claim Failed: Not the winner');

            let token = ERC721ABIDispatcher { contract_address: token_address };

            // transfer balance to winner
            token.transfer_from(get_contract_address(), caller, token_id);

            // update last claimed
            self.last_claimed_erc721.write(get_block_timestamp());
        }

        // sets the high score and winner
        fn set_high_score(ref self: ContractState, survivor_id: felt252, camel: bool) {
            let caller = get_caller_address();
            let owner = self.survivor.read().owner_of(survivor_id);

            // if caller is not owner, must be primary account holder based on AA
            if owner != caller {
                assert(
                    caller == _get_primary_account_address(owner, camel),
                    'Failed: Not your adventurer'
                );
            }

            // must be born within last 999 blocks
            assert(
                get_block_info().unbox().block_number
                    - self.survivor.read().get_adventurer_meta(survivor_id).start_block < 1000,
                'Failed: Too late to submit'
            );

            // if there is a current high score, else just set it
            if (self.survivor_id.read() != 0) {
                // if the current high score is more than 1000 blocks old, you can overwrite it
                if (get_block_info().unbox().block_number
                    - self
                        .survivor
                        .read()
                        .get_adventurer_meta(self.survivor_id.read())
                        .start_block < 1000) {
                    // check high score
                    assert(
                        self.survivor.read().get_xp(survivor_id) > self.get_high_score(),
                        'Failed: Not a higher score'
                    );
                }
            }

            // set new high score and winner
            self.survivor_id.write(survivor_id);
            self.winner.write(caller);

            // emit highscore
            self
                .emit(
                    HighScore {
                        survivor_id: survivor_id,
                        winner: caller,
                        score: self.survivor.read().get_xp(survivor_id)
                    }
                );
        }

        // returns the high score
        fn get_high_score(self: @ContractState) -> u16 {
            if (self.survivor_id.read() == 0) {
                0
            } else {
                self.survivor.read().get_xp(self.survivor_id.read())
            }
        }

        // returns the winner
        fn get_winner(self: @ContractState) -> ContractAddress {
            self.winner.read()
        }

        // returns the survivor id
        fn get_survivor_id(self: @ContractState) -> felt252 {
            self.survivor_id.read()
        }

        // returns the number of blocks until the next restart
        fn get_blocks_till_end(self: @ContractState) -> u64 {
            if (self.survivor_id.read() == 0) {
                0
            } else {
                let blocks = 1000
                    - self.survivor.read().get_adventurer_meta(self.survivor_id.read()).start_block;
                if (blocks > 0) {
                    blocks
                } else {
                    0
                }
            }
        }
    }

    fn _get_primary_account_address(
        address: ContractAddress, interface_camel: bool
    ) -> ContractAddress {
        if interface_camel {
            let account_camel = ISRC5CamelDispatcher { contract_address: address };
            if account_camel.supportsInterface(ARCADE_ACCOUNT_ID) {
                IMasterControlDispatcher { contract_address: address }.get_master_account()
            } else {
                address
            }
        } else {
            let account_snake = ISRC5Dispatcher { contract_address: address };
            if account_snake.supports_interface(ARCADE_ACCOUNT_ID) {
                IMasterControlDispatcher { contract_address: address }.get_master_account()
            } else {
                address
            }
        }
    }
}
