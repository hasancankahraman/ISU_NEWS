class SettingsState {
  String language;
  bool darkMode;
  bool userLoggedIn;
  List<String> userData;

  SettingsState({
    this.language = "en",
    this.darkMode = false,
    this.userLoggedIn = false,
    this.userData = const [],
  });
}
