// Copyright (c) Voxelverses Game
// SPDX-License-Identifier: MIT

/// Module: character
module voxelverses::character {
    use std::string::String;
    use sui::dynamic_field::{Self as df};
    use suifrens::suifrens::{SuiFren};
    use sui::tx_context::{sender};

    /// Our Dynamic Field is a custom struct to make sure only our module can
    /// add/remove the GameData.
    public struct GameDataKey has copy, store, drop {}

    public struct GameData has store {
        level: u8,
        experience: u16,
        nfttype: u8,
        inventory: vector<u16>
    }


    public struct CharacterNFT has key, store {
        id: UID,
    }

    public fun mint(ctx: &mut TxContext) {
        let mut nft = CharacterNFT {
            id: object::new(ctx),
        };

        transfer::public_transfer(nft, sender(ctx));
    }

    public fun registerDefault(nft: &mut CharacterNFT) {
        df::add(&mut nft.id, GameDataKey {}, GameData {
            level: 1,
            experience: 0,
            nfttype: 0,
            inventory: vector[]
        })
    }

    /// A registration function for our SuiFren.
    public fun registerSuiFren<T>(fren: &mut SuiFren<T>) {
        df::add(fren.uid_mut(), GameDataKey {}, GameData {
            level: 1,
            experience: 0,
            nfttype: 1,
            inventory: vector[]
        })
    }

    public fun up_exp(data: &mut GameData) {
        data.experience = data.experience + 1;
    }

    public fun up_level(data: &mut GameData) {
        data.level = data.level + 1;
    }

    public fun add_item(data: &mut GameData, item: u16) {
        let size = data.inventory.length();
        data.inventory.insert(item, size+1);
    }
}