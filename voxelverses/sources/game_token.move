// Copyright (c) Voxelverses Game
// SPDX-License-Identifier: MIT

/// Module: game_token
module voxelverses::game_token {
    use std::option::none;
    use std::string::{Self, String};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::tx_context::{sender};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::token::{Self};
    use sui::event::emit;
    use sui::random::{Random, new_generator};
    use sui::token::TokenPolicy;

    // === Constants ===

    const MaxNumber: u8 = 63;


    // === Events ===

    /// Emitted when the greeting is created.
    public struct RuffleResulted has copy, drop {
        guess: u8,
        r: u8
    }

    const EWrongGuess: u64 = 0;
    const EInsufficientBalance: u64 = 11;

    public struct GameTokenStore has key, store {
        id: UID,
        profits: Balance<SUI>,
        gem_treasury: TreasuryCap<GAME_TOKEN>
    }

    public struct GAME_TOKEN has drop {}

    fun init(otw: GAME_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, coin_metadata) = coin::create_currency(
            otw, 0, b"Token", b"Game Token",
            b"In-game currency for Voxelverses", none(),
            ctx
        );

        // create a `TokenPolicy` for GEMs
        let (policy, cap) = token::new_policy(&treasury_cap, ctx);

        let mut policy = policy;
        token::allow(&mut policy, &cap, buy_action(), ctx);
        token::allow(&mut policy, &cap, token::spend_action(), ctx);

        transfer::share_object(GameTokenStore {
            id: object::new(ctx),
            gem_treasury: treasury_cap,
            profits: balance::zero()
        });

        // deal with `TokenPolicy`, `CoinMetadata` and `TokenPolicyCap`
        transfer::public_freeze_object(coin_metadata);
        transfer::public_transfer(cap, sender(ctx));
        token::share_policy(policy);
    }

    public fun buy_game_token(
        self: &mut GameTokenStore, payment: Coin<SUI>, ctx: &mut TxContext
    ) {
        assert!(coin::value(&payment) > 0, EInsufficientBalance);

        let amount = coin::value(&payment);
        let purchased = amount * 1000;

        coin::put(&mut self.profits, payment);

        let new_tokens = token::mint(&mut self.gem_treasury, purchased, ctx);
        let action_request = token::transfer(new_tokens, sender(ctx), ctx);
        token::confirm_with_treasury_cap(&mut self.gem_treasury, action_request, ctx);
    }

    /// The name of the `buy` action in the `GemStore`.
    public fun buy_action(): String { string::utf8(b"buy") }


    public fun do_raffle(guess: u8, r: &Random, self: &mut GameTokenStore, ctx: &mut TxContext) {
        let mut generator = r.new_generator(ctx);
        let r = generator.generate_u8_in_range(0, MaxNumber);

        emit(RuffleResulted {
            guess,
            r
        });
    
        // assert!(guess == r, EWrongGuess);

        let reward: u64 = 100;

        if (guess == r) {
            let new_tokens = token::mint(&mut self.gem_treasury, reward, ctx);
            let action_request = token::transfer(new_tokens, sender(ctx), ctx);
            token::confirm_with_treasury_cap(&mut self.gem_treasury, action_request, ctx);
        }
    }
}