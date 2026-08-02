import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Achievements: BaseGamesServices {
  
  func showAchievements(result: @escaping FlutterResult) {
    if #available(iOS 18.0, macOS 15.0, *) {
      GKAccessPoint.shared.trigger(state: .achievements, handler: {})
    } else {
      let viewController = GKGameCenterViewController(state: .achievements)
      viewController.gameCenterDelegate = self
      self.viewController?.show(viewController)
    }
    result(Messages.success)
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
      result(Messages.success)
    }
  }
  
  func loadAchievements(ignoreImages: Bool, result: @escaping FlutterResult) {
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
          let incompleteAchievementImage = ignoreImages ? nil : incompleteAchievementImageData.tiffRepresentation?.base64EncodedString()
          #else
          let incompleteAchievementImage = ignoreImages ? nil : incompleteAchievementImageData.pngData()?.base64EncodedString()
          #endif
          var items = [AchievementItemData]()
          for (description, achievement) in achievementsMap {
            let image: String?
            if ignoreImages {
              image = nil
            } else {
              #if os(macOS)
              let uiimage = try? await description.loadImage()
              let imageData = uiimage?.tiffRepresentation
              #else
              let uiimage = try? await description.loadImage()
              let imageData = uiimage?.pngData()
              #endif
              image = imageData?.base64EncodedString()
            }
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
          result(Messages.success)
          } catch {
          result(error.flutterError(code: .failedToResetAchievements))
        }
      }
    }
  }
}

