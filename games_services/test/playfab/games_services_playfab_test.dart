import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:games_services/games_services.dart';
import 'package:games_services/src/playfab/playfab_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps a PlayFab `data` payload in the `{code,status,data}` envelope the
/// client unwraps.
http.Response _ok(Map<String, dynamic> data) =>
    http.Response(jsonEncode({"code": 200, "status": "OK", "data": data}), 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Builds an impl whose HTTP calls are served by [handler], recording every
  /// request in [requests].
  (GamesServicesPlayFab, List<http.BaseRequest>) makeImpl(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final requests = <http.BaseRequest>[];
    final mock = MockClient((request) {
      requests.add(request);
      return handler(request);
    });
    final impl = GamesServicesPlayFab(
      playFabClient: PlayFabClient(titleId: "TEST", httpClient: mock),
    );
    return (impl, requests);
  }

  Map<String, dynamic> bodyOf(http.BaseRequest request) =>
      jsonDecode((request as http.Request).body) as Map<String, dynamic>;

  http.Request requestFor(List<http.BaseRequest> requests, String pathSuffix) =>
      requests.firstWhere((r) => r.url.path.endsWith(pathSuffix))
          as http.Request;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group("signIn", () {
    test("logs in with a custom id and emits the player", () async {
      final (impl, requests) = makeImpl((request) async {
        if (request.url.path.endsWith("/Client/LoginWithCustomID")) {
          return _ok({
            "SessionTicket": "ticket-123",
            "PlayFabId": "PF1",
            "EntityToken": {
              "EntityToken": "etoken",
              "Entity": {"Id": "E1", "Type": "title_player_account"},
            },
            "InfoResultPayload": {
              "PlayerProfile": {
                "DisplayName": "Ada",
                "AvatarUrl": "https://img/avatar.png",
              },
            },
          });
        }
        // Avatar download.
        return http.Response.bytes([1, 2, 3], 200);
      });

      final id = await impl.signIn();
      expect(id, "PF1");

      final body = bodyOf(requestFor(requests, "/Client/LoginWithCustomID"));
      expect(body["TitleId"], "TEST");
      expect(body["CreateAccount"], true);
      expect(body["CustomId"], isNotEmpty);

      final player = await impl.player.first;
      expect(player?.playerID, "PF1");
      expect(player?.displayName, "Ada");
      expect(player?.iconImage, base64Encode([1, 2, 3]));
    });

    test("reuses the persisted custom id across sign-ins", () async {
      final ids = <String>[];
      handler(http.Request request) async {
        if (request.url.path.endsWith("/Client/LoginWithCustomID")) {
          ids.add(jsonDecode(request.body)["CustomId"] as String);
          return _ok({"SessionTicket": "t", "PlayFabId": "PF1"});
        }
        return http.Response("", 404);
      }

      final (impl1, _) = makeImpl(handler);
      await impl1.signIn();
      final (impl2, _) = makeImpl(handler);
      await impl2.signIn();

      expect(ids, hasLength(2));
      expect(ids[0], ids[1]);
    });
  });

  group("leaderboards", () {
    Future<GamesServicesPlayFab> signedIn(
      Future<http.Response> Function(http.Request) handler,
    ) async {
      final (impl, _) = makeImpl((request) async {
        if (request.url.path.endsWith("/Client/LoginWithCustomID")) {
          return _ok({"SessionTicket": "t", "PlayFabId": "PF1"});
        }
        return handler(request);
      });
      await impl.signIn();
      return impl;
    }

    test("submitScore posts the statistic value", () async {
      late Map<String, dynamic> statBody;
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/UpdatePlayerStatistics")) {
          statBody = jsonDecode(request.body);
          return _ok({});
        }
        return http.Response("", 404);
      });

      await impl.submitScore(
          score: Score(iOSLeaderboardID: "highscore", value: 4200));

      final stats = statBody["Statistics"] as List;
      expect(stats.single["StatisticName"], "highscore");
      expect(stats.single["Value"], 4200);
    });

    test("loadLeaderboardScores maps entries to LeaderboardScoreData",
        () async {
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/GetLeaderboard")) {
          return _ok({
            "Version": 0,
            "Leaderboard": [
              {
                "PlayFabId": "PF1",
                "DisplayName": "Ada",
                "StatValue": 4200,
                "Position": 0,
                "Profile": {"AvatarUrl": "https://img/a.png"},
              },
            ],
          });
        }
        return http.Response("", 404);
      });

      final json = await impl.loadLeaderboardScores(
        iOSLeaderboardID: "highscore",
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: 10,
      );

      final scores = (jsonDecode(json!) as List)
          .map((e) => LeaderboardScoreData.fromJson(e))
          .toList();
      expect(scores.single.rank, 1); // Position 0 -> rank 1
      expect(scores.single.rawScore, 4200);
      expect(scores.single.displayScore, "4200");
      expect(scores.single.scoreHolder.displayName, "Ada");
      expect(scores.single.scoreHolder.playerID, "PF1");
    });

    test("getPlayerScore returns the statistic value", () async {
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/GetPlayerStatistics")) {
          return _ok({
            "Statistics": [
              {"StatisticName": "highscore", "Value": 99, "Version": 0}
            ]
          });
        }
        return http.Response("", 404);
      });

      expect(await impl.getPlayerScore(iOSLeaderboardID: "highscore"), 99);
    });
  });

  group("achievements", () {
    Future<GamesServicesPlayFab> signedIn(
      Future<http.Response> Function(http.Request) handler,
    ) async {
      final (impl, _) = makeImpl((request) async {
        if (request.url.path.endsWith("/Client/LoginWithCustomID")) {
          return _ok({"SessionTicket": "t", "PlayFabId": "PF1"});
        }
        return handler(request);
      });
      await impl.signIn();
      return impl;
    }

    test("loadAchievements merges title-data defs with user-data progress",
        () async {
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/GetTitleData")) {
          return _ok({
            "Data": {
              "achievements": jsonEncode([
                {
                  "id": "first_win",
                  "name": "First Win",
                  "description": "Win a game",
                  "steps": 0,
                },
                {
                  "id": "100_kills",
                  "name": "Centurion",
                  "description": "100 kills",
                  "steps": 100,
                },
              ]),
            },
          });
        }
        if (request.url.path.endsWith("/Client/GetUserData")) {
          return _ok({
            "Data": {
              "achievements_progress": {
                "Value": jsonEncode({
                  "first_win": {"unlocked": true, "steps": 0},
                  "100_kills": {"unlocked": false, "steps": 40},
                }),
              },
            },
          });
        }
        return http.Response("", 404);
      });

      final json = await impl.loadAchievements();
      final items = (jsonDecode(json!) as List)
          .map((e) => AchievementItemData.fromJson(e))
          .toList();

      final firstWin = items.firstWhere((a) => a.id == "first_win");
      expect(firstWin.unlocked, true);
      expect(firstWin.name, "First Win");

      final centurion = items.firstWhere((a) => a.id == "100_kills");
      expect(centurion.unlocked, false);
      expect(centurion.completedSteps, 40);
      expect(centurion.totalSteps, 100);
    });

    test("unlock writes unlocked progress to user data", () async {
      late Map<String, dynamic> updateBody;
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/GetUserData")) {
          return _ok({"Data": {}});
        }
        if (request.url.path.endsWith("/Client/UpdateUserData")) {
          updateBody = jsonDecode(request.body);
          return _ok({});
        }
        return http.Response("", 404);
      });

      await impl.unlock(achievement: Achievement(iOSID: "first_win"));

      final progress = jsonDecode(
          (updateBody["Data"] as Map)["achievements_progress"] as String);
      expect(progress["first_win"]["unlocked"], true);
    });

    test("increment unlocks once total steps are reached", () async {
      late Map<String, dynamic> updateBody;
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Client/GetTitleData")) {
          return _ok({
            "Data": {
              "achievements": jsonEncode([
                {
                  "id": "100_kills",
                  "name": "C",
                  "description": "d",
                  "steps": 100
                }
              ]),
            },
          });
        }
        if (request.url.path.endsWith("/Client/GetUserData")) {
          return _ok({
            "Data": {
              "achievements_progress": {
                "Value": jsonEncode({
                  "100_kills": {"unlocked": false, "steps": 60}
                }),
              },
            },
          });
        }
        if (request.url.path.endsWith("/Client/UpdateUserData")) {
          updateBody = jsonDecode(request.body);
          return _ok({});
        }
        return http.Response("", 404);
      });

      await impl.increment(
          achievement: Achievement(iOSID: "100_kills", steps: 50));

      final progress = jsonDecode(
          (updateBody["Data"] as Map)["achievements_progress"] as String);
      expect(progress["100_kills"]["steps"], 110);
      expect(progress["100_kills"]["unlocked"], true);
    });
  });

  group("saved games", () {
    Future<GamesServicesPlayFab> signedIn(
      Future<http.Response> Function(http.Request) handler,
    ) async {
      final (impl, _) = makeImpl((request) async {
        if (request.url.path.endsWith("/Client/LoginWithCustomID")) {
          return _ok({
            "SessionTicket": "t",
            "PlayFabId": "PF1",
            "EntityToken": {
              "EntityToken": "etoken",
              "Entity": {"Id": "E1", "Type": "title_player_account"},
            },
          });
        }
        return handler(request);
      });
      await impl.signIn();
      return impl;
    }

    test("saveGame uploads an envelope file then indexes it", () async {
      final puts = <List<int>>[];
      Map<String, dynamic>? indexObject;
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/File/InitiateFileUploads")) {
          return _ok({
            "UploadDetails": [
              {"FileName": "x", "UploadUrl": "https://blob/upload"}
            ],
            "ProfileVersion": 1,
          });
        }
        if (request.method == "PUT") {
          puts.add(request.bodyBytes);
          return http.Response("", 201);
        }
        if (request.url.path.endsWith("/File/FinalizeFileUploads")) {
          return _ok({});
        }
        if (request.url.path.endsWith("/Object/GetObjects")) {
          return _ok({"Objects": {}});
        }
        if (request.url.path.endsWith("/Object/SetObjects")) {
          indexObject = (jsonDecode((request).body)["Objects"] as List)
              .single["DataObject"] as Map<String, dynamic>;
          return _ok({});
        }
        return http.Response("", 404);
      });

      final result = await impl.saveGame(data: "savedata", name: "slot1");
      expect(result, "success");

      // The uploaded bytes are the JSON envelope containing the save data.
      final envelope = jsonDecode(utf8.decode(puts.single));
      expect(envelope["data"], "savedata");

      // The index records the human-readable save name.
      expect(indexObject!.containsKey("slot1"), true);
    });

    test("getSavedGames reads the index object", () async {
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/Object/GetObjects")) {
          return _ok({
            "Objects": {
              "saved_games": {
                "ObjectName": "saved_games",
                "DataObject": {
                  "slot1": {
                    "fileName": "abc.save",
                    "modificationDate": 123,
                    "deviceName": "PC",
                  },
                },
              },
            },
          });
        }
        return http.Response("", 404);
      });

      final json = await impl.getSavedGames();
      final games = (jsonDecode(json!) as List)
          .map((e) => SavedGame.fromJson(e))
          .toList();
      expect(games.single.name, "slot1");
      expect(games.single.modificationDate, 123);
      expect(games.single.deviceName, "PC");
    });

    test("loadGame downloads and unwraps the envelope", () async {
      final impl = await signedIn((request) async {
        if (request.url.path.endsWith("/File/GetFiles")) {
          // File name is the hex encoding of "slot1".
          final fileName = utf8
              .encode("slot1")
              .map((b) => b.toRadixString(16).padLeft(2, "0"))
              .join();
          return _ok({
            "Metadata": {
              "$fileName.save": {
                "FileName": "$fileName.save",
                "DownloadUrl": "https://blob/download",
              },
            },
          });
        }
        if (request.method == "GET" && request.url.host == "blob") {
          return http.Response(
              jsonEncode({"data": "savedata", "coverImage": null}), 200);
        }
        return http.Response("", 404);
      });

      expect(await impl.loadGame(name: "slot1"), "savedata");
    });
  });

  group("unsupported methods", () {
    test("native-UI and Apple/Google-only methods return null", () async {
      final (impl, _) = makeImpl((request) async => _ok({}));
      expect(await impl.showAchievements(), isNull);
      expect(await impl.showLeaderboards(), isNull);
      expect(await impl.hideAccessPoint(), isNull);
      expect(await impl.getAuthCode("client"), isNull);
      expect(await impl.fetchIdentityVerificationSignature(), isNull);
    });
  });
}
