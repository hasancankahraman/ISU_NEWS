// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, empty_catches, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings/settings_cubit.dart';
import 'localizations/localizations.dart';
import '../screens/storage/storage.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool loading = true;
  late SettingsCubit settings;

  loadApp() async {
    try {
      final storage = AppStorage();
      var data = await storage.readAll();

      if (data["darkMode"] == null) {
        if (ThemeMode.system == ThemeMode.dark) {
          data["darkMode"] = true;
        } else {
          data["darkMode"] = false;
        }
        // await storage.writeAppSettings(language: "", darkMode: data["darkMode"]);
      }

      if (data["language"] == null) {
        if (kIsWeb) {
          data["language"] = "tr";
          await storage.writeAppSettings(
              language: data["language"], darkMode: data["darkMode"]);
        } else {
          final String defaultLocale = Platform.localeName;
          // en_US
          // tr_TR
          var liste = defaultLocale.split('_');
          // ["en","US"]
          // ["tr", "TR"]
          var isSupported =
              AppLocalizations.delegate.isSupported(Locale(liste[0], ""));
          if (isSupported) {
            data["language"] = liste[0];
            await storage.writeAppSettings(
                language: data["language"], darkMode: data["darkMode"]);
          } else {
            data["language"] = "en";
            await storage.writeAppSettings(
                language: data["language"], darkMode: data["darkMode"]);
          }
        }
      }

      if (data["loggedIn"] == null) {
        data["loggedIn"] = false;
        data["userData"] = [];
        await storage.writeUserData(isLoggedIn: false, userData: []);
      }

      settings.changeThemeMode(data["darkMode"]);
      settings.changeLanguage(data["language"]);
      if (data["loggedIn"]) {
        settings.userLogin(data["userData"]);
      } else {
        settings.userLogout();
      }

      setState(() {
        loading = false;
      });

      if (data["loggedIn"]) {
        GoRouter.of(context).replace("/home");
      } else {
        GoRouter.of(context).replace("/welcome");
      }
    } catch (e) {}
  }

  @override
  void initState() {
    settings = context.read<SettingsCubit>();
    super.initState();
    loadApp();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: loading
                ? Center(child: const CircularProgressIndicator())
                : const Text('Loaded')));
  }
}
