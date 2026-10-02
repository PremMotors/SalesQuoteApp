import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotationApiService  {
  // ============================================================
  // BASE URL
  // ============================================================
  //
  // Postman:
  // {{baseUrl}}/api/quotation/models
  //
  // Agar Postman ka {{baseUrl}}:
  // https://premerp.in/dvms
  // hai to yahi rakhein.
  //
  // ============================================================

  // static const String baseUrl = "https://premerp.in/salesquote";
  static const String baseUrl = "http://103.168.210.85:4005/api";

  // ============================================================
  // GET REQUEST
  // ============================================================

  static Future<dynamic> getRequest(
    String endpoint,
  ) async {
    final uri = Uri.parse(
      "$baseUrl$endpoint",
    );

    print("");
    print("======================================");
    print("GET");
    print(uri);
    print("======================================");

    final response = await http.get(
      uri,
      headers: const {
        "Accept": "application/json",
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      "GET ${response.statusCode}: ${response.body}",
    );
  }

  // ============================================================
  // POST REQUEST
  // ============================================================

  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(
      "$baseUrl$endpoint",
    );

    print("");
    print("======================================");
    print("POST");
    print(uri);
    print("REQUEST BODY");
    print(
      const JsonEncoder.withIndent("  ")
          .convert(body),
    );
    print("======================================");

    final response = await http.post(
      uri,
      headers: const {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {
          "success": true,
        };
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      "POST ${response.statusCode}: ${response.body}",
    );
  }

  // ============================================================
  // MODELS
  // ============================================================

  static Future<dynamic> getModels(
    String locationCode,
  ) {
    return getRequest(
      "/api/quotation/models"
      "?location=${Uri.encodeQueryComponent(locationCode)}",
    );
  }

  // ============================================================
  // VARIANTS
  // ============================================================

  static Future<dynamic> getVariants({
    required String locationCode,
    required String model,
  }) {
    return getRequest(
      "/api/quotation/variants"
      "?location=${Uri.encodeQueryComponent(locationCode)}"
      "&model=${Uri.encodeQueryComponent(model)}",
    );
  }

  // ============================================================
  // COLORS
  // ============================================================

  static Future<dynamic> getColors({
    required String locationCode,
    required String variantCode,
  }) {
    return getRequest(
      "/api/quotation/colors"
      "?location=${Uri.encodeQueryComponent(locationCode)}"
      "&variantCode=${Uri.encodeQueryComponent(variantCode)}",
    );
  }

  // ============================================================
  // FINANCIERS
  // ============================================================

  static Future<dynamic> getFinanciers() {
    return getRequest(
      "/api/financiers",
    );
  }

  // ============================================================
  // OFFERS
  // ============================================================

  static Future<dynamic> getOffers({
    required String locationCode,
    required String model,
    required String variantCode,
  }) {
    return getRequest(
      "/api/quotation/offers"
      "?location=${Uri.encodeQueryComponent(locationCode)}"
      "&model=${Uri.encodeQueryComponent(model)}"
      "&variantCode=${Uri.encodeQueryComponent(variantCode)}",
    );
  }

  // ============================================================
  // PRICE ADDON
  // ============================================================

  static Future<dynamic> getPriceAddon({
    required String variantCode,
    required String column,
    required String locationCode,
    required String model,
  }) {
    return getRequest(
      "/api/price/addon"
      "?variantCode=${Uri.encodeQueryComponent(variantCode)}"
      "&column=${Uri.encodeQueryComponent(column)}"
      "&location=${Uri.encodeQueryComponent(locationCode)}"
      "&model=${Uri.encodeQueryComponent(model)}",
    );
  }

  // ============================================================
  // CORPORATE LIST
  // ============================================================

  static Future<dynamic> getCorporateList() {
    return getRequest(
      "/api/corporate/all",
    );
  }

  // ============================================================
  // CORPORATE OFFER AMOUNT
  // ============================================================

  static Future<dynamic> getCorporateOfferAmount({
    required String modelGroup,
    required String corporateName,
    required String invoiceDate,
    required String locationCode,
  }) {
    return getRequest(
      "/api/corporate/offerAmount"
      "?modelGroup=${Uri.encodeQueryComponent(modelGroup)}"
      "&corporateName=${Uri.encodeQueryComponent(corporateName)}"
      "&invoiceDate=${Uri.encodeQueryComponent(invoiceDate)}"
      "&location=${Uri.encodeQueryComponent(locationCode)}",
    );
  }

  // ============================================================
  // SAVE QUOTATION
  // ============================================================

  static Future<dynamic> saveQuotation(
    Map<String, dynamic> body,
  ) {
    return postRequest(
      "/api/quotations",
      body,
    );
  }


  static Future<dynamic> sendQuotationWhatsApp(
  dynamic custId,
) {
  final id = custId.toString().trim();

  if (id.isEmpty) {
    throw Exception("custId is required for WhatsApp");
  }

  return postRequest(
    "/api/quotations/${Uri.encodeComponent(id)}/send-whatsapp",
    <String, dynamic>{},
  );
}
}