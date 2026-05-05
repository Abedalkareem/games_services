import Foundation

struct SavedGame: Codable {
  var name: String
  var modificationDate: UInt64
  var deviceName: String
}
