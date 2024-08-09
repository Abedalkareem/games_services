import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class SaveGame: BaseGamesServices {
  
  func saveGame(name: String, data: String, result: @escaping FlutterResult) {
    log("[SaveGame] Start saving game")
    guard let data = data.data(using: .utf8) else {
      log("[SaveGame] failed to get data from a string \(data)")
      result(PluginError.failedToSaveGame.flutterError)
      return
    }
    
    log("[SaveGame] Start saving the game to current player")
    currentPlayer.saveGameData(data, withName: name) { savedGame, error in
      guard error == nil else {
        log("[SaveGame] Something went wrong \(error?.localizedDescription ?? "")")
        result(error?.flutterError(code: .failedToSaveGame))
        return
      }
      
      log("[SaveGame] Saved successfully")
      result(nil)
    }
  }
  
  func getSavedGames(result: @escaping FlutterResult) {
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      log("[GetSavedGames] Start loading all saved games")
      guard error == nil else {
        log("[GetSavedGames] Something went wrong \(error?.localizedDescription ?? "")")
        result(error?.flutterError(code: .failedToGetSavedGames))
        return
      }
      let items = savedGames?
        .map({ SavedGame(name: $0.name ?? "",
                         modificationDate: UInt64($0.modificationDate?.timeIntervalSince1970 ?? 0),
                         deviceName: $0.deviceName ?? "") }) ?? []
      if let data = try? JSONEncoder().encode(items) {
        log("[GetSavedGames] Loaded successfully")
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      } else {
        log("[GetSavedGames] Something wrong with the data \(items)")
        result(PluginError.failedToGetSavedGames.flutterError())
      }
    })
  }
  
  func loadGame(name: String, result: @escaping FlutterResult) {
    log("[LoadGame] Start loading the saved games")
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      log("[LoadGame] Got saved games result")
      guard error == nil else {
        log("[LoadGame] something went wrong \(error?.localizedDescription ?? "")")
        result(error?.flutterError(code: .failedToLoadGame))
        return
      }
      
      guard let item = savedGames?
        .first(where: { $0.name == name }) else {
        log("[LoadGame] Saved game not found")
        result(PluginError.failedToLoadGame.flutterError())
        return
      }
      
      log("[LoadGame] Start loading the saved game data")
      item.loadData { data, error in
        guard let data = data, error == nil else {
          log("[LoadGame] Something went wrong loading the saved game data \(error?.localizedDescription ?? "")")
          result(error?.flutterError(code: .failedToLoadGame))
          return
        }
        log("[LoadGame] Got the saved game data")
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      }
    })
  }
  
  func deleteGame(name: String, result: @escaping FlutterResult) {
    log("[DeleteGame] Start deleting game")
    currentPlayer.deleteSavedGames(withName: name) { error in
      guard error == nil else {
        log("[DeleteGame] Something went wrong \(error?.localizedDescription ?? "")")
        result(error?.flutterError(code: .failedToDeleteSavedGame))
        return
      }
      log("[DeleteGame] Deleted successfully")
      result(nil)
    }
  }
  
}
