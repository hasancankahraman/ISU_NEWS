// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:dio/dio.dart';

class LoginApi {
  Object error = "";
  final AppLink = "https://api.eskanist.com/public/api";
  login({required String email, required String password}) async {
    try {
      final dio = Dio();
      String endpoint = "/login";
      var params = {
        "email": email,
        "passsword": password,
      };

      var formData = FormData.fromMap(params);

      final response = await dio.post("$AppLink$endpoint", data: formData);

      if (response.statusCode == 200) {
        var token = response.data["token"];
        print(response.data);
        return token;
      } else {
        return null;
      }
    } catch (e) {
      error = e;
      return null;
    }
  }

  Future<String?> register(
      {required String email,
      required String password,
      required String name,
      required String phone,
      required String confirm_password}) async {
    try {
      final dio = Dio();
      String endpoint = "/register";

      var params = {
        "name": name,
        "email": email,
        "passsword": password,
        "confirm_password": confirm_password,
      };
      print(params);

      var formData = FormData.fromMap(params);

      final response = await dio.post(endpoint, data: formData);
      print(response);

      if (response.statusCode == 200) {
        var token = response.data["token"];
        return token;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
