use starknet::ContractAddress;
use array::ArrayTrait;
use array::SpanTrait;
use starknet::account::Call;

#[derive(Drop, Copy, Serde)]
struct Stats {
    strength: u8, // 4 bits
    dexterity: u8, // 4 bits
    vitality: u8, // 4 bits
    intelligence: u8, // 4 bits
    wisdom: u8, // 4 bits
    charisma: u8, // 4 bits
    luck: u8 // // dynamically generated, not stored.
}

#[derive(Drop, Copy, Serde)]
struct AdventurerMetadata {
    start_block: u64, // 64 bits in storage
    starting_stats: Stats, // 24 bits in storage
    name: u128, // 128 bits in storage
    interface_camel: bool, // 1 bit bool in storage
}

#[starknet::interface]
trait IGame<TContractState> {
    fn get_health(self: @TContractState, adventurer_id: felt252) -> u16;
    fn get_xp(self: @TContractState, adventurer_id: felt252) -> u16;
    fn get_level(self: @TContractState, adventurer_id: felt252) -> u8;
    fn get_gold(self: @TContractState, adventurer_id: felt252) -> u16;
    fn owner_of(self: @TContractState, adventurer_id: felt252) -> ContractAddress;
    fn get_adventurer_meta(self: @TContractState, adventurer_id: felt252) -> AdventurerMetadata;
}


#[starknet::interface]
trait IMasterControl<TState> {
    fn update_whitelisted_contracts(ref self: TState, data: Array<(ContractAddress, bool)>);
    fn update_whitelisted_calls(ref self: TState, data: Array<(ContractAddress, felt252, bool)>);
    fn function_call(ref self: TState, data: Array<Call>) -> Array<Span<felt252>>;
    fn get_master_account(self: @TState) -> ContractAddress;
}

const ARCADE_ACCOUNT_ID: felt252 = 22227699753170493970302265346292000442692;
