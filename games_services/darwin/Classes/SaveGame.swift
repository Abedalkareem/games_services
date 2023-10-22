import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class SaveGame: BaseGamesServices {
  
  func saveGame(name: String, data: String, result: @escaping FlutterResult) {
    guard let data = data.data(using: .utf8) else {
      result(PluginError.failedToSaveGame.flutterError)
      return }
    currentPlayer.saveGameData(data, withName: name) { savedGame, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSaveGame))
        return
      }
      result(nil)
    }
  }
  
  func getSavedGames(result: @escaping FlutterResult) {
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToGetSavedGames))
        return
      }
      let items = savedGames?
        .map({ SavedGame(name: $0.name ?? "",
                         modificationDate: UInt64($0.modificationDate?.timeIntervalSince1970 ?? 0),
                         deviceName: $0.deviceName ?? "") }) ?? []
      if let data = try? JSONEncoder().encode(items) {
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      } else {
        result(PluginError.failedToGetSavedGames.flutterError())
      }
    })
  }
  
  func loadGame(name: String, result: @escaping FlutterResult) {
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToLoadGame))
        return
      }
      
      guard let item = savedGames?
        .first(where: { $0.name == name }) else {
        result(PluginError.failedToLoadGame.flutterError())
        return
      }
      item.loadData { data, error in
        guard let data = data, error == nil else {
          result(error?.flutterError(code: .failedToLoadGame))
          return
        }
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      }
    })
  }
  
  func deleteGame(name: String, result: @escaping FlutterResult) {
    currentPlayer.deleteSavedGames(withName: name) { error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToDeleteSavedGame))
        return
      }
      result(nil)
    }
  }
  
}
