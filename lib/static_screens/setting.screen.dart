// ignore_for_file: prefer_const_literals_to_create_immutables, unused_import, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';
import '../screens/localizations/localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SettingsCubit settings;
  String language = "en";
  bool darkMode = false;

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
            AppLocalizations.of(context).getTranslate('language_selection')),
        message: Text(
            AppLocalizations.of(context).getTranslate('language_selection2')),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              settings.changeLanguage("tr");
              Navigator.pop(context);
            },
            child: const Text('Turkce'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.changeLanguage("en");
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).getTranslate('cancel')),
          ),
        ],
      ),
    );
  }
//1:25
  // loadSettings() async {
  //   SharedPreferences memory = await SharedPreferences.getInstance();
  //   var d = memory.getBool('darkMode');
  //   var l = memory.getString('language');

  //   if (d == null) {
  //     changeThemeMode(false);
  //   } else {
  //     darkMode = d;
  //   }

  //   if (l == null) {
  //     changeLanguage("en");
  //   } else {
  //     language = l;
  //   }

  //   setState(() {});
  // }

  @override
  void initState() {
    settings = context.read<SettingsCubit>();
    //loadSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getTranslate('settings'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home'); // Anasayfaya yönlendirme
          },
        ),
      ),
      body:
          BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            InkWell(
                onTap: () => _showActionSheet(context),
                child: Text(
                    '${AppLocalizations.of(context).getTranslate('language')} : ${state.language}')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${AppLocalizations.of(context).getTranslate('darkMode')}:'),
                Switch(
                    value: state.darkMode,
                    onChanged: (value) {
                      settings.changeThemeMode(value);
                    })
              ],
            ),
          ]),
        );
      }),
    );
  }
}
