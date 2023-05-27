// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, unused_import, unnecessary_import, unused_local_variable
//Önemli silme
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isu_haber/screens/initialScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routers/routers.dart';
import 'themes/themes.dart';

// ayarlar sayfası
import 'package:isu_haber/static_screens/setting.screen.dart';

//Önemli silme
import 'bloc/settings/settings_cubit.dart';
import 'bloc/settings/settings_state.dart';
import 'screens/localizations/localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String language = "en";
  bool darkMode = false;

  changeLanguage(String lang) async {
    SharedPreferences memory = await SharedPreferences.getInstance();
    await memory.setString("language", lang);

    setState(() {
      language = lang;
    });
  }

  changeThemeMode(bool isDark) async {
    SharedPreferences memory = await SharedPreferences.getInstance();
    await memory.setBool("darkMode", isDark);

    setState(() {
      darkMode = isDark;
    });
  }

  loadSettings() async {
    SharedPreferences memory = await SharedPreferences.getInstance();
    var d = memory.getBool('darkMode');
    var l = memory.getString('language');

    if (d == null) {
      if (ThemeMode.system == ThemeMode.dark) {
        changeThemeMode(true);
      } else {
        changeThemeMode(false);
      }
    } else {
      darkMode = d;
    }

    if (l == null) {
      if (kIsWeb) {
        changeLanguage('tr');
      } else {
        final String defaultLocale = Platform.localeName;
        var liste = defaultLocale.split('_');
        var isSupported =
            AppLocalizations.delegate.isSupported(Locale(liste[0], ""));
        if (isSupported) {
          changeLanguage(liste[0]);
        } else {
          changeLanguage('tr');
        }
      }
    } else {
      language = l;
    }

    setState(() {});
  }

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SettingsCubit(SettingsState()),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'İSU HABER',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale("en", ""),
              Locale("tr", ""),
            ],
            locale: Locale(state.language, ""),
            themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            routerConfig: routes,
          );
        },
      ),
    );
  }
}
