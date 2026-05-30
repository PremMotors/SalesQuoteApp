import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────
// API Base URL — auto-selected by platform
// ─────────────────────────────────────────────────────────────

String get kBaseUrl {
  if (kIsWeb) return "http://10.0.2.2:5247"; // Web (use localhost)
  return "http://10.0.2.2:5247";
}

// String get kBaseUrl {
//   if (kIsWeb) {
//     return "http://localhost:5247"; // Chrome
//   } else {
//     return "http://10.0.2.2:5247"; // Emulator
//   }
// }
class ApiService {

  // ── Stored session ─────────────────────────────────────────
  static String? _token;
  static int? _userId;
  static String? _showroomType;
  static String? _fullName;
  static String? _role;
  static String? _username;
  static String? _pass;


  // ── Public getters ─────────────────────────────────────────
  static String? get currentUserName => _fullName;
  static String? get currentUsername => _username;
  static String? get currentPass => _pass;
  static String? get currentRole => _role;
  static String? get currentShowroomType => _showroomType;
  static int? get currentUserId => _userId;
  static bool get isLoggedIn => _token != null;

  static String get userInitials {
    if (_fullName == null || _fullName!.isEmpty) return '?';
    final parts = _fullName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // ── Headers ────────────────────────────────────────────────
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ───────────────── AUTH ─────────────────

  static Future<Map<String, dynamic>> login(
      String UserName, String Pass, String showroomType) async {

    print("API CALL → $kBaseUrl/api/auth/login");

    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserName': UserName,
          'Pass': Pass,
          'showroomType': showroomType,
        }),
      );

      print("STATUS CODE → ${res.statusCode}");
      print("RESPONSE → ${res.body}");

      if (res.statusCode != 200) {
        return {
          "success": false,
          "message": res.body
        };
      }

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        _token = data['data']['token'];
        _userId = data['data']['userId'];
        _showroomType = data['data']['showroomType'];
        _fullName = data['data']['fullName'];
        _role = data['data']['role'];
        _username = data['data']['username'];
        _pass = data['data']['password'];
      }

      return data;

    } catch (e) {
      print("API ERROR → $e");
      return {
        "success": false,
        "message": "Cannot connect to server"
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {

    final res = await http.post(
      Uri.parse('$kBaseUrl/api/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        'userId': _userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    return jsonDecode(res.body);
  }

  // ───────────────── DASHBOARD ─────────────────

  static Future<Map<String, dynamic>> getDashboard() async {

    final res = await http.get(
      Uri.parse(
          '$kBaseUrl/api/dashboard?showroomType=${_showroomType ?? "Arena"}'),
      headers: _headers,
    );

    return jsonDecode(res.body);
  }

  // ───────────────── CUSTOMERS ─────────────────

  static Future<Map<String, dynamic>> getCustomers({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri =
    Uri.parse('$kBaseUrl/api/customers').replace(queryParameters: params);

    final res = await http.get(uri, headers: _headers);

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> searchCustomerByMobile(
      String mobile) async {

    final res = await http.get(
      Uri.parse('$kBaseUrl/api/customers/search?mobile=$mobile'),
      headers: _headers,
    );

    return jsonDecode(res.body);
  }


  static Future<Map<String, dynamic>> createCustomer(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/api/customers'),
      headers: _headers,
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateCustomer(
      int id, Map<String, dynamic> data) async {

    final res = await http.put(
      Uri.parse('$kBaseUrl/api/customers/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  // ───────────────── VEHICLES ─────────────────

  static Future<Map<String, dynamic>> getVehicles(
      {String? showroomType}) async {

    final type = showroomType ?? _showroomType ?? 'Arena';

    final res = await http.get(
      Uri.parse('$kBaseUrl/api/vehicles?showroomType=$type'),
      headers: _headers,
    );

    return jsonDecode(res.body);
  }

  // ───────────────── QUOTES ─────────────────

  static Future<Map<String, dynamic>> getQuotes({
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {

    final params = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (_showroomType != null) 'showroomType': _showroomType!,
      if (status != null && status != 'All') 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri =
    Uri.parse('$kBaseUrl/api/quotes').replace(queryParameters: params);

    final res = await http.get(uri, headers: _headers);

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getQuoteById(int id) async {

    final res = await http.get(
      Uri.parse('$kBaseUrl/api/quotes/$id'),
      headers: _headers,
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createQuote(
      Map<String, dynamic> data) async {

    final res = await http.post(
      Uri.parse('$kBaseUrl/api/quotes'),
      headers: _headers,
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateQuote(
      int id, Map<String, dynamic> data) async {

    final res = await http.put(
      Uri.parse('$kBaseUrl/api/quotes/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateQuoteStatus(
      int id, String status,
      {String? remarks}) async {

    final res = await http.patch(
      Uri.parse('$kBaseUrl/api/quotes/$id/status'),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        if (remarks != null) 'remarks': remarks
      }),
    );

    return jsonDecode(res.body);
  }

  // ───────────────── PROFILE STATS ─────────────────

  static Future<Map<String, dynamic>> getMyStats() async {

    final result = await getQuotes(pageSize: 1000);

    if (result['success'] != true) {
      return {'total': 0, 'converted': 0, 'rate': '0%'};
    }

    final quotes = (result['data']?['data'] as List?) ?? [];

    final total = quotes.length;

    final converted =
        quotes.where((q) => q['status'] == 'Converted').length;

    final rate =
    total > 0 ? (converted / total * 100).toStringAsFixed(1) : '0.0';

    return {
      'total': total,
      'converted': converted,
      'rate': '$rate%'
    };
  }
}