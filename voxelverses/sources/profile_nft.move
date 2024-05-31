// Copyright (c) Voxelverses Game
// SPDX-License-Identifier: MIT

/// Module: profile_nft
module voxelverses::profile_nft {
    use std::string;
    use sui::event;

    public struct ProfileNFT has key, store {
        id: UID,
        username: string::String
    }
    
    // ===== Events =====
    public struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        username: string::String,
    }

    // ===== View Functions =====

    /// Get the NFT's name
    public fun username(nft: &ProfileNFT): &string::String {
        &nft.username
    }

    /// Create a new 
    public fun create_profile(
        username: string::String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = ProfileNFT {
            id: object::new(ctx),
            username: username
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            username: nft.username
        });

        transfer::public_transfer(nft, sender);
    }

    public fun transfer(
        nft: ProfileNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }

   
    public fun burn(nft: ProfileNFT, _: &mut TxContext) {
        let ProfileNFT { id, username: _} = nft;
        object::delete(id)
    }
}