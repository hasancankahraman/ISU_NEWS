import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  Future<Map<String, dynamic>> readAll() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    var loggedIn = storage.getBool('isLoggedIn');
    var userData = storage.getStringList('userData');
    var language = storage.getString('language');
    var darkMode = storage.getBool('darkMode');

    return {
      "loggedIn": loggedIn,
      "userData": userData,
      "language": language,
      "darkMode": darkMode,
    };
  }

  readUserData() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    var loggedIn = storage.getBool('isLoggedIn');
    var userData = storage.getStringList('userData');

    return {
      "loggedIn": loggedIn,
      "userData": userData,
    };
  }

  readAppSettings() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    var language = storage.getString('language');
    var darkMode = storage.getBool('darkMode');

    return {
      "language": language,
      "darkMode": darkMode,
    };
  }

  writeUserData(
      {required bool isLoggedIn, required List<String> userData}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setBool('isLoggedIn', isLoggedIn);
    storage.setStringList('userData', userData);
  }

  writeAppSettings({required String language, required bool darkMode}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString('language', language);
    storage.setBool('darkMode', darkMode);
  }

  readBalances() async {}

  writeBalances() async {}
}
