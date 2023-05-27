// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_import, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../api/login_api.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../localizations/localizations.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  late SettingsCubit settings;
  String name = "";
  String email = "";
  String password = "";
  String confirm_password = "";
  List<String> warnings = [];
  bool loading = false;

  showWarnings() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          AppLocalizations.of(context).getTranslate('warning'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).getTranslate('close'),
            ),
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: warnings
              .map(
                (e) => Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context).getTranslate(e),
                    textAlign: TextAlign.start,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> register() async {
    setState(
      () {
        loading = true;
      },
    );

    List<String> msgs = [];
    if (email.trim().isEmpty) {
      msgs.add("mail_required");
    }
    if (password.trim().length < 6) {
      msgs.add("passwd_length");
    }

    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

    if (!emailValid) {
      msgs.add("email_format");
    }

    if (name.trim().isEmpty) {
      msgs.add("name_required");
    }

    if (msgs.isEmpty) {
      final registerResult =
          await performRegister(email, password, name, confirm_password);

      if (registerResult != null) {
        final data = [
          registerResult["email"],
          registerResult["name"],
          registerResult["token"]
        ];
        final dataList = data.map((value) => value.toString()).toList();
        settings.userUpdate(dataList);
        print('object');
      } else {
        warnings = [
          AppLocalizations.of(context).getTranslate('register_failed')
        ];
        showWarnings();
      }
    } else {
      showWarnings();
    }
    setState(() {
      warnings = msgs;
      loading = false;
    });
  }

  Future<Map<String, dynamic>?> performRegister(String email, String password,
      String name, String confirm_password) async {
    final url = Uri.parse('https://api.qline.app/api/register');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
        'name': name,
        'confirm_password': confirm_password
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final success = responseBody['success'] as bool;
      if (success) {
        return responseBody;
      } else {
        final msg = responseBody['msg'] as String;
        print('Login failed: $msg');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    settings = context.read<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).go('/welcome');
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        height: MediaQuery.of(context).size.height - 50,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).getTranslate('sign_up'),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)
                      .getTranslate('create_an_account'),
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).getTranslate('username'),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          name = value;
                        },
                      );
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).getTranslate('mail'),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          email = value;
                        },
                      );
                    },
                  ),
                  TextField(
                    obscureText: _obscureText1,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).getTranslate('passwd'),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText1
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                            () {
                              _obscureText1 = !_obscureText1;
                            },
                          );
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          password = value;
                        },
                      );
                    },
                  ),
                  TextField(
                    obscureText: _obscureText2,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .getTranslate('confirm_passwd'),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText2
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                            () {
                              _obscureText2 = !_obscureText2;
                            },
                          );
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          confirm_password = value;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 3, left: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                  top: BorderSide(color: Colors.black),
                  left: BorderSide(color: Colors.black),
                  right: BorderSide(color: Colors.black),
                ),
              ),
              child: MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () => register(),
                color: Color(0xff0095FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  AppLocalizations.of(context).getTranslate('sign_up'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).getTranslate('already_account'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).getTranslate('login'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget inputFile({label, obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
      SizedBox(
        height: 10,
      )
    ],
  );
}
