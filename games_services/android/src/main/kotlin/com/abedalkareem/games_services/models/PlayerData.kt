package com.abedalkareem.games_services.models

data class PlayerData (
    val displayName: String,
    // playerID may be null if privacy settings do not allow current player
    // to see info about the this player
    val playerID: String?,
    val iconImage: String?
)