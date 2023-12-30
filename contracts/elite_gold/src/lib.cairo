mod interface;
mod test;

#[starknet::contract]
mod EliteGold {
    use openzeppelin::token::erc20::interface::IERC20Metadata;
    use elite_gold::interface::{
        IGame, IGameDispatcher, IGameDispatcherTrait, IMasterControl, IMasterControlDispatcher,
        IMasterControlDispatcherTrait, ARCADE_ACCOUNT_ID
    };

    use openzeppelin::token::erc20::ERC20Component;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    use openzeppelin::introspection::interface::{
        ISRC5Dispatcher, ISRC5DispatcherTrait, ISRC5CamelDispatcher, ISRC5CamelDispatcherTrait
    };


    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        survivor: IGameDispatcher,
        claimed: LegacyMap::<felt252, bool>,
        tourney_address: ContractAddress,
        start_time: u64
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, game_address: ContractAddress, tourney_address: ContractAddress
    ) {
        self.erc20.initializer('EliteGold', 'EGLD');

        self.survivor.write(IGameDispatcher { contract_address: game_address });

        self.tourney_address.write(tourney_address);

        self.start_time.write(get_block_timestamp());
    }

    #[starknet::interface]
    trait IEliteGold<TContractState> {
        fn harvest_elite_gold(ref self: TContractState, adventurer_id: felt252, camel: bool);
    }

    #[external(v0)]
    impl EliteGoldImpl of IEliteGold<ContractState> {
        fn harvest_elite_gold(ref self: ContractState, adventurer_id: felt252, camel: bool) {
            let caller = get_caller_address();

            let owner = self.survivor.read().owner_of(adventurer_id);

            // if caller is not owner, must be primary account holder based on AA
            if owner != caller {
                assert(caller == _get_primary_account_address(owner, camel), 'Not your adventurer');
            }

            // no no no
            let claimed = self.claimed.read(adventurer_id);
            assert(!claimed, 'Already claimed');

            // must be dead
            let health = self.survivor.read().get_health(adventurer_id);
            assert(health == 0, 'Must be dead');

            // must be level 15 and L33T
            let level = self.survivor.read().get_level(adventurer_id);
            assert(level >= 15, 'Not L33T enough');

            // i love gold
            let gold = self.survivor.read().get_gold(adventurer_id);
            assert(gold > 0, 'No gold to claim');

            // 6 month claim period
            assert(get_block_timestamp() <= self.start_time.read() + 15778463, 'Past claim window');

            // give 18 decimals
            let amount = gold.into() * 10 * 1000000000000000000;

            // 5% tourney fee
            let tourney_fee = amount * 500 / 10000;

            // mint caller
            self.erc20._mint(caller, amount - tourney_fee);

            // mint fee
            self.erc20._mint(self.tourney_address.read(), tourney_fee);

            // mark as claimed
            self.claimed.write(adventurer_id, true);
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
