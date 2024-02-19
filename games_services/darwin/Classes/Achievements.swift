import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Achievements: BaseGamesServices {
  
  func showAchievements(result: @escaping FlutterResult) {
    let viewController = GKGameCenterViewController()
    viewController.gameCenterDelegate = self
    viewController.viewState = .achievements
    self.viewController.show(viewController)
    result(nil)
  }
  
  func report(achievementID: String, percentComplete: Double, showsCompletionBanner: Bool, result: @escaping FlutterResult) {
    let achievement = GKAchievement(identifier: achievementID)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = showsCompletionBanner
    GKAchievement.report([achievement]) { (error) in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSendAchievement))
        return
      }
      result(nil)
    }
  }
  
  func loadAchievements(result: @escaping FlutterResult) {
    if #available(iOS 13.0, *) {
      Task {
        do {
          let achievements = try await GKAchievement.loadAchievements()
          let descriptions = try await GKAchievementDescription.loadAchievementDescriptions()
          
          let achievementsMap = descriptions.reduce(into: [GKAchievementDescription: GKAchievement?]()) { result, description in
            result[description] = achievements.first(where: { $0.identifier == description.identifier })
          }
          
          let incompleteAchievementImageData = GKAchievementDescription.incompleteAchievementImage()
          #if os(macOS)
          let incompleteAchievementImage = incompleteAchievementImageData.tiffRepresentation?.base64EncodedString()
          #else
          let incompleteAchievementImage = incompleteAchievementImageData.pngData()?.base64EncodedString()
          #endif
          var items = [AchievementItemData]()
          for (description, achievement) in achievementsMap {
            #if os(macOS)
            let uiimage = try? await description.loadImage()
            let imageData = uiimage?.tiffRepresentation
            #else
            let uiimage = try? await description.loadImage()
            let imageData = uiimage?.pngData()
            #endif
            let image = imageData?.base64EncodedString()
            let isCompleted = achievement?.isCompleted ?? false
            let achievementDescription = isCompleted ? description.achievedDescription : description.unachievedDescription
            items.append(AchievementItemData(id: description.identifier,
                                             name: description.title,
                                             description: achievementDescription,
                                             lockedImage: incompleteAchievementImage,
                                             unlockedImage: image,
                                             completedSteps: Int(achievement?.percentComplete ?? 0),
                                             unlocked: isCompleted))
          }
          if let data = try? JSONEncoder().encode(items) {
            let string = String(data: data, encoding: String.Encoding.utf8)
            result(string)
          } else {
            result(PluginError.failedToLoadAchievements.flutterError())
          }
          
        } catch {
          result(error.flutterError(code: .failedToLoadAchievements))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func resetAchievements(result: @escaping FlutterResult) {
    if #available(iOS 13.0, *) {
      Task {
        do {
          try await GKAchievement.resetAchievements()
          result(nil)
          } catch {
          result(error.flutterError(code: .failedToResetAchievements))
        }
      }
    }
  }
}

