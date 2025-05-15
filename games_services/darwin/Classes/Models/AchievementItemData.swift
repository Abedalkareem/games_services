import Foundation

struct AchievementItemData: Codable {
  var id: String
  var name: String
  var description: String
  var lockedImage: String?
  var unlockedImage: String?
  var completedSteps: Int
  var totalSteps: Int = 100
  var unlocked: Bool
}
