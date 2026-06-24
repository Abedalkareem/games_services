class SavedGame {
  /// The saved game's name.
  String name;

  /// The saved game's modification date (in milliseconds). When the saved game is
  /// first created, this will be the creation date.
  int modificationDate;

  /// The device that saved the game.
  String deviceName;

  /// An optional short description of the save. Android only.
  String? description;

  /// Time played in the save. Android only.
  Duration? timePlayed;

  /// A cover image for the save (base64). Android only.
  String? coverImage;

  SavedGame(
    this.name,
    this.modificationDate,
    this.deviceName, {
    this.description,
    this.timePlayed,
    this.coverImage,
  });

  factory SavedGame.fromJson(Map json) {
    return SavedGame(
      json["name"],
      json["modificationDate"],
      json["deviceName"],
      description: json["description"],
      timePlayed: json["playedTimeMillis"] == null
          ? null
          : Duration(milliseconds: json["playedTimeMillis"]),
      coverImage: json["coverImage"],
    );
  }

  Map toJson() => {
    "name": name,
    "modificationDate": modificationDate,
    "deviceName": deviceName,
    "description": description,
    "playedTimeMillis": timePlayed?.inMilliseconds,
    "coverImage": coverImage,
  };
}

class NewSave extends SavedGame {
  NewSave() : super('', 0, '');
}
