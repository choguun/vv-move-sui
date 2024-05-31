// Copyright (c) Voxelverses Game
// SPDX-License-Identifier: MIT

/// Module: pickaxe_nft
module voxelverses::pickaxe_nft {
    use sui::token::{Self, Token};
    use sui::tx_context::{sender};

    use voxelverses::game_token::GAME_TOKEN;
    use sui::token::TokenPolicy;

    /// Trying to purchase a pickaxe with an incorrect amount.
    const EWrongAmount: u64 = 0;

    /// The price of a pickaxe in game token.
    const PICKAXE_PRICE: u64 = 100;

    /// A game item that can be purchased with game token.
    public struct PickAxe has key, store { id: UID }
    public struct Shop has drop {}

    /// Purchase a pickaxe with game token.
    public fun buy_pickaxe(
        tokens: Token<GAME_TOKEN>,
        policy: &mut TokenPolicy<GAME_TOKEN>,
        ctx: &mut TxContext
    ) {
        assert!(token::value(&tokens) > 0, EWrongAmount);
        
        transfer::public_transfer(PickAxe { id: object::new(ctx) }, sender(ctx)); 
        let action_request = token::spend(tokens, ctx);
        token::confirm_request_mut(policy, action_request, ctx);
    }
}