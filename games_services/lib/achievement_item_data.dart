class AchievementItemData {
  final String? id;
  final String? name;

  /// On iOS [description] will be [achievedDescription] in case chievement completed else it
  /// will be [unachievedDescription].
  final String? description;

  /// The achievement locked (revealed) image as base64.
  final String? lockedImage;

  /// The achievement locked (revealed) image as base64.
  final String? unlockedImage;

  /// On android the achievement type should be [TYPE_INCREMENTAL] to get the steps, else it will be 0.
  /// On iOS [completedSteps] is same as [percentComplete].
  final int? completedSteps;

  /// On android the achievement type should be [TYPE_INCREMENTAL] to get the total steps, else it will be 0.
  /// On iOS [totalSteps] will have always 100.
  final int? totalSteps;

  final bool? unlocked;

  const AchievementItemData({
    this.id,
    this.name,
    this.description,
    this.lockedImage,
    this.unlockedImage,
    this.completedSteps,
    this.totalSteps,
    this.unlocked,
  });

  factory AchievementItemData.fromJson(Map<String, dynamic> json) {
    return AchievementItemData(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      unlockedImage: json["unlockedImage"],
      lockedImage: json["lockedImage"],
      totalSteps: json["totalSteps"],
      completedSteps: json["completedSteps"],
      unlocked: json["unlocked"],
    );
  }
}
