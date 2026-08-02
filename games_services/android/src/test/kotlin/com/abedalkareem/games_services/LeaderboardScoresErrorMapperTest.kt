package com.abedalkareem.games_services

import com.abedalkareem.games_services.util.PluginError
import com.google.android.gms.common.api.CommonStatusCodes
import org.junit.Assert.assertEquals
import org.junit.Test

class LeaderboardScoresErrorMapperTest {
  @Test
  fun signInRequiredMapsToNotAuthenticated() {
    assertEquals(
      PluginError.NotAuthenticated,
      leaderboardScoresPluginError(CommonStatusCodes.SIGN_IN_REQUIRED)
    )
  }

  @Test
  fun otherApiStatusMapsToGenericFailure() {
    assertEquals(
      PluginError.FailedToLoadLeaderboardScores,
      leaderboardScoresPluginError(CommonStatusCodes.DEVELOPER_ERROR)
    )
  }

  @Test
  fun nonApiExceptionMapsToGenericFailure() {
    assertEquals(
      PluginError.FailedToLoadLeaderboardScores,
      leaderboardScoresPluginError(null)
    )
  }
}
