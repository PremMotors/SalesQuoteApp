import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quotation_api_service.dart';


class AddQuotationPage extends StatefulWidget {
  const AddQuotationPage({
    super.key,
  });

  @override
  State<AddQuotationPage> createState() =>
      _AddQuotationPageState();
}

class _AddQuotationPageState
    extends State<AddQuotationPage> {
  // ============================================================
  // FORM KEY
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CUSTOMER CONTROLLERS
  // ============================================================

  final TextEditingController customerNameController =
      TextEditingController();

  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController professionController =
      TextEditingController();

  // ============================================================
  // PRICE CONTROLLERS
  // ============================================================

  final TextEditingController exShowroomController =
      TextEditingController();

  final TextEditingController insuranceController =
      TextEditingController();

  final TextEditingController rtoController =
      TextEditingController();

  final TextEditingController discountController =
      TextEditingController();

  final TextEditingController accessoriesController =
      TextEditingController();

  final TextEditingController onRoadController =
      TextEditingController();

  final TextEditingController costOfVehicleController =
      TextEditingController();

  final TextEditingController tcsAmountController =
      TextEditingController();

  final TextEditingController invoiceAmountController =
      TextEditingController();

  final TextEditingController extendedWarrantyAmountController =
      TextEditingController();

  final TextEditingController ccpAmountController =
      TextEditingController();

  final TextEditingController msgaAmountController =
      TextEditingController();

  final TextEditingController fastagAmountController =
      TextEditingController();

  final TextEditingController otherChargeController =
      TextEditingController();

  final TextEditingController otherChargeAmountController =
      TextEditingController();

  // ============================================================
  // FINANCE CONTROLLERS
  // ============================================================

  final TextEditingController financeOnController =
      TextEditingController();

  final TextEditingController tenureController =
      TextEditingController();

  final TextEditingController roiController =
      TextEditingController();

  final TextEditingController loanPerController =
      TextEditingController();

  final TextEditingController loanAmountController =
      TextEditingController();

  final TextEditingController emiController =
      TextEditingController();

  // ============================================================
  // LOGIN DATA
  // ============================================================

  String userId = "";
  String locationCode = "";
  String showroomType = "";
  String locationName = "";

  // ============================================================
  // CUSTOMER
  // ============================================================

  String customerType = "Individual";

  // ============================================================
  // PAYMENT
  // ============================================================

  String paymentType = "Cash";

  // ============================================================
  // MODEL
  // ============================================================

  List<String> models = [];

  String selectedModel = "";

  // ============================================================
  // VARIANT
  // ============================================================

  List<Map<String, dynamic>> variants = [];

  String selectedVariant = "";

  String selectedVariantCode = "";

  // ============================================================
  // COLOUR
  // ============================================================

  List<Map<String, dynamic>> colors = [];

  String selectedColour = "";

  // ============================================================
  // INSURANCE
  // ============================================================

  String selectedInsurance = "";

  // ============================================================
  // RTO
  // ============================================================

  String selectedRto = "";

  String selectedTcsRate = "No";
  String selectedExtendedWarrantyType = "";
  String selectedCcpType = "";
  String selectedMsgaType = "MSGA / GNA";
  String selectedFastag = "";

  // ============================================================
  // FINANCIERS
  // ============================================================

  List<Map<String, dynamic>> financiers = [];

  String selectedFinancier = "CASH";

  // ============================================================
  // OFFERS
  // ============================================================

  List<Map<String, dynamic>> offers = [];

  double totalOfferValue = 0;

  // ============================================================
  // CORPORATE
  // ============================================================

  List<Map<String, dynamic>> corporateList = [];

  String selectedCorporate = "";

  String corporateCode = "";

  String corporateOfferName = "";

  double corporateAmount = 0;

  // ============================================================
  // LOADING
  // ============================================================

  bool loadingModels = false;

  bool loadingVariants = false;

  bool loadingColors = false;

  bool loadingOffers = false;

  bool loadingFinanciers = false;

  bool loadingCorporate = false;

  bool loadingCorporateOffer = false;

  bool savingQuotation = false;

  bool modelsLoaded = false;
  bool variantsLoaded = false;
  bool colorsLoaded = false;
  bool offersLoaded = false;
  bool financiersLoaded = false;
  bool corporateLoaded = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadInitialData();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    customerNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    cityController.dispose();
    professionController.dispose();

    exShowroomController.dispose();
    insuranceController.dispose();
    rtoController.dispose();
    discountController.dispose();
    accessoriesController.dispose();
    onRoadController.dispose();
    costOfVehicleController.dispose();
    tcsAmountController.dispose();
    invoiceAmountController.dispose();
    extendedWarrantyAmountController.dispose();
    ccpAmountController.dispose();
    msgaAmountController.dispose();
    fastagAmountController.dispose();
    otherChargeController.dispose();
    otherChargeAmountController.dispose();

    financeOnController.dispose();
    tenureController.dispose();
    roiController.dispose();
    loanPerController.dispose();
    loanAmountController.dispose();
    emiController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD LOGIN DATA
  // ============================================================

  Future<void> loadInitialData() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      userId =
          prefs.getString("userId") ?? "";

      locationCode =
          prefs.getString("locationCode") ?? "";

      showroomType =
          prefs.getString("showroomType") ?? "";

      locationName =
          prefs.getString("locationName") ?? "";

      debugPrint("================================");
      debugPrint("USER ID       : $userId");
      debugPrint("LOCATION CODE : $locationCode");
      debugPrint("SHOWROOM TYPE : $showroomType");
      debugPrint("LOCATION NAME : $locationName");
      debugPrint("================================");

      if (locationCode.isEmpty) {
        showMessage(
          "Location Code not found. Please login again.",
          isError: true,
        );

        return;
      }

      // Only load Models when page opens.
      // Other APIs are loaded when they are needed.
      await loadModels();
    } catch (e) {
      debugPrint(
        "INITIAL DATA ERROR: $e",
      );

      showMessage(
        "Unable to load quotation data.",
        isError: true,
      );
    }
  }

  // ============================================================
  // MODELS
  // ============================================================

  Future<void> loadModels() async {
    if (!mounted) return;

    setState(() {
      loadingModels = true;
      modelsLoaded = false;
      models = [];
    });

    try {
      final response = await QuotationApiService.getModels(
        locationCode,
      );

      debugPrint("MODELS RESPONSE = $response");

      final List data = extractList(
        response,
        [
          "models",
          "Models",
          "data",
        ],
      );

      final List<String> result = [];

      for (final item in data) {
        if (item is Map) {
          final Map<String, dynamic> map =
              Map<String, dynamic>.from(item);

          final value = firstString(
            map,
            [
              "Model_Group",
              "ModelGroup",
              "modelGroup",
              "Model",
              "model",
            ],
          );

          if (value.isNotEmpty && !result.contains(value)) {
            result.add(value);
          }
        } else if (item != null) {
          final value = item.toString().trim();
          if (value.isNotEmpty && !result.contains(value)) {
            result.add(value);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        models = result;
        modelsLoaded = true;
      });

      if (result.isEmpty) {
        showMessage("Models: Data Not Found");
      }
    } catch (e) {
      debugPrint("MODELS ERROR = $e");

      if (mounted) {
        setState(() {
          models = [];
          modelsLoaded = true;
        });
        showMessage("Models: Data Not Found", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingModels = false;
        });
      }
    }
  }

  // ============================================================
  // VARIANTS
  // ============================================================

  Future<void> loadVariants(
    String model,
  ) async {
    if (!mounted) return;

    setState(() {
      loadingVariants = true;
      variantsLoaded = false;

      variants = [];

      colors = [];

      offers = [];

      selectedVariant = "";

      selectedVariantCode = "";

      selectedColour = "";

      totalOfferValue = 0;
    });

    try {
      final response =
          await QuotationApiService.getVariants(
        locationCode: locationCode,
        model: model,
      );

      debugPrint(
        "VARIANTS RESPONSE = $response",
      );

      final List data =
          extractList(
        response,
        [
          "variants",
          "Variants",
          "data",
        ],
      );

      final List<Map<String, dynamic>> result = [];
      final Set<String> seenVariantKeys = {};

      for (final item in data) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final code = getVariantCode(map);
          final name = getVariantDescription(map);

          // API can return duplicate variant rows. Keep only one
          // entry for each Variant Code + Variant Description.
          final key = '${code.trim()}|${name.trim()}';
          if (code.isNotEmpty && name.isNotEmpty && seenVariantKeys.add(key)) {
            result.add(map);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        variants = result;
        variantsLoaded = true;
      });

      if (result.isEmpty) {
        showMessage("Variants: Data Not Found");
      }
    } catch (e) {
      debugPrint(
        "VARIANTS ERROR = $e",
      );

      if (mounted) {
        setState(() {
          variants = [];
          variantsLoaded = true;
        });
        showMessage("Variants: Data Not Found", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingVariants = false;
        });
      }
    }
  }

  // ============================================================
  // COLORS
  // ============================================================

  Future<void> loadColors() async {
    if (selectedVariantCode.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      loadingColors = true;
      colorsLoaded = false;
      colors = [];
      selectedColour = "";
      exShowroomController.clear();
    });

    try {
      final response = await QuotationApiService.getColors(
        locationCode: locationCode,
        variantCode: selectedVariantCode,
      );

      debugPrint("========================================");
      debugPrint("COLORS RESPONSE = $response");
      debugPrint("========================================");

      final List data = extractList(
        response,
        [
          "colors",
          "Colors",
          "data",
        ],
      );

      final List<Map<String, dynamic>> result = [];
      final Set<String> seen = {};

      for (final item in data) {
        if (item is! Map) continue;

        final map = Map<String, dynamic>.from(item);
        final colorName = getColorName(map);
        final exShowroom = getColorExShowroom(map);

        debugPrint(
          "COLOR = $colorName | EX-SHOWROOM = $exShowroom",
        );

        if (colorName.isEmpty) continue;

        // API may return duplicate color rows.
        // Keep one row for Color + Ex_Showroom combination.
        final key =
            '${colorName.trim().toUpperCase()}|${exShowroom.toStringAsFixed(2)}';

        if (seen.add(key)) {
          result.add(map);
        }
      }

      if (!mounted) return;

      setState(() {
        colors = result;
        colorsLoaded = true;
      });

      debugPrint("TOTAL COLORS = ${result.length}");

      if (result.isEmpty) {
        showMessage("Colours: Data Not Found");
      }
    } catch (e) {
      debugPrint("COLORS ERROR = $e");

      if (mounted) {
        setState(() {
          colors = [];
          colorsLoaded = true;
          exShowroomController.clear();
        });

        showMessage(
          "Colours: Data Not Found",
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingColors = false;
        });
      }
    }
  }


  // ============================================================
  // OFFERS
  // ============================================================

  Future<void> loadOffers() async {
    if (selectedModel.isEmpty ||
        selectedVariantCode.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      loadingOffers = true;
      offersLoaded = false;

      offers = [];

      totalOfferValue = 0;
    });

    try {
      final response =
          await QuotationApiService.getOffers(
        locationCode: locationCode,
        model: selectedModel,
        variantCode: selectedVariantCode,
      );

      debugPrint(
        "OFFERS RESPONSE = $response",
      );

      final List data =
          extractList(
        response,
        [
          "offers",
          "Offers",
          "data",
        ],
      );

      final List<Map<String, dynamic>>
          result = [];

      double total = 0;

      for (final item in data) {
        if (item is Map) {
          final map =
              Map<String, dynamic>.from(item);

          result.add(map);

          total += numberValue(
            map["value"] ??
                map["Value"] ??
                map["amount"] ??
                map["Amount"],
          );
        }
      }

      if (!mounted) return;

      setState(() {
        offers = result;
        totalOfferValue = total;
        offersLoaded = true;
      });

      if (result.isEmpty) {
        showMessage("Offers: Data Not Found");
      }
    } catch (e) {
      debugPrint(
        "OFFERS ERROR = $e",
      );

      if (mounted) {
        setState(() {
          offers = [];
          totalOfferValue = 0;
          offersLoaded = true;
        });
        showMessage("Offers: Data Not Found", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingOffers = false;
        });
      }
    }
  }

  // ============================================================
  // FINANCIERS
  // ============================================================

  Future<void> loadFinanciers() async {
    if (!mounted) return;

    setState(() {
      loadingFinanciers = true;
      financiersLoaded = false;
      financiers = [];
    });

    try {
      final response =
          await QuotationApiService
              .getFinanciers();

      debugPrint(
        "FINANCIERS RESPONSE = $response",
      );

      final List data =
          extractList(
        response,
        [
          "financiers",
          "Financiers",
          "data",
        ],
      );

      final List<Map<String, dynamic>> result = [];
      final Set<String> seenVariantKeys = {};

      for (final item in data) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final code = getVariantCode(map);
          final name = getVariantDescription(map);

          // API can return duplicate variant rows. Keep only one
          // entry for each Variant Code + Variant Description.
          final key = '${code.trim()}|${name.trim()}';
          if (code.isNotEmpty && name.isNotEmpty && seenVariantKeys.add(key)) {
            result.add(map);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        financiers = result;
        financiersLoaded = true;
      });

      if (result.isEmpty) {
        showMessage("Financiers: Data Not Found");
      }
    } catch (e) {
      debugPrint("FINANCIERS ERROR = $e");

      if (mounted) {
        setState(() {
          financiers = [];
          financiersLoaded = true;
        });
        showMessage("Financiers: Data Not Found", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingFinanciers = false;
        });
      }
    }
  }

  // ============================================================
  // CORPORATE
  // ============================================================

  Future<void> loadCorporate() async {
    if (!mounted) return;

    setState(() {
      loadingCorporate = true;
      corporateLoaded = false;
      corporateList = [];
    });

    try {
      final response =
          await QuotationApiService
              .getCorporateList();

      debugPrint(
        "CORPORATE RESPONSE = $response",
      );

      final List data =
          extractList(
        response,
        [
          "corporates",
          "corporate",
          "Corporate",
          "data",
        ],
      );

      final List<Map<String, dynamic>> result = [];
      final Set<String> seenVariantKeys = {};

      for (final item in data) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final code = getVariantCode(map);
          final name = getVariantDescription(map);

          // API can return duplicate variant rows. Keep only one
          // entry for each Variant Code + Variant Description.
          final key = '${code.trim()}|${name.trim()}';
          if (code.isNotEmpty && name.isNotEmpty && seenVariantKeys.add(key)) {
            result.add(map);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        corporateList = result;
        corporateLoaded = true;
      });

      if (result.isEmpty) {
        showMessage("Corporate: Data Not Found");
      }
    } catch (e) {
      debugPrint("CORPORATE ERROR = $e");

      if (mounted) {
        setState(() {
          corporateList = [];
          corporateLoaded = true;
        });
        showMessage("Corporate: Data Not Found", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingCorporate = false;
        });
      }
    }
  }

  // ============================================================
  // CORPORATE OFFER
  // ============================================================

  Future<void> loadCorporateOffer() async {
    if (selectedModel.isEmpty) {
      showMessage(
        "Please select Model.",
        isError: true,
      );

      return;
    }

    if (selectedCorporate.isEmpty) {
      showMessage(
        "Please select Corporate.",
        isError: true,
      );

      return;
    }

    setState(() {
      loadingCorporateOffer = true;
    });

    try {
      final now = DateTime.now();

      final invoiceDate =
          "${now.year}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}";

      final response =
          await QuotationApiService
              .getCorporateOfferAmount(
        modelGroup: selectedModel,
        corporateName:
            selectedCorporate,
        invoiceDate: invoiceDate,
        locationCode: locationCode,
      );

      debugPrint(
        "CORPORATE OFFER RESPONSE = $response",
      );

      final amount =
          extractAmount(response);

      if (!mounted) return;

      setState(() {
        corporateAmount = amount;
      });
    } catch (e) {
      debugPrint(
        "CORPORATE OFFER ERROR = $e",
      );

      showMessage(
        "Corporate offer load nahi hua.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingCorporateOffer = false;
        });
      }
    }
  }

  // ============================================================
  // EX-SHOWROOM AMOUNT
  // ============================================================

  Future<void> loadExShowroomAmount() async {
    if (selectedVariantCode.isEmpty ||
        selectedModel.isEmpty ||
        locationCode.isEmpty) {
      return;
    }

    try {
      debugPrint("========================================");
      debugPrint("LOADING EX-SHOWROOM");
      debugPrint("Location : $locationCode");
      debugPrint("Model    : $selectedModel");
      debugPrint("Variant  : $selectedVariantCode");
      debugPrint("Column   : Ex_Showroom");
      debugPrint("========================================");

      final response =
          await QuotationApiService.getPriceAddon(
        variantCode: selectedVariantCode,
        column: "Ex_Showroom",
        locationCode: locationCode,
        model: selectedModel,
      );

      debugPrint("EX-SHOWROOM RESPONSE = $response");

      final amount = extractAmount(response);

      if (!mounted) return;

      setState(() {
        exShowroomController.text =
            amount.toStringAsFixed(2);
      });

      calculateOnRoadPrice();

      debugPrint(
        "EX-SHOWROOM AMOUNT = ${amount.toStringAsFixed(2)}",
      );
    } catch (e) {
      debugPrint("EX-SHOWROOM ERROR = $e");

      if (mounted) {
        showMessage(
          "Ex-Showroom amount load nahi hua.",
          isError: true,
        );
      }
    }
  }

  // ============================================================
  // INSURANCE
  // ============================================================

  Future<void> loadInsuranceAmount(
    String column,
  ) async {
    if (selectedVariantCode.isEmpty ||
        selectedModel.isEmpty ||
        locationCode.isEmpty) {
      return;
    }

    try {
      final response =
          await QuotationApiService .getPriceAddon(
        variantCode: selectedVariantCode,
        column: column,
        locationCode:  locationCode,
        model: selectedModel,
      );

      debugPrint(
        "INSURANCE RESPONSE = $response",
      );

      final amount = extractAmount(response);

      insuranceController.text = amount.toStringAsFixed(2);

      calculateOnRoadPrice();
    } catch (e) {
      debugPrint(
        "INSURANCE ERROR = $e",
      );

      showMessage(
        "Insurance amount load nahi hua.",
        isError: true,
      );
    }
  }

  // ============================================================
  // VARIANT HELPERS
  // ============================================================

 Map<String, dynamic>? _findMapByString(
  List<Map<String, dynamic>> list,
  String Function(Map<String, dynamic>) getter,
  String value,
) {
  for (final item in list) {
    if (getter(item) == value) {
      return item;
    }
  }

  return null;
}

  String getVariantDescription(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        "VariantDescription",
        "Variant_Description",
        "VARIANT_DESC",
        "Variant_Desc",
        "Description",
        "Variant",
        "variant",
      ],
    );
  }

  String getVariantCode(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        // IMPORTANT: selectedVariantCode must use Model_with_Type
        // Example: ATR4HL1(M)
        "Model_with_Type",
        "model_with_type",

        "VariantCode",
        "Variant_Code",
        "VARIANT_CD",
        "variantCode",
        "variant_code",

        // Fallback only
        "Model_Code",
        "MODEL_CODE",
        "model_code",
      ],
    );
  }

  // ============================================================
  // COLOR HELPER
  // ============================================================

  String getColorName(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        "ColorDescription",
        "Color_Description",
        "ColourDescription",
        "Colour_Description",
        "Color",
        "Colour",
        "COLOR",
        "COLOR_DESC",
        "Color_Name",
        "Colour_Name",
      ],
    );
  }

  // ============================================================
  // COLOR EX-SHOWROOM HELPER
  // ============================================================

  double getColorExShowroom(
    Map<String, dynamic> item,
  ) {
    final value =
        item["Ex_Showroom"] ??
        item["ExShowroom"] ??
        item["ex_showroom"] ??
        item["exShowroom"];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString().replaceAll(",", "").trim() ?? "",
        ) ??
        0;
  }

  // ============================================================
  // CORPORATE HELPER
  // ============================================================

  String getCorporateName(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        "CorporateName",
        "corporateName",
        "Corporate_Name",
        "Name",
        "name",
      ],
    );
  }

  String getCorporateCode(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        "CorporateCode",
        "corporateCode",
        "Corporate_Code",
        "Code",
        "code",
      ],
    );
  }

  // ============================================================
  // FINANCIER HELPER
  // ============================================================

  String getFinancierName(
    Map<String, dynamic> item,
  ) {
    return firstString(
      item,
      [
        "FinancierName",
        "financierName",
        "Name",
        "name",
        "Financier",
        "financier",
      ],
    );
  }

  // ============================================================
  // GENERIC STRING
  // ============================================================

  String firstString(
    Map<String, dynamic> item,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = item[key];

      if (value != null) {
        final text =
            value.toString().trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return "";
  }

  // ============================================================
  // GENERIC LIST
  // ============================================================

  List extractList(
    dynamic response,
    List<String> keys,
  ) {
    if (response is List) {
      return response;
    }

    if (response is Map) {
      for (final key in keys) {
        final value = response[key];

        if (value is List) {
          return value;
        }
      }
    }

    return [];
  }

  // ============================================================
  // NUMBER
  // ============================================================

  double numberValue(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }

  // ============================================================
  // EXTRACT AMOUNT
  // ============================================================

  double extractAmount(
    dynamic response,
  ) {
    if (response is num) {
      return response.toDouble();
    }

    if (response is List &&
        response.isNotEmpty) {
      return extractAmount(
        response.first,
      );
    }

    if (response is Map) {
      const keys = [
        "amount",
        "Amount",
        "value",
        "Value",
        "price",
        "Price",
        "addon",
        "Addon",
        "offerAmount",
        "OfferAmount",
        "corporateAmount",
        "CorporateAmount",

        // Ex-Showroom API response keys
        "Ex_Showroom",
        "ExShowroom",
        "ex_showroom",
        "exShowroom",
        "Ex-Showroom",
      ];

      for (final key in keys) {
        final value =
            response[key];

        if (value is num) {
          return value.toDouble();
        }

        final parsed =
            double.tryParse(
          value?.toString() ?? "",
        );

        if (parsed != null) {
          return parsed;
        }
      }

      if (response["data"] != null) {
        return extractAmount(
          response["data"],
        );
      }
    }

    return 0;
  }

  // ============================================================
  // INSURANCE COLUMN
  // ============================================================

  String getInsuranceColumn() {
    switch (selectedInsurance) {
      case "Insurance 1+3":
        return "Insurance_1Plus3";

      case "Insurance 1+3 with EPRT":
        return "Insurance_1Plus3_withEPRT";

      case "Insurance 3+3":
        return "Insurance_3Plus3";

      case "Insurance 3+3 with EPRT":
        return "Insurance_3Plus3_withEPRT";

      default:
        return "";
    }
  }

  // ============================================================
  // DOUBLE FROM CONTROLLER
  // ============================================================

  double controllerNumber(
    TextEditingController controller,
  ) {
    return double.tryParse(
          controller.text.trim(),
        ) ??
        0;
  }

  // ============================================================
  // CALCULATE FINANCE
  // ============================================================

  void calculateFinance() {
    final financeOn = controllerNumber(financeOnController);
    final loanPercent = controllerNumber(loanPerController);
    final annualRate = controllerNumber(roiController);
    final months = int.tryParse(tenureController.text.trim()) ?? 0;

    final loanAmount = financeOn * loanPercent / 100;
    loanAmountController.text = loanAmount.toStringAsFixed(2);

    if (loanAmount <= 0 || months <= 0) {
      emiController.text = "0.00";
      if (mounted) setState(() {});
      return;
    }

    final monthlyRate = annualRate / 12 / 100;
    final emi = monthlyRate == 0
        ? loanAmount / months
        : loanAmount *
            monthlyRate *
            math.pow(1 + monthlyRate, months) /
            (math.pow(1 + monthlyRate, months) - 1);

    emiController.text = emi.toStringAsFixed(2);

    if (mounted) setState(() {});
  }

  // ============================================================
  // CALCULATE ON ROAD
  // ============================================================

  void calculateOnRoadPrice() {
    final exShowroom = controllerNumber(exShowroomController);
    final totalOffer =
        totalOfferValue +
        corporateAmount +
        controllerNumber(discountController);

    final cost = math.max(0, exShowroom - totalOffer);

    final tcsRate = selectedTcsRate == "1%" ? 0.01 : 0.0;
    final tcs = cost >= 1000000 && customerType != "CSD"
        ? cost * tcsRate
        : 0.0;

    final invoice = cost + tcs;

    costOfVehicleController.text = cost.toStringAsFixed(2);
    tcsAmountController.text = tcs.toStringAsFixed(2);
    invoiceAmountController.text = invoice.toStringAsFixed(2);

    final onRoad =
        invoice +
        controllerNumber(insuranceController) +
        controllerNumber(extendedWarrantyAmountController) +
        controllerNumber(ccpAmountController) +
        controllerNumber(rtoController) +
        controllerNumber(msgaAmountController) +
        controllerNumber(fastagAmountController) +
        controllerNumber(otherChargeAmountController);

    onRoadController.text = onRoad.toStringAsFixed(2);

    if (financeOnController.text.trim().isEmpty) {
      financeOnController.text = onRoad.toStringAsFixed(2);
    }

    calculateFinance();

    if (mounted) setState(() {});
  }

  // ============================================================
  // SAVE BODY
  // ============================================================

  Map<String, dynamic> buildQuotationBody() {
    final exShowroom = controllerNumber(exShowroomController);
    final insuranceAmount = controllerNumber(insuranceController);
    final rtoAmount = controllerNumber(rtoController);
    final additionalDiscount = controllerNumber(discountController);

    final totalOffer =
        totalOfferValue +
        corporateAmount +
        additionalDiscount;

    final costOfVehicle =
        controllerNumber(costOfVehicleController);

    return {
      "userId": userId,
      "locationCode": locationCode,
      "CustomerName": customerNameController.text.trim(),
      "PhoneNo": mobileController.text.trim(),
      "Email": emailController.text.trim(),
      "City": cityController.text.trim(),
      "Profession": professionController.text.trim(),
      "CustomerType": customerType,
      "Model": selectedModel,
      "VariantDescription": selectedVariant,
      "VariantCode": selectedVariantCode,
      "ColorDescription": selectedColour,
      "ExShowroom": exShowroom,

      "CorporateCode": corporateCode,
      "CorporateOfferName": corporateOfferName,
      "CorporateAmount": corporateAmount,
      "AddiDiscount": additionalDiscount,
      "TotalOfferValue": totalOffer,

      "CostOfVehicle": costOfVehicle,
      "TCSRate": selectedTcsRate == "1%" ? 1 : 0,
      "TCSAmount": controllerNumber(tcsAmountController),
      "InvioceAmount":
          controllerNumber(invoiceAmountController),

      "InsuranceType": getInsuranceColumn(),
      "InsuranceAmount": insuranceAmount,

      "ExtendedWarrantyType":
          selectedExtendedWarrantyType,
      "ExtendedWarrantyAmount":
          controllerNumber(extendedWarrantyAmountController),

      "CCPType": selectedCcpType,
      "CCPAmount": controllerNumber(ccpAmountController),

      "RTOType": selectedRto,
      "RTOAmount": rtoAmount,

      "MSGAType": selectedMsgaType,
      "MSGAAmount":
          controllerNumber(msgaAmountController),

      "FasTag": selectedFastag,
      "FasTagAmount":
          controllerNumber(fastagAmountController),

      "OtherCharge": otherChargeController.text.trim(),
      "OtherChargeAmount":
          controllerNumber(otherChargeAmountController),

      "OnRoadPrice":
          controllerNumber(onRoadController),

      "LoanType": paymentType,
      "FinancierName":
          paymentType == "Cash"
              ? "CASH"
              : selectedFinancier,
      "FinanceOn": financeOnController.text.trim(),
      "Tenure":
          int.tryParse(tenureController.text.trim()) ?? 0,
      "ROI": controllerNumber(roiController),
      "LoanPer": controllerNumber(loanPerController),
      "Loanamount":
          controllerNumber(loanAmountController),
      "EMI": controllerNumber(emiController),
      "Offers": offers,
    };
  }





  Future<void> saveQuotation() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (locationCode.isEmpty) {
      showMessage(
        "Location Code missing.",
        isError: true,
      );
      return;
    }

    if (selectedModel.isEmpty) {
      showMessage(
        "Please select Model.",
        isError: true,
      );
      return;
    }

    if (selectedVariant.isEmpty) {
      showMessage(
        "Please select Variant.",
        isError: true,
      );
      return;
    }

    if (selectedVariantCode.isEmpty) {
      showMessage(
        "Variant Code missing.",
        isError: true,
      );
      return;
    }

    if (selectedColour.isEmpty) {
      showMessage(
        "Please select Colour.",
        isError: true,
      );
      return;
    }

    final phoneNumber = mobileController.text.trim();
    if (phoneNumber.isEmpty) {
      showMessage(
        "Please enter Contact Number.",
        isError: true,
      );
      return;
    }

    setState(() {
      savingQuotation = true;
    });

    try {
      calculateOnRoadPrice();

      final body = buildQuotationBody();

      debugPrint(
        const JsonEncoder.withIndent("  ").convert(body),
      );

      // STEP 1: Save quotation.
      final saveResponse = await QuotationApiService.saveQuotation(body);

      debugPrint(
        "SAVE RESPONSE = $saveResponse",
      );

      // STEP 2: Get custId returned by /quotations.
      final custId = extractCustId(saveResponse);

      if (custId == null) {
        throw Exception(
          "Quotation saved, but API did not return custId. "
          "Check /api/quotations response.",
        );
      }

      debugPrint("CUST ID = $custId");
      debugPrint("CONTACT NUMBER = $phoneNumber");

      // STEP 3: Backend generates/locates the quotation PDF,
      // reads PhoneNo saved with this custId and sends it through
      // Daksh Connect WhatsApp template.
      final whatsappResponse =
          await QuotationApiService.sendQuotationWhatsApp(
        custId,
      );

      debugPrint(
        "WHATSAPP RESPONSE = $whatsappResponse",
      );

      if (!mounted) return;

      showMessage(
        "Quotation saved and PDF sent on WhatsApp.",
      );

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint(
        "SAVE QUOTATION / WHATSAPP ERROR = $e",
      );

      if (mounted) {
        showMessage(
          "Quotation save/WhatsApp failed.\n$e",
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          savingQuotation = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Colors.red
                : const Color(0xff145DA0),
      ),
    );
  }




dynamic extractCustId(dynamic response) {
    if (response == null) return null;

    if (response is num) {
      return response;
    }

    if (response is String) {
      final value = response.trim();
      if (value.isEmpty) return null;

      // Direct numeric response.
      final number = int.tryParse(value);
      if (number != null) return number;

      // JSON string response.
      try {
        return extractCustId(jsonDecode(value));
      } catch (_) {
        return null;
      }
    }

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);

      const keys = <String>[
        "custId",
        "CustId",
        "CUSTID",
        "CustID",
        "customerId",
        "CustomerId",
        "quotationId",
        "QuotationId",
        "id",
        "Id",
      ];

      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value;
        }
      }

      for (final key in <String>["data", "result", "quotation"]) {
        if (map[key] != null) {
          final value = extractCustId(map[key]);
          if (value != null) return value;
        }
      }
    }

    return null;
  }
  // ============================================================
  // SAVE QUOTATION
  // ============================================================

  // Future<void> saveQuotation() async {
  //   FocusScope.of(context).unfocus();

  //   if (!_formKey.currentState!
  //       .validate()) {
  //     return;
  //   }

  //   if (locationCode.isEmpty) {
  //     showMessage(
  //       "Location Code missing.",
  //       isError: true,
  //     );

  //     return;
  //   }

  //   if (selectedModel.isEmpty) {
  //     showMessage(
  //       "Please select Model.",
  //       isError: true,
  //     );

  //     return;
  //   }

  //   if (selectedVariant.isEmpty) {
  //     showMessage(
  //       "Please select Variant.",
  //       isError: true,
  //     );

  //     return;
  //   }

  //   if (selectedVariantCode.isEmpty) {
  //     showMessage(
  //       "Variant Code missing.",
  //       isError: true,
  //     );

  //     return;
  //   }

  //   if (selectedColour.isEmpty) {
  //     showMessage(
  //       "Please select Colour.",
  //       isError: true,
  //     );

  //     return;
  //   }

  //   setState(() {
  //     savingQuotation = true;
  //   });

  //   try {
  //     calculateOnRoadPrice();

  //     final body =
  //         buildQuotationBody();

  //     debugPrint(
  //       const JsonEncoder
  //           .withIndent("  ")
  //           .convert(body),
  //     );

  //     final response =
  //         await QuotationApiService
  //             .saveQuotation(body);

  //     debugPrint(
  //       "SAVE RESPONSE = $response",
  //     );

  //     if (!mounted) return;

  //     showMessage(
  //       "Quotation saved successfully.",
  //     );

  //     await Future.delayed(
  //       const Duration(
  //         milliseconds: 800,
  //       ),
  //     );

  //     if (mounted) {
  //       Navigator.pop(
  //         context,
  //         true,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint(
  //       "SAVE QUOTATION ERROR = $e",
  //     );

  //     if (mounted) {
  //       showMessage(
  //         "Quotation save failed.\n$e",
  //         isError: true,
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         savingQuotation = false;
  //       });
  //     }
  //   }
  // }

  // // ============================================================
  // // MESSAGE
  // // ============================================================

  // void showMessage(
  //   String message, {
  //   bool isError = false,
  // }) {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context)
  //       .hideCurrentSnackBar();

  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor:
  //           isError
  //               ? Colors.red
  //               : const Color(0xff145DA0),
  //     ),
  //   );
  // }


  // ============================================================
  // RESPONSIVE BUILD - MATCHES THE PROVIDED DESKTOP DESIGN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF4FB),
      appBar: AppBar(
        backgroundColor: const Color(0xff145DA0),
        foregroundColor: Colors.white,
        title: const Text(
          "Add Quotation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildCustomerSection(),
              const SizedBox(height: 14),
              buildVehicleSection(),
              const SizedBox(height: 14),
              buildOfferSection(),
              const SizedBox(height: 14),
              buildPriceSection(),
              const SizedBox(height: 14),
              buildFinanceSection(),
              const SizedBox(height: 18),
              buildSaveButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMON RESPONSIVE GRID
  // ============================================================

  Widget responsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 3 : width >= 650 ? 2 : 1;
        const gap = 20.0;
        final itemWidth =
            (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  Widget buildCustomerSection() {
    return sectionCard(
      title: "Customer Details",
      children: [
        responsiveGrid([
          textField(
            controller: customerNameController,
            label: "Customer Name",
            required: true,
          ),
          textField(
            controller: mobileController,
            label: "Contact Number",
            keyboardType: TextInputType.phone,
            maxLength: 10,
            required: true,
          ),
          textField(
            controller: emailController,
            label: "Email Id",
            keyboardType: TextInputType.emailAddress,
          ),
          textField(
            controller: cityController,
            label: "City",
          ),
          dropdownString(
            label: "Customer Profession",
            value: professionController.text.isEmpty
                ? null
                : professionController.text,
            items: const [
              "Private Job",
              "Government Job",
              "Business",
              "Self Employed",
              "Farmer",
              "Student",
              "Other",
            ],
            hint: "Select Profession Type",
            onChanged: (value) {
              professionController.text = value ?? "";
              setState(() {});
            },
          ),
          dropdownString(
            label: "Customer Type",
            value: customerType,
            items: const ["Individual", "CSD"],
            hint: "Select Customer Type",
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                customerType = value;
                calculateOnRoadPrice();
              });
            },
          ),
        ]),
      ],
    );
  }

  // ============================================================
  // VEHICLE
  // ============================================================

  Widget buildVehicleSection() {
    return sectionCard(
      title: "Vehicle Details",
      children: [
        responsiveGrid([
          readOnlyValue("Location Code", locationCode),
          dropdownString(
            label: "Model",
            value:
                selectedModel.isEmpty ? null : selectedModel,
            items: models,
            hint: loadingModels
                ? "Loading Models..."
                : modelsLoaded && models.isEmpty
                    ? "Data Not Found"
                    : "Select Model",
            onChanged: loadingModels
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      selectedModel = value;
                      selectedVariant = "";
                      selectedVariantCode = "";
                      selectedColour = "";
                      variants = [];
                      colors = [];
                      offers = [];
                      totalOfferValue = 0;
                      exShowroomController.clear();
                      insuranceController.clear();
                    });

                    // IMPORTANT: no async callback here.
                    // This avoids Future<void> -> ValueChanged errors.
                    unawaited(loadVariants(value));
                  },
          ),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedVariantCode.isEmpty
                ? null
                : (variants.any(
                        (item) => getVariantCode(item) == selectedVariantCode,
                      )
                    ? selectedVariantCode
                    : null),
            decoration: fieldDecoration("Variant Name"),
            hint: Text(
              loadingVariants
                  ? "Loading Variants..."
                  : variantsLoaded && variants.isEmpty
                      ? "Data Not Found"
                      : "Select Variant",
            ),
            items: variants
                .map(getVariantCode)
                .where((code) => code.isNotEmpty)
                .toSet()
                .map((code) {
                  final item = variants.firstWhere(
                    (v) => getVariantCode(v) == code,
                  );
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(
                      getVariantDescription(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                })
                .toList(),
            onChanged: loadingVariants
                ? null
                : (code) {
                    if (code == null || code.isEmpty) return;

                    final item = variants.firstWhere(
                      (v) => getVariantCode(v) == code,
                    );
                    final name = getVariantDescription(item);

                    setState(() {
                      selectedVariant = name;
                      selectedVariantCode = code;
                      selectedColour = "";
                    });

                    // Ex_Showroom comes from the Colors API response.
                    // First load Colors, then Offers.
                    unawaited(
                      loadColors().then((_) {
                        if (mounted) {
                          return loadOffers();
                        }
                        return Future<void>.value();
                      }),
                    );
                  },
          ),
          readOnlyValue("Variant Code", selectedVariantCode),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedColour.isEmpty
                ? null
                : (colors.any((item) => getColorName(item) == selectedColour)
                    ? selectedColour
                    : null),
            decoration: fieldDecoration("Color"),
            hint: Text(
              loadingColors
                  ? "Loading Color..."
                  : colorsLoaded && colors.isEmpty
                      ? "Data Not Found"
                      : "Select Color",
            ),
            items: colors
                .map(getColorName)
                .where((name) => name.isNotEmpty)
                .toSet()
                .map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: loadingColors
                ? null
                : (value) {
                    if (value == null) return;

                    final item = _findMapByString(
                      colors,
                      getColorName,
                      value,
                    );

                    if (item == null) return;

                    final exShowroom =
                        getColorExShowroom(item);

                    debugPrint(
                      "SELECTED COLOR = $value",
                    );
                    debugPrint(
                      "SELECTED EX-SHOWROOM = $exShowroom",
                    );

                    setState(() {
                      selectedColour = value;
                      exShowroomController.text =
                          exShowroom.toStringAsFixed(2);
                    });

                    calculateOnRoadPrice();
                  },
          ),
          textField(
            controller: exShowroomController,
            label: "Ex-Showroom",
            readOnly: true,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => calculateOnRoadPrice(),
          ),
        ]),
      ],
    );
  }

  // ============================================================
  // OFFERS
  // ============================================================

  Widget buildOfferSection() {
    final corporateCodes = corporateList
        .map(getCorporateCode)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    final corporateNames = corporateList
        .map(getCorporateName)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return sectionCard(
      title: "Offers Details",
      children: [
        responsiveGrid([
          dropdownString(
            label: "Corporate Code",
            value: corporateCode.isEmpty ? null : corporateCode,
            items: corporateCodes,
            hint: loadingCorporate
                ? "Loading..."
                : "Corporate Code",
            onChanged: loadingCorporate
                ? null
                : (value) {
                    if (value == null) return;

                    final item = _findMapByString(
                      corporateList,
                      getCorporateCode,
                      value,
                    );
                    if (item == null) return;

                    _selectCorporate(item);
                  },
          ),
          dropdownString(
            label: "Corporate Offer Name",
            value:
                corporateOfferName.isEmpty
                    ? null
                    : corporateOfferName,
            items: corporateNames,
            hint: loadingCorporate
                ? "Loading..."
                : "Corporate Offer Name",
            onChanged: loadingCorporate
                ? null
                : (value) {
                    if (value == null) return;

                    final item = _findMapByString(
                      corporateList,
                      getCorporateName,
                      value,
                    );
                    if (item == null) return;

                    _selectCorporate(item);
                  },
          ),
          readOnlyValue(
            "Corporate Amount",
            corporateAmount.toStringAsFixed(2),
          ),
          textField(
            controller: discountController,
            label: "Additional Discount",
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => calculateOnRoadPrice(),
          ),
          readOnlyValue(
            "Total Offers",
            totalOfferValue.toStringAsFixed(2),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 42,
              width: 106,
              child: ElevatedButton(
                onPressed: offers.isEmpty
                    ? null
                    : showOffersDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff145DA0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ]),
        if (loadingOffers) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  void _selectCorporate(Map<String, dynamic> item) {
    setState(() {
      selectedCorporate = getCorporateName(item);
      corporateCode = getCorporateCode(item);
      corporateOfferName = selectedCorporate;
      corporateAmount = 0;
    });

    // API method already exists in your original code.
    unawaited(
      loadCorporateOffer().then((_) {
        if (mounted) calculateOnRoadPrice();
      }),
    );
  }

  void showOffersDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Available Offers"),
          content: SizedBox(
            width: 500,
            child: offers.isEmpty
                ? const Text("No offers available.")
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: offers.length,
                    separatorBuilder: (_, __) =>
                        const Divider(),
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      final header =
                          offer["header"]?.toString() ?? "";
                      final description =
                          offer["description"]?.toString() ?? "";
                      final value =
                          numberValue(offer["value"]);

                      return ListTile(
                        title: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(description),
                        trailing: Text(
                          "₹${value.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRICE DETAILS
  // ============================================================

  Widget buildPriceSection() {
    return sectionCard(
      title: "Price Details",
      children: [
        responsiveGrid([
          readOnlyAmount(
            "Cost Of Vehicle",
            costOfVehicleController,
          ),
          dropdownString(
            label: "TCS Rate",
            value: selectedTcsRate,
            items: const ["No", "1%"],
            hint: "TCS Rate",
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                selectedTcsRate = value;
              });
              calculateOnRoadPrice();
            },
          ),
          readOnlyAmount(
            "TCS Amount",
            tcsAmountController,
          ),

          readOnlyAmount(
            "Invoice Amount",
            invoiceAmountController,
          ),
          dropdownString(
            label: "Insurance Type",
            value: selectedInsurance.isEmpty
                ? null
                : selectedInsurance,
            items: const [
              "Insurance 1+3",
              "Insurance 1+3 with EPRT",
              "Insurance 3+3",
              "Insurance 3+3 with EPRT",
            ],
            hint: "Insurance Type",
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedInsurance = value;
              });

              final column = getInsuranceColumn();
              unawaited(loadInsuranceAmount(column));
            },
          ),
          readOnlyAmount(
            "Insurance Amount",
            insuranceController,
          ),

          dropdownString(
            label: "Extended Warranty Type",
            value: selectedExtendedWarrantyType.isEmpty
                ? null
                : selectedExtendedWarrantyType,
            items: const [
              "Extended Warranty",
              "EW Royal 5th Year",
              "EW Platinum 4th Year",
            ],
            hint: "Extended Warranty Type",
            onChanged: (value) {
              setState(() {
                selectedExtendedWarrantyType = value ?? "";
              });
              calculateOnRoadPrice();
            },
          ),
          amountField(
            "Extended Warranty Amount",
            extendedWarrantyAmountController,
          ),
          dropdownString(
            label: "CCP Type",
            value:
                selectedCcpType.isEmpty ? null : selectedCcpType,
            items: const [
              "CCP",
              "CCP Plus",
              "No CCP",
            ],
            hint: "CCP Type",
            onChanged: (value) {
              setState(() {
                selectedCcpType = value ?? "";
              });
              calculateOnRoadPrice();
            },
          ),

          amountField("CCP Amount", ccpAmountController),
          dropdownString(
            label: "RTO Type",
            value:
                selectedRto.isEmpty ? null : selectedRto,
            items: const [
              "Same State",
              "Other State(Only NCR)",
            ],
            hint: "RTO Type",
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                selectedRto = value;
              });
              calculateOnRoadPrice();
            },
          ),
          amountField("RTO Amount", rtoController),

          dropdownString(
            label: "MSGA Type",
            value: selectedMsgaType,
            items: const [
              "MSGA / GNA",
              "MSGA",
              "GNA",
              "No",
            ],
            hint: "MSGA / GNA",
            onChanged: (value) {
              setState(() {
                selectedMsgaType = value ?? "MSGA / GNA";
              });
              calculateOnRoadPrice();
            },
          ),
          amountField("MSGA Amount", msgaAmountController),
          dropdownString(
            label: "FasTag",
            value:
                selectedFastag.isEmpty ? null : selectedFastag,
            items: const [
              "FasTag",
              "Yes",
              "No",
            ],
            hint: "FasTag",
            onChanged: (value) {
              setState(() {
                selectedFastag = value ?? "";
              });
              calculateOnRoadPrice();
            },
          ),

          amountField("FasTag Amount", fastagAmountController),
          textField(
            controller: otherChargeController,
            label: "Other Charge",
          ),
          amountField(
            "Other Charge Amount",
            otherChargeAmountController,
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffE8F2FF),
            border: Border.all(
              color: const Color(0xffA9C8ED),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "On Road Price",
                  style: TextStyle(
                    color: Color(0xff0F559C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "₹${controllerNumber(onRoadController).toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xff0F559C),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FINANCE / EMI
  // ============================================================

  Widget buildFinanceSection() {
    return sectionCard(
      title: "EMI Calculator",
      children: [
        responsiveGrid([
          dropdownString(
            label: "Loan Type",
            value: paymentType,
            items: const ["Cash", "Finance"],
            hint: "Loan Type",
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                paymentType = value;
                if (value == "Cash") {
                  selectedFinancier = "CASH";
                }
              });

              if (value == "Finance" &&
                  financiers.isEmpty &&
                  !loadingFinanciers) {
                unawaited(loadFinanciers());
              }

              calculateFinance();
            },
          ),
          dropdownString(
            label: "Financier Name",
            value:
                selectedFinancier.isEmpty
                    ? null
                    : selectedFinancier,
            items: financiers
                .map(getFinancierName)
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList(),
            hint: loadingFinanciers
                ? "Loading Financier..."
                : "Select Financier",
            onChanged: paymentType == "Cash"
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      selectedFinancier = value;
                    });
                  },
          ),
          textField(
            controller: financeOnController,
            label: "Finance On",
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => calculateFinance(),
          ),
          textField(
            controller: tenureController,
            label: "Tenure (Months)",
            keyboardType: TextInputType.number,
            onChanged: (_) => calculateFinance(),
          ),
          textField(
            controller: roiController,
            label: "ROI (%)",
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => calculateFinance(),
          ),
          dropdownString(
            label: "Loan %",
            value: loanPerController.text.isEmpty
                ? null
                : loanPerController.text,
            items: const ["70", "80", "90", "100"],
            hint: "Loan %",
            onChanged: (value) {
              if (value == null) return;
              loanPerController.text = value;
              calculateFinance();
            },
          ),
          readOnlyAmount(
            "Loan Amount",
            loanAmountController,
          ),
          readOnlyAmount(
            "EMI (Monthly)",
            emiController,
          ),
        ]),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffD7E3F2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffD7E3F2),
                ),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff0757A6),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool required = false,
    bool readOnly = false,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return "$label is required";
              }
              return null;
            }
          : null,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xff17324D),
      ),
      decoration: fieldDecoration(label),
    );
  }

  Widget readOnlyValue(String label, String value) {
    return InputDecorator(
      decoration: fieldDecoration(label),
      child: SizedBox(
        height: 20,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value.isEmpty ? "0" : value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff5B6B7A),
            ),
          ),
        ),
      ),
    );
  }

  Widget readOnlyAmount(
    String label,
    TextEditingController controller,
  ) {
    return textField(
      controller: controller,
      label: label,
      readOnly: true,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
    );
  }

  Widget amountField(
    String label,
    TextEditingController controller,
  ) {
    return textField(
      controller: controller,
      label: label,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onChanged: (_) => calculateOnRoadPrice(),
    );
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xff0C2D4A),
        fontSize: 12,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xffFBFDFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xffC9DBEF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xffC9DBEF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xff145DA0),
          width: 1.2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xffC9DBEF),
        ),
      ),
    );
  }

  // ============================================================
  // STRING DROPDOWN
  // ============================================================

  Widget dropdownString({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    String? hint,
  }) {
    final validValue =
        value != null && items.contains(value)
            ? value
            : null;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: validValue,
      decoration: fieldDecoration(label),
      hint: hint == null ? null : Text(
        hint,
        overflow: TextOverflow.ellipsis,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget buildSaveButton() {
    return SizedBox(
      width: 260,
      height: 48,
      child: ElevatedButton.icon(
        onPressed:
            savingQuotation ? null : saveQuotation,
        icon: savingQuotation
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          savingQuotation
              ? "Saving..."
              : "Save Quotation",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff145DA0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }
}
