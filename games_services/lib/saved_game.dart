class SavedGame {
  /// The saved game name.
  String name;

  /// The modification date, this will be also the creation date once you create the
  /// saved game for the first time. The date is in milliseconds.
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
        "deviceName": deviceName
      };
}
