class AchievementItemData {
  final String? id;
  final String? name;
  final String? description;
  final String? revealedImageUrl;
  final String? unlockedImageUrl;
  final int? completedSteps;
  final int? totalSteps;
  final bool? unlocked;

  const AchievementItemData({
    this.id,
    this.name,
    this.description,
    this.revealedImageUrl,
    this.unlockedImageUrl,
    this.completedSteps,
    this.totalSteps,
    this.unlocked,
  });

  factory AchievementItemData.fromJson(Map<String, dynamic> json) {
    return AchievementItemData(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      unlockedImageUrl: json["unlockedImageUrl"],
      revealedImageUrl: json["revealedImageUrl"],
      totalSteps: json["totalSteps"],
      completedSteps: json["completedSteps"],
      unlocked: json["unlocked"],
    );
  }
}
