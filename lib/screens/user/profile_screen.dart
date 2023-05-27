// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../bloc/settings/settings_cubit.dart';
import '../../bloc/settings/settings_state.dart';

import '../localizations/localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SettingsCubit settings;

  void askLogout() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).getTranslate("logout")),
        content:
            Text(AppLocalizations.of(context).getTranslate("logout_confirm")),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(AppLocalizations.of(context).getTranslate("yes")),
            onPressed: () {
              context.read<SettingsCubit>().userLogout();
              GoRouter.of(context).go('/welcome');
            },
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).getTranslate("no")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getTranslate('profile'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home'); // Anasayfaya yönlendirme
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              askLogout();
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 18.0),
              child: Icon(Iconsax.logout),
            ),
          )
        ],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (!state.userLoggedIn) {
            return Center(child: Text("Hesap oluşturun"));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).getTranslate('name'),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        state.userData[0],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).getTranslate('mail'),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        state.userData[1],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).getTranslate('token'),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        state.userData[3],
                        style: TextStyle(fontSize: 15.5),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .getTranslate('get_support'),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      ElevatedButton.icon(
                        onPressed: () {
                          GoRouter.of(context).go('/tickets');
                        },
                        icon: Icon(Iconsax.message),
                        label: Text(
                          AppLocalizations.of(context)
                              .getTranslate('get_support'),
                          style: TextStyle(fontSize: 16.0),
                        ),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
