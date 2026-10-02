import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // static const String baseUrl = 'https://premerp.in/salesquote/api';
  // static const String baseUrl = 'https://192.168.2.247:4005/api';
  static const String baseUrl = "http://103.168.210.85:4005/api";

  

Future<Map<String, dynamic>?> login(
  String userId,
  String password,
) async {
  try {
    final url = Uri.parse(
      "$baseUrl/login",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "userId": userId.trim(),
        "password": password.trim(),
      }),
    ).timeout(
      const Duration(seconds: 15),
    );

    print("STATUS CODE => ${response.statusCode}");
    print("LOGIN RESPONSE => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Login Failed: ${response.statusCode}",
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if (data["success"] != true) {
      throw Exception(
        data["message"] ??
            "Invalid User ID or Password",
      );
    }

    // ==========================================
    // SAVE LOGIN DATA
    // ==========================================

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "isLogin",
      true,
    );

    await prefs.setString(
      "userName",
      data["userName"]?.toString() ?? "",
    );

    // Aapke existing code me UserName bhi use ho raha hai
    await prefs.setString(
      "UserName",
      data["userName"]?.toString() ?? "",
    );

    await prefs.setString(
      "userId",
      data["userId"]?.toString() ?? "",
    );

    await prefs.setString(
      "userType",
      data["userType"]?.toString() ?? "",
    );

    await prefs.setString(
      "showroomType",
      data["showroomType"]?.toString() ?? "",
    );

    await prefs.setString(
      "locationCode",
      data["locationCode"]?.toString() ?? "",
    );

    await prefs.setString(
      "locationName",
      data["locationName"]?.toString() ?? "",
    );

    return data;

  } on TimeoutException {
    throw Exception(
      "Server connection timeout.",
    );
  } on SocketException {
    throw Exception(
      "Cannot connect to server.",
    );
  } catch (e) {
    print("LOGIN ERROR => $e");
    rethrow;
  }
}


  static Future<void> logout() async {
  // Clear saved login/session here
}
}