class AchievementItemData {
  final String id;
  final String name;

  /// On iOS/macOS [description] will be either [achievedDescription] or
  /// [unachievedDescription], depending on whether or not the achievement has been unlocked.
  final String description;

  /// The achievement's locked (unrevealed) image as base64.
  final String? lockedImage;

  /// The achievement's unlocked (revealed) image as base64.
  final String? unlockedImage;

  /// On Android the achievement type should be [TYPE_INCREMENTAL] to get the steps, otherwise it will be 0.
  /// On iOS/macOS [completedSteps] is the same as [percentComplete].
  final int completedSteps;

  /// On Android the achievement type should be [TYPE_INCREMENTAL] to get the total steps, otherwise it will be 0.
  /// On iOS/macOS [totalSteps] will always be 100.
  final int totalSteps;

  final bool unlocked;

  const AchievementItemData({
    required this.id,
    required this.name,
    required this.description,
    this.lockedImage,
    this.unlockedImage,
    required this.completedSteps,
    required this.totalSteps,
    required this.unlocked,
  });

  factory AchievementItemData.fromJson(Map<String, dynamic> json) {
    return AchievementItemData(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      unlockedImage: (json["unlockedImage"] as String?)?.replaceAll("\n", ""),
      lockedImage: (json["lockedImage"] as String?)?.replaceAll("\n", ""),
      totalSteps: json["totalSteps"],
      completedSteps: json["completedSteps"],
      unlocked: json["unlocked"],
    );
  }
}
