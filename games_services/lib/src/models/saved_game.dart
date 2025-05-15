class SavedGame {
  /// The saved game's name.
  String name;

  /// The saved game's modification date (in milliseconds). When the saved game is
  /// first created, this will be the creation date.
  int modificationDate;

  /// The device that saved the game.
  String deviceName;

  SavedGame(this.name, this.modificationDate, this.deviceName);

  factory SavedGame.fromJson(Map json) {
    return SavedGame(
        json["name"], json["modificationDate"], json["deviceName"]);
  }

  Map toJson() => {
        "name": name,
        "modificationDate": modificationDate,
        "deviceName": deviceName,
      };
}
