import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:sales_quote_arnexa/models/price_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  // 🔥 Use this for real device. For emulator keep 10.0.2.2
  // static const String baseUrl = "http://10.0.2.2:5247";
  static const String baseUrl = "http://localhost:5247";


// ── Stored session ─────────────────────────────────────────
  static String? _token;
  static int? _userId;
  static String? _showroomType;
  static String? _fullName;
  static String? _role;
  static String? _username;
  static String? _pass;
  static String? _Loc_Code;

  
 Future<Map<String, dynamic>?> login(
      String UserName, String Pass, String showroomType) async {

    print("API CALL → $baseUrl/api/auth/login");

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
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
        _Loc_Code = data['data']['Loc_Code'];
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
  
   // 🔹 GET Departments
Future<List<String>> getDepartments(String model) async {
  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/pricelist/corporate?model=${Uri.encodeComponent(model)}",
    ),
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    print("RAW API: $data");

    // 🔥 SAFE mapping
    return data.map((e) {
      if (e is String) return e;
      return e["Scheme_Group"].toString();
    }).toList();
  } else {
    throw Exception("Failed to load departments");
  }
}


Future<List<String>> GetCorporateByScheme(String scheme) async {
  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/pricelist/corporates-by-scheme?schemeGroup=${Uri.encodeComponent(scheme)}",
    ),
  );

 if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    print("RAW API: $data");

    // 🔥 SAFE mapping
    return data.map((e) {
      if (e is String) return e;
      return e["CorporateName"].toString();
    }).toList();
  } else {
    throw Exception("Failed to load departments");
  }
}

Future<double> getTotalOffer(String model, String corporateName) async {
  final url =
      "$baseUrl/api/pricelist/total-offer?model=${Uri.encodeComponent(model)}&corporateName=${Uri.encodeComponent(corporateName)}";

  print("URL: $url");

  final response = await http.get(Uri.parse(url));

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0;
  } else {
    throw Exception("Failed to load total offer");
  }
}


Future<double> getInsuranceAmount(String modelWithType, String location) async {

  if (modelWithType.isEmpty || location.isEmpty) {
    throw Exception("Invalid params: model or location empty");
  }

  final url =
      "$baseUrl/api/pricelist/insurance?modelWithType=${Uri.encodeComponent(modelWithType)}&location=${Uri.encodeComponent(location)}";

  print("URL: $url");

  final response = await http.get(Uri.parse(url));

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0;
  } else {
    throw Exception("Failed to load insurance");
  }
}

Future<double> getAccessoriesAmount(String modelWithType, String location) async {

  if (modelWithType.isEmpty || location.isEmpty) {
    throw Exception("Invalid params: model or location empty");
  }

  final url =
      "$baseUrl/api/pricelist/accessories?modelWithType=${Uri.encodeComponent(modelWithType)}&location=${Uri.encodeComponent(location)}";

  print("URL: $url");

  final response = await http.get(Uri.parse(url));

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0;
  } else {
    throw Exception("Failed to load accessories");
  }
}


Future<List<PriceModel>> getAllData() async {
  final prefs = await SharedPreferences.getInstance();

  // 🔥 Yaha se loc_Code mil raha hai
  final locationCode = prefs.getString("locationCode") ?? "";

  final response = await http.get(
    Uri.parse("$baseUrl/api/pricelist/GetPriceList?locationCode=$locationCode"),
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((e) => PriceModel.fromJson(e)).toList();
  } else {
    throw Exception("Error");
  }
}

// Future<List<PriceModel>> getAllData() async {
//   final res = await http.get(Uri.parse("$baseUrl/api/pricelist/model_group"));

//   if (res.statusCode == 200) {
//     final List data = jsonDecode(res.body);
//     return data.map((e) => PriceModel.fromJson(e)).toList();
//   }

//   throw Exception("Failed");
// }


Future<List<String>> getColors(String code) async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/pricelist/colors?variantCode=${Uri.encodeComponent(code)}"),
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => e.toString()).toList();
  }

  throw Exception("Failed");
}

Future<List<String>> getFinancerNames() async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/pricelist/fiaancerName"),
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);

    return data.map<String>((e) => e['fiaancerName'].toString()).toList();
  } else {
    throw Exception("Failed to load financer names");
  }
}

  Future<bool> submitData(Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/api/pricelist/save");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
  
Future<double> getWarrantyAmount(
  String model,
  String ewType,
  String ccpType,
) async {
   
   final prefs = await SharedPreferences.getInstance();
  // 🔥 Yaha se loc_Code mil raha hai
  final locationCode = prefs.getString("locationCode") ?? "";
  

  // 🚨 Stop API call if location missing
  if (locationCode == null || locationCode.isEmpty) {
    throw Exception("Location not found. Please login again.");
  }

  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/pricelist/ext-warranty"
      "?modelWithType=$model"
      "&location=$locationCode"
      "&ewType=$ewType"
      "&ccpType=$ccpType",
    ),
  );

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0;
  } else {
    throw Exception("Failed to load warranty");
  }
}
}