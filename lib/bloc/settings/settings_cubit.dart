// ignore_for_file: unused_import, duplicate_import

import '../../screens/storage/storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(super.initialState);

  changeLanguage(String lang) async {
    final newState = SettingsState(
      language: lang,
      darkMode: state.darkMode,
      userLoggedIn: state.userLoggedIn,
      userData: state.userData,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeAppSettings(
      darkMode: state.darkMode,
      language: lang,
    );
  }

  changeThemeMode(bool darkMode) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: darkMode,
      userLoggedIn: state.userLoggedIn,
      userData: state.userData,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeAppSettings(
      darkMode: darkMode,
      language: state.language,
    );
  }

  userLogin(List<String> userData) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userLoggedIn: true,
      userData: userData,
    );

    emit(newState);
    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: true, userData: userData);
  }

  userLogout() async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userLoggedIn: false,
      userData: const [],
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: false, userData: []);
  }

  userUpdate(List<String> userData) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userData: userData,
      userLoggedIn: true,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: true, userData: userData);
  }
}
