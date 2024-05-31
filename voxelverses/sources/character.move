// Copyright (c) Voxelverses Game
// SPDX-License-Identifier: MIT

/// Module: character
module voxelverses::character {
    use std::string::String;
    use sui::dynamic_field::{Self as df};
    use suifrens::suifrens::{SuiFren};

    /// Our Dynamic Field is a custom struct to make sure only our module can
    /// add/remove the GameData.
    public struct GameDataKey has copy, store, drop {}

    public struct GameData has store {
        nickname: String,
        level: u8,
        experience: u16,
    }

    /// A registration function for our SuiFren.
    public fun register<T>(fren: &mut SuiFren<T>, nickname: String) {
        df::add(fren.uid_mut(), GameDataKey {}, GameData {
            nickname,
            level: 1,
            experience: 0
        })
    }
}