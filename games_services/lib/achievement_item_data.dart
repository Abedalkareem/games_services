class AchievementItemData {
  final String? id;
  final String? name;
  final String? description;
  final String? lockedImage;
  final String? unlockedImage;
  final int? completedSteps;
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
