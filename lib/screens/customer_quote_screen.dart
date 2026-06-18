import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pmpl_salesquote/screens/login_screen.dart';
import 'package:pmpl_salesquote/screens/pdf_screen.dart';
import 'package:pmpl_salesquote/services/auth_service.dart';
import 'package:pmpl_salesquote/models/price_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class CustomerQuoteScreen extends StatefulWidget {
  final String userName;
  final String teamLeaderName;
  final String teamLeaderCont;
  const CustomerQuoteScreen({super.key, required this.userName, required this.teamLeaderName, required this.teamLeaderCont});
  @override
  State<CustomerQuoteScreen> createState() => _CustomerQuoteScreenState();
}

class UpperCaseTextFormatter
    extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {

      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    }
}

class LowerCaseTextFormatter
    extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      return TextEditingValue(
        text: newValue.text.toLowerCase(),
        selection: newValue.selection,
      );
    }
}

class _CustomerQuoteScreenState extends State<CustomerQuoteScreen> {
  /// FORM KEY
  final _formKey = GlobalKey<FormState>();
   String userName = "";
   String userId = "";
   String teamLeaderName = "";
   String teamLeaderCont = "";
  
   String? showroomType = "";
  /// 🔹 BASIC CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  /// 🔹 PRICE CONTROLLERS
  final exShowroomController = TextEditingController();
  final parkingChargeController = TextEditingController();
  final FastagAmountController = TextEditingController();
  final totalOfferController = TextEditingController();
  final txtInsAmtController = TextEditingController();
  final txtMGAAmtController = TextEditingController();
  final txtRTOAmtController = TextEditingController();
  final txtEWAmountController = TextEditingController();
  final txtCcpAmountController = TextEditingController();
  final txtConsumerOfferController = TextEditingController();
  final txtExchangAmtController = TextEditingController();
  final txtAddDisController = TextEditingController();
  /// 🔹 FINANCE CONTROLLERS
  final tenureController = TextEditingController();
  final interestController = TextEditingController();
  final loanAmountController = TextEditingController();
  final emiController = TextEditingController();
  final tcsPctController = TextEditingController();
  /// 🔹 DROPDOWN VARIABLES
  String? customerType, model;
  String? color, profession, corporate, department, parking;
  String? fastag, insurance, accessories, rto, warranty,FasTag,Ccp;
  String? consumerOffer, exchange, addDiscount;
  String? financier, bank, financeOn, percent;
  bool isFinance = false;
  /// 🔹 LISTS
  List<String> financerNames = [];
  List<PriceModel> allData = [];
  List<String> modelList = [];
  List<String> variantList = [];
  List<String> variantCodeList = [];
  List<String> colorList = [];
  String? selectedVariant;
  String? selectedVariantCode;
  String? selectedModel;
  List<String> departmentList = []; 
  bool isLoading = false;
  bool isCorporateEnabled = false;
  bool isInsuranceEnabled = false;
  bool isAccessoriesEnabled = false;
  bool isRTOEnabled = false;
  bool isWarrantyEnabled = false;
  bool isCcpEnabled = false;
  bool isConsumerOfferEnabled = false;
  bool isExchangeEnabled = false;
  bool isDiscountEnabled = false;
  bool isExshowroomEnabled = false;
  List<String> corporateList = [];
  double totalOffer = 0;
  // final totalOfferController = TextEditingController();
  String? parkingCharge;

String selectedModelGroup = "";
String custType = "";
 String? locationCode = " ";
 /// ================= API LOAD =================
 
final AuthService apiService = AuthService();
void loadData() async {
  allData = await apiService.getAllData();
  
  modelList = allData.map((e) => e.modelGroup).toSet().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  // modelList = allData.map((e) => e.modelGroup).toSet().toList();

  setState(() {});
}
Future<void> onModelChanged(String? v) async {
  if (v == null) return;
  setState(() {
    model = v;
    // variantList = allData .where((e) => e.modelGroup == v).map((e) => e.description).toSet().toList();
    variantList = allData.where((e) => e.modelGroup == v)
    .map((e) => e.description)
    .toSet()
    .toList()
  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));


    selectedVariant = null;
    selectedVariantCode = null;
    departmentList = [];   // 🔥 clear old data
    department = null;
    corporateList = [];   // 🔥 clear old data
    corporate = null;
  });
  await fetchCorporate(v);
}
void loadFinancers() async {
  financerNames = await apiService.getFinancerNames();
  setState(() {});
}
void onVariantChanged(String? v) {
  selectedVariant = v;
  // 🔹 Filter variant codes
  var filtered = allData.where((e) => e.modelGroup == model &&  e.description == v).toList();
  variantCodeList = filtered.map((e) => e.modelWithType).toSet().toList();
  // 🔥 AUTO FILL Ex Showroom (take first item)
  if (filtered.isNotEmpty) {
    exShowroomController.text = filtered.first.exShowroom.toString();
  }
  selectedVariantCode = null;
  colorList = [];
  setState(() {});
}

// void onVariantCodeChanged(String? v) async {
//   if (v == null) return;
//   selectedVariantCode = v;
//   // 🔥 Load colors from API
//   colorList = await apiService.getColors(v);
//   colorList.insert(0, "Select Colour");
//   color = "Select Colour";
//   setState(() {});
// }
void onVariantCodeChanged(String? v) async {
  if (v == null) return;

  selectedVariantCode = v;

  colorList = await apiService.getColors(v);

  color = null; // Clear selection

  setState(() {});
}

void resetForm() {
  _formKey.currentState?.reset();

  setState(() {
    // Dropdowns
    customerType = null;
    model = null;
    selectedVariant = null;
    selectedVariantCode = null;
    color = null;
    profession = null;
    insurance = null;
    accessories = null;
    rto = null;
    warranty = null;
    Ccp = null;
    FasTag = null;
    parkingCharge = null;
    corporate = null;
    department = null;
    consumerOffer = null;
    exchange = null;
    addDiscount = null;
    financier = null;
    bank = null;
    financeOn = null;
    percent = null;

    // Flags
    isInsuranceEnabled = false;
    isAccessoriesEnabled = false;
    isRTOEnabled = false;
    isWarrantyEnabled = false;
    isCcpEnabled = false;
    isConsumerOfferEnabled = false;
    isExchangeEnabled = false;
    isDiscountEnabled = false;
    isFinance = false;

    // Controllers
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    cityController.clear();

    exShowroomController.clear();
    parkingChargeController.clear();
    FastagAmountController.clear();
    totalOfferController.clear();
    txtInsAmtController.clear();
    txtMGAAmtController.clear();
    txtRTOAmtController.clear();
    txtEWAmountController.clear();
    txtCcpAmountController.clear();
    txtConsumerOfferController.clear();
    txtExchangAmtController.clear();
    txtAddDisController.clear();

    tenureController.clear();
    interestController.clear();
    loanAmountController.clear();
    emiController.clear();

    totalOfferController.clear();

    // Lists
    variantList.clear();
    variantCodeList.clear();
    colorList.clear();
    departmentList.clear();
    corporateList.clear();
  });
}
Future<void> fetchCorporate(String model) async {
  try {
    final data = await apiService.getDepartments(model);
    print("DEPARTMENT DATA: $data");
    setState(() {
      corporateList = data.toSet().toList(); 
      corporate = null;                      
    });
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> fetchDepartments(String corporate) async {
  try {
    final data = await apiService.GetCorporateByScheme(corporate);
    print("DEPARTMENT DATA: $data");
    setState(() {
      departmentList = data.toSet().toList(); // remove duplicates
      department = null; // reset selection
    });
  } catch (e) {
    print("Error: $e");
  }
}

Future<int?> saveData() async {

  if (!_formKey.currentState!.validate()) {
    return null;
  }
  final body = {
    "CustName": nameController.text.trim(),
    "PhoneNo": phoneController.text.trim(),
    "Email": emailController.text.trim(),
    "City": cityController.text.trim(),
    "CustType": customerType,
    "Model": model,
    "Variant": selectedVariant,
    "Model_with_Type": selectedVariantCode,
    "Colour": color,
    "Profession": profession,
    "ExShowroomPrice":double.tryParse(exShowroomController.text,) ?? 0,
    "CorporateName": corporate,
    "DeptName": department,
    // "MCDParkingCharges":parking == "Yes" ? 1 : 0,
    "CorporateOffer":double.tryParse(totalOfferController.text,) ?? 0,
    "InsurancePer": 0,
    // "FastTag":fastag == "Yes" ? 1 : 0,
    "FasTag":double.tryParse(FastagAmountController.text,) ?? 0,
    "MCDParkingCharges":double.tryParse(parkingChargeController.text,) ?? 0,
    "CcpAmt":double.tryParse(txtCcpAmountController.text,) ?? 0,
    "InsuranceAmt":double.tryParse(txtInsAmtController.text,) ?? 0,
    "AccessoriesPer": 0,
    "AccessoriesAmt":double.tryParse(txtMGAAmtController.text,) ?? 0,
    "RTOPer": 0,
    "RTOAmt":double.tryParse(txtRTOAmtController.text,) ?? 0,
    "WarrantyPer": 0,
    "WarrantyAmt": double.tryParse(txtEWAmountController.text,) ?? 0,
    "ConsumerOffer": 0,
    "ConsumerOfferAmt":double.tryParse(txtConsumerOfferController.text,) ?? 0,
    "ExchangePer": 0,
    "ExchangeAmt":double.tryParse(txtExchangAmtController.text,) ?? 0,
    "AdditionalDisAmt":double.tryParse(txtAddDisController.text,) ?? 0,
    "FinanceBank": bank,
    "Tenure":int.tryParse(tenureController.text,) ?? 0,
    "InterestType":interestController.text,
    "LoanPer":double.tryParse(percent?.replaceAll("%", "") ?? "0",) ?? 0,
    "Loanamount":double.tryParse(loanAmountController.text,) ?? 0,
    "EMI":double.tryParse(emiController.text,) ?? 0,
    "IsActive": true
  };
  final response = await apiService.submitData(body);

  if (response != null && response["success"] == true) 
  {
    int custId = response["custId"];
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "✅ Data Saved Successfully",
        ),
      ),
    );
    return custId;
  }
  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "❌ Failed to save data",
      ),
    ),
  );
  return null;
}


  @override
  void initState()
  {
    super.initState();
    loadData();
    loadUserData();
    loadShowroomType();
    loadFinancers();
    txtAddDisController.text = "0";
    txtExchangAmtController.text = "0";
    txtConsumerOfferController.text ="0";
    loanAmountController.addListener(calculateEMI);
    interestController.addListener(calculateEMI);
  }
  List<String> professionList =  ["Farmers","HouseWife", "NRI", "Other", "Proprietor/Trade", "Retired", "Salaried Govt.","Salaried Private", "Student" ];
  
 Widget textField(
  String label,
  TextEditingController controller, {
  bool enabled = true,
  bool isPhone = false,
  bool isNumeric = false,
  IconData? icon,
  bool isEmail = false,
  bool isRequired = true,
  bool isLowerCase = false,
  int? maxLength,
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    autovalidateMode: AutovalidateMode.onUserInteraction,

    keyboardType: (isPhone || isNumeric)
        ? TextInputType.number
        : TextInputType.text,
inputFormatters: isNumeric
    ? [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null)
          LengthLimitingTextInputFormatter(maxLength),
      ]
    : isPhone
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
        : isLowerCase
            ? [
                LowerCaseTextFormatter(),
              ]
            : [
                UpperCaseTextFormatter(),
              ],
              

      decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade300,
      border: const OutlineInputBorder(),
    ),

    validator: (value) {
      if (!enabled) return null;

      if (isRequired && (value == null || value.isEmpty)) {
        return "$label Required";
      }

      if (isPhone && value!.length != 10) {
        return "Phone must be 10 digits";
      }

      if (isEmail && value != null && value.isNotEmpty) {
        final regex = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        );

        if (!regex.hasMatch(value)) {
          return "Invalid email";
        }
      }

      return null;
    },
  );
}



Future<void> loadShowroomType() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    showroomType = prefs.getString("showroomType") ?? "";
  });
}
Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
     userName = prefs.getString("UserName") ?? "";
     userId = prefs.getString("userId") ?? "";
     showroomType = prefs.getString("showroomType") ?? "";
     teamLeaderName = prefs.getString("teamLeaderName") ?? "";
     teamLeaderCont = prefs.getString("teamLeaderCont") ?? "";
  });
}


Widget dropdown(
  String label,
  String? value,
  List<String> items,
  Function(String?)? onChange,
) {
  return DropdownButtonFormField<String>(
    isExpanded: true,
    value: value,
    items: items
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
        .toList(),
    onChanged: onChange,
    decoration: InputDecoration(
      labelText: label, // <-- yaha change
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(),
    ),
  );
}
  /// 🔹 CLEAR FINANCE
  void clearFinanceFields() {
    bank = null;
    financeOn = null;
    percent = null;
    tenureController.clear();
    interestController.clear();
    loanAmountController.clear();
    emiController.clear();
  }

void calculateEMI() {
  double loanAmount = double.tryParse(loanAmountController.text.replaceAll(',', '')) ?? 0;
  // Dropdown se direct months mil rahe hain
  int months = int.tryParse(tenureController.text) ?? 0;
  double annualInterestRate = double.tryParse(interestController.text) ?? 0;

  if (loanAmount > 0 && months > 0 && annualInterestRate > 0) {

    double monthlyRate = annualInterestRate / 12 / 100;

    double emi = (loanAmount *  monthlyRate *
            pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    setState(() {
      emiController.text = emi.toStringAsFixed(0);
    });
  } else {
    setState(() {
      emiController.clear();
    });
  }
}

double calculateTCS(
  double exShowroom,
  double totalOffers,
) {
  double costoffvehicle =
      exShowroom - totalOffers;

  if (costoffvehicle >= 1000000) {
    return costoffvehicle * 0.01;
  }

  return 0;
}

void calculateTCSAmount() {
  double exShowroom = double.tryParse(exShowroomController.text) ?? 0;

  double totalOffers =
      (double.tryParse(totalOfferController.text) ?? 0) +
      (double.tryParse(txtConsumerOfferController.text) ?? 0) +
      (double.tryParse(txtExchangAmtController.text) ?? 0) +
      (double.tryParse(txtAddDisController.text) ?? 0);

  double costOfVehicle = exShowroom - totalOffers;

  double tcs = 0;

  if (costOfVehicle >= 1000000) {
    tcs = costOfVehicle * 0.01;
  }

  setState(() {
    tcsPctController.text = tcs.toStringAsFixed(0);
  });
}


// void calculateLoanAmount() {
//   double exShowroom = double.tryParse(exShowroomController.text) ?? 0;
//   double insurance = double.tryParse(txtInsAmtController.text) ?? 0;
//   double accessories = double.tryParse(txtMGAAmtController.text) ?? 0;
//   double rto = double.tryParse(txtRTOAmtController.text) ?? 0;
//   double warranty = double.tryParse(txtEWAmountController.text) ?? 0;
//   double ewCcpAmount = double.tryParse(txtCcpAmountController.text) ?? 0;
//   double fasTag = double.tryParse(FastagAmountController.text) ?? 0;
//   double mcdParking = double.tryParse(parkingChargeController.text) ?? 0;
//   double corporateOffer = double.tryParse(totalOfferController.text) ?? 0;
//   double consumerOffer = double.tryParse(txtConsumerOfferController.text) ?? 0;
//   double exchange = double.tryParse(txtExchangAmtController.text) ?? 0;
//   double discount = double.tryParse(txtAddDisController.text) ?? 0;

//   double tcsPct = double.tryParse(tcsPctController.text) ?? 0;
//   // Total Offers
//   double totalOffers =corporateOffer +consumerOffer + exchange + discount;

//   double onRoadWithoutOffers =
//       exShowroom +
//       insurance +
//       rto +
//       warranty +
//       ewCcpAmount +
//       accessories +
//       fasTag +
//       mcdParking + tcsPct
//       ;
//   double onRoad = onRoadWithoutOffers - totalOffers;
//   double baseAmount = financeOn == "ExShowroom" ? exShowroom : onRoad;
//   double loanAmount = baseAmount;
//   if (percent != null && percent!.isNotEmpty) {
//     String cleanPercent = percent!.replaceAll('%', '');
//     double loanPer = double.tryParse(cleanPercent) ?? 100;
//     loanAmount = (baseAmount * loanPer) / 100;
//   }
//   loanAmountController.text = loanAmount.toStringAsFixed(0);
//   tcsPctController.text =tcsPct.toStringAsFixed(0);
// }



void calculateLoanAmount() {
  double exShowroom = double.tryParse(exShowroomController.text) ?? 0;
  double insurance = double.tryParse(txtInsAmtController.text) ?? 0;
  double accessories = double.tryParse(txtMGAAmtController.text) ?? 0;
  double rto = double.tryParse(txtRTOAmtController.text) ?? 0;
  double warranty = double.tryParse(txtEWAmountController.text) ?? 0;
  double ewCcpAmount = double.tryParse(txtCcpAmountController.text) ?? 0;
  double fasTag = double.tryParse(FastagAmountController.text) ?? 0;
  double mcdParking = double.tryParse(parkingChargeController.text) ?? 0;

  double corporateOffer =
      double.tryParse(totalOfferController.text) ?? 0;

  double consumerOffer =
      double.tryParse(txtConsumerOfferController.text) ?? 0;

  double exchange =
      double.tryParse(txtExchangAmtController.text) ?? 0;

  double discount =
      double.tryParse(txtAddDisController.text) ?? 0;

  // Total Offers
  double totalOffers =
      corporateOffer +
      consumerOffer +
      exchange +
      discount;

  // TCS
  double tcsPct = calculateTCS(
    exShowroom,
    totalOffers,
  );

  // On Road Before Offers
  double onRoadWithoutOffers =
      exShowroom +
      insurance +
      rto +
      warranty +
      ewCcpAmount +
      accessories +
      fasTag +
      mcdParking +
      tcsPct;

  // Final On Road
  double onRoad = onRoadWithoutOffers - totalOffers;

  // TCS Text
  tcsPctController.text = tcsPct.toStringAsFixed(0);

  // ==========================
  // Finance Logic
  // ==========================

  // Cash
  if (financeOn == "Cash") {
    loanAmountController.text = "0";
    return;
  }

  // Manual
  if (financeOn == "Manual") {
    if (loanAmountController.text.isEmpty) {
      loanAmountController.text = "0";
    }
    return;
  }

  // ExShowroom / OnRoad
  double baseAmount =
      financeOn == "ExShowroom"
          ? exShowroom
          : onRoad;

  double loanAmount = baseAmount;

  if (percent != null && percent!.isNotEmpty) {
    String cleanPercent = percent!.replaceAll('%', '');

    double loanPer =
        double.tryParse(cleanPercent) ?? 100;

    loanAmount = (baseAmount * loanPer) / 100;
  }

  loanAmountController.text =
      loanAmount.toStringAsFixed(0);
}

// void calculateLoanAmount() {

//   double exShowroom = double.tryParse( exShowroomController.text, ) ?? 0;
//   double insurance = double.tryParse( txtInsAmtController.text, ) ?? 0;
//   double accessories = double.tryParse( txtMGAAmtController.text, ) ?? 0;
//   double rto = double.tryParse( txtRTOAmtController.text, ) ?? 0;
//   double warranty = double.tryParse( txtEWAmountController.text,  ) ?? 0;
//   double ewCcpAmount = double.tryParse( txtCcpAmountController.text,  ) ?? 0;
//   double fasTag = double.tryParse( FastagAmountController.text,  ) ?? 0;
//   double mcdParking = double.tryParse( parkingChargeController.text,  ) ?? 0;
//   double corporateOffer = double.tryParse( totalOfferController.text, ) ?? 0;
//   double consumerOffer = double.tryParse( txtConsumerOfferController.text, ) ?? 0;
//   double exchange = double.tryParse( exShowroomController.text, ) ??  0;
//   double discount = double.tryParse( txtAddDisController.text, ) ?? 0;
//   // ✅ ON ROAD
//   // double onRoad = exShowroom + insurance + accessories + rto + warranty;
//   // double onRoad = corporateOffer + consumerOffer + exchange + discount + ewCcpAmount;
 

//  double  onRoadWithoutOffers =   
//       exShowroom + 
//       insurance + 
//       rto+
//       warranty + 
//       ewCcpAmount + 
//       accessories+
//       fasTag +
//       mcdParking;
//   double  totalOffers = corporateOffer + consumerOffer + exchange + discount;

//  double onRoad = onRoadWithoutOffers - totalOffers;

//   double loanAmount = 0;
//   // ✅ FIRST TIME FULL PRICE
//   if (percent == null || percent!.isEmpty) 
//   {
//     if (financeOn == "ExShowroom") 
//     {
//       loanAmount = exShowroom;
//     }
//     else if (financeOn == "OnRoad") 
//     {
//       loanAmount = onRoad ;
//     }
//     else {
//       loanAmount = onRoad ;
//     }
//   }

//   // ✅ AFTER PERCENT APPLY
//   else {
//     double loanPer = double.tryParse(percent!) ?? 0;
//     if (financeOn == "ExShowroom") {
//       loanAmount = exShowroom ;
//     }
//     else if (financeOn == "OnRoad") {
//       loanAmount = onRoad;
//     }
//     else {
//       loanAmount = onRoad;
//     }
//   }
//   loanAmountController.text = loanAmount.toStringAsFixed(0);
// }




  /// ================= LOGOUT Start =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
 /// ================= LOGOUT End =================
 
Future<String> generatePdfSave(
  QuoteData data,
  int custId,
) async {

  final pdf = pw.Document();  
  final footerBanner = await imageFromAssetBundle(showroomType == 'Nexa'
        ? 'assets/images/newnexalogo.png'
        : 'assets/images/marutinexa.jpeg',
  );

  pdf.addPage(
    pw.Page(

      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(8),
      build: (context) {

        return pw.Container(

          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              width: 1,
              color: PdfColors.black,
            ),
          ),

          child: pw.Column(

            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [

              // =========================
              // HEADER
              // =========================

              pw.Container(
                  color: data.showroomType == 'Nexa'
                  ? PdfColors.black
                  : PdfColors.white,
                padding: const pw.EdgeInsets.all(10),

                child: pw.Column(

                  children: [

                    pw.Row(

                      mainAxisAlignment:  pw.MainAxisAlignment .spaceBetween,
                      crossAxisAlignment:  pw.CrossAxisAlignment.start,

                        children: [
                          pw.Image(
                            footerBanner,
                            width: 50,
                          ),

                          pw.Text(
                            data.showroomType == 'Nexa'
                                ? 'N E X A'
                                : 'MARUTI SUZUKI ARENA',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: data.showroomType == 'Nexa'
                                  ? PdfColors.white
                                  : PdfColors.black,
                            ),
                          ),
                        ],
                    ),
                    //   children: [
                    //     pw.Text(
                    //        pw.Image(
                    //       footerBanner,
                    //       width: 50,
                    //     ),
                          
                    //       style: pw.TextStyle(
                    //       fontWeight: pw.FontWeight.bold,
                    //       fontSize: 12,
                    //       // TEXT COLOR
                    //       color: data.showroomType == 'Nexa' ? PdfColors.white : PdfColors.black,
                    //     ),
                    //   ),
                       
                    //    data.showroomType == 'Nexa' ? 'N E X A'  : 'MARUTI SUZUKI ARENA',

                    //   ],
                    // ),



                    pw.SizedBox(height: 15),

                    pw.Text( "PREM MOTORS PVT. LTD.",

                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 22,
                        color: data.showroomType == 'Nexa' ? PdfColors.white : PdfColors.black,
                      ),
                    ),

                    pw.Text( "(Authorised Maruti Suzuki Dealer)",

                      style: pw.TextStyle(
                      fontSize: 9,
                      color: data.showroomType == 'Nexa' ? PdfColors.white : PdfColors.black,
                    ),
                    ),

                    pw.Text( "Location Address : ${data.locationAddress}",

                      style: pw.TextStyle(
                        fontSize: 8,
                        color: data.showroomType == 'Nexa'
                            ? PdfColors.white
                            : PdfColors.black,
                      ),
                    ),

                    pw.Text(
                    "City : ${data.locationCity}, Pincode : ${data.locationPincode}",

                    style: pw.TextStyle(
                      fontSize: 8,

                      color: data.showroomType == 'Nexa'
                          ? PdfColors.white
                          : PdfColors.black,
                    ),
                  ),

                  pw.Text(
                    "Contact No : ${data.contactPhone} Email : ${data.locationEmail}",

                    style: pw.TextStyle(
                      fontSize: 8,

                      color: data.showroomType == 'Nexa'
                          ? PdfColors.white
                          : PdfColors.black,
                    ),
                  ),

                  pw.Text(
                    "Website : www.premmotors.com",

                    style: pw.TextStyle(
                      fontSize: 8,

                      color: data.showroomType == 'Nexa'
                          ? PdfColors.white
                          : PdfColors.blue,
                    ),
                  ),
                  ],
                ),
              ),





              // =========================
              // CUSTOMER DETAILS
              // =========================

              pw.Table(

                border: pw.TableBorder.all(),

                columnWidths: {

                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                },

                children: [

                  buildRow(
                    "Customer Name: ${data.customerName}",
                    "Quotation Date: ${data.quotationDate}",
                  ),

                  buildRow(
                    "Contact No: ${data.contactNo}",
                    "Email: ${data.email}",
                  ),

                  buildRow(
                    "City: ${data.city}",
                    "Profession Type:${data.professionType}",
                  ),

                  buildRow(
                    "Corporate Name:${data.corporateName}",
                    "Department Name:${data.departmentName}",
                  ),
                ],
              ),

              // =========================
              // RM BAR
              // =========================

              pw.Container(

                color: PdfColors.grey300,

                padding: const pw.EdgeInsets.all(5),

                child: pw.Row(

                  mainAxisAlignment:
                      pw.MainAxisAlignment .spaceBetween,

                  children: [

                    pw.Text(
                      "RM (M.): ${data.rmName} (${data.rmPhone})",

                      style: pw.TextStyle(
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text(
                       "SRM (M.): ${data.srmName} (${data.srmPhone})",
                     
                      style: pw.TextStyle(
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // TITLE
              // =========================

              pw.Center(

                child: pw.Padding(

                  padding: const pw.EdgeInsets.all(5),

                  child: pw.Text(

                    "PERFORMA INVOICE",

                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // =========================
              // VEHICLE DETAILS
              // =========================

              pw.Table(

                border: pw.TableBorder.all(),

                children: [

                  buildRow(
                    "Model With Fuel: ${data.modelWithFuel}",
                    "Variant: ${data.variant}",
                  ),

                  buildRow(
                    "Color: ${data.color}",
                    "Customer/Financier Type: ${data.customerFinancierType}",
                  ),
                ],
              ),

              // =========================
              // PRICE BREAKUP TITLE
              // =========================

              pw.Center(

                child: pw.Padding(

                  padding:
                      const pw.EdgeInsets.all(5),

                  child: pw.Text(

                    "PRICE BREAK-UP",

                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // =========================
              // PRICE TABLE
              // =========================

              pw.Table(

                border: pw.TableBorder.all(),

                children: [

                  priceRow(
                    "Ex-Showroom Price:",
                    data.exShowroom,
                  ),

                  priceRow(
                    "Insurance:",
                    data.insurance,
                  ),

                  priceRow(
                    "RTO",
                    data.rtoAmount,
                  ),

                  priceRow(
                    "Accessories:",
                    data.mgaOrGna,
                  ),

                  priceRow(
                    "Ext.Warranty:",
                    data.ewCcpAmount,
                  ),

                  priceRow(
                    "CCP:",
                    data.Ccp,
                  ),
                  priceRow(
                    "FstTag:",
                    data.fasTag,
                  ),

                  priceRow(
                    "MCD Parking:",
                    data.mcdParking,
                  ),

                 if (data.exShowroom >= 1000000 &&
                    !(data.customerFinancierType ?? '').contains('CSD'))
                  priceRow('1% TCS:', data.tcsPct),
                 

                 
                  highlightRow(
                    "On Road Price Without Offers:",
                    data.onRoadWithoutOffers,
                  ),

                  priceRow(
                    "Corporate Offer:",
                    data.corporateOffer,
                  ),

                  priceRow(
                    "Consumer Offer:",
                    data.consumerOffer,
                  ),

                  priceRow(
                    "Exchange Offer:",
                    data.exchangeOffer,
                  ),

                  priceRow(
                    "Addnl. Discount:",
                    data.addnlDiscount,
                  ),

                  highlightRow(
                    "On Road Price After Applicable Offers:",
                    data.onRoadAfterOffers,
                  ),
                ],
              ),

              // =========================
              // EMI TITLE
              // =========================

              pw.Center(

                child: pw.Padding(

                  padding: const pw.EdgeInsets.all(5),

                  child: pw.Text(

                    "EMI Details",

                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // =========================
              // EMI TABLE
              // =========================

              pw.Table(

                border: pw.TableBorder.all(),

                children: [

                  buildRow(
                    "Finance On: ${data.financeOn}",
                    "Loan Amount: ${data.loanAmount}",
                  ),

                  buildRow(
                    "ROI: ${data.roi}%",
                    "Tenure in Years: ${data.tenureYears}: Months",
                  ),

                  buildRow(
                    "EMI Amount: ${data.emiAmount}",
                    "* ROI Will Subject to change as per CIBIL score.",
                  ),
                ],
              ),

              // =========================
              // TERMS
              // =========================

              pw.Padding(

                padding:const pw.EdgeInsets.all(5),

                child: pw.Column(

                  crossAxisAlignment:pw.CrossAxisAlignment.start,

                  children: [

                    pw.Text(

                      "Terms and Conditions:",

                      style: pw.TextStyle(
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text(
                      "1. All Products are as per company's standard specifications.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),

                    pw.Text(
                      "2. Delivery of Vehicle Model/Color/Variant is subject to availability and force Majure clause or may be delayed due to supply constaints from the Manufacturer Maruti Suzuki India Ltd.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),

                    pw.Text(
                      "3.  Price and Offers are applicable at the time of Invoicing and will be applicable, irrespective when the order was placed and or accepted by us.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),

                    pw.Text(
                      "4.  Delivery will be done with full payment received only either RTGS/NEFT/DD/BANK LOAN PAYMENT. We will not Delivery any Car on short payment in any means.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),

                    pw.Text(
                      "5.  All Disputes Subjected to Location Jurisdiction only.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              // =========================
              // BANK DETAILS
              // =========================

              pw.Padding(

                padding:
                    const pw.EdgeInsets.all(5),

                child: pw.Column(

                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,

                  children: [

                    bankRow(
                      "Bank Name",
                      data.bankName,
                    ),

                    bankRow(
                      "Beneficiary",
                      data.beneficiary,
                    ),

                    bankRow(
                      "Account Number",
                      data.accountNumber,
                    ),

                    bankRow(
                      "IFSC Code",
                      data.ifscCode,
                    ),

                    bankRow(
                      "Branch Name",
                      data.branchName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  final dir = await getApplicationDocumentsDirectory();

  final file = File("${dir.path}/$custId.pdf");

  await file.writeAsBytes(
    await pdf.save(),
  );

  return file.path;
}



// =========================
// TABLE ROW
// =========================

pw.TableRow buildRow(
    String left,
    String right) {

  return pw.TableRow(

    children: [

      pw.Padding(

        padding:const pw.EdgeInsets.all(4),

        child: pw.Text(
          left,
          style: const pw.TextStyle(
            fontSize: 8,
          ),
        ),
      ),

      pw.Padding(

        padding:const pw.EdgeInsets.all(4),

        child: pw.Text(
          right,
          style: const pw.TextStyle(
            fontSize: 8,
          ),
        ),
      ),
    ],
  );
}



// =========================
// PRICE ROW
// =========================

pw.TableRow priceRow(
    String label,
    double value) {

  return pw.TableRow(

    children: [

      pw.Padding(

        padding:const pw.EdgeInsets.all(4),
        child: pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 8,
          ),
        ),
      ),

      pw.Padding(
        padding:const pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment:pw.Alignment.centerRight,
          child: pw.Text(
            value.toStringAsFixed(0),
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
        ),
      ),
    ],
  );
}



// =========================
// HIGHLIGHT ROW
// =========================

pw.TableRow highlightRow(
    String label,
    double value) {

  return pw.TableRow(

    decoration: const pw.BoxDecoration(
      color: PdfColors.grey300,
    ),

    children: [

      pw.Padding(

        padding:
            const pw.EdgeInsets.all(4),

        child: pw.Text(

          label,

          style: pw.TextStyle(
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ),

      pw.Padding(

        padding:
            const pw.EdgeInsets.all(4),

        child: pw.Align(

          alignment:
              pw.Alignment.centerRight,

          child: pw.Text(

            "Rs. ${value.toStringAsFixed(0)}",

            style: pw.TextStyle(
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}



// =========================
// BANK ROW
// =========================

pw.Widget bankRow(
    String label,
    String value) {
  return pw.Padding(
    padding:
        const pw.EdgeInsets.only(
      bottom: 3,
    ),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight:
                  pw.FontWeight.bold,
              fontSize: 8,
            ),
          ),
        ),

        pw.Text(
          ": ",
          style: const pw.TextStyle(
            fontSize: 8,
          ),
        ),

        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.blue,
          ),
        ),
      ],
    ),
  );
}



Future<String> uploadPdf(
    String filePath,
    int custId) async {

  try {

    final data = await apiService.uploadPdf( filePath,
      "$custId.pdf",
    );

    return data!;

  } catch (e) {

    print(
      "UPLOAD ERROR : $e",
    );
    throw Exception(
      "PDF Upload Failed",
    );
  }
}


Future<void> sendWhatsApp(
    String pdfUrl) async {


 String mobileNo = phoneController.text.trim();
  String name = nameController.text.trim();
  // agar user 10 digit dale
  if (mobileNo.length == 10) {
    mobileNo = "91$mobileNo";
  }
  

  var url = Uri.parse(
    "https://wa.dakshconnect.com/api/ac1f17b7-d64d-4815-a493-5d31cf50b799/contact/send-template-message",
  );
  var body = {
    "from_phone_number_id":
        "844506238736342",
    // "phone_number":
    //     "918949682733",
    "phone_number": mobileNo,
    "template_name":
        "purchase_performa",
    "template_language":
        "en_US",
    "templateArgs": {
      "header_document":
          pdfUrl,
      "header_document_name":
          "Quotation",
      // "field_1":
      //     "Mr./Mrs. Harish Saini",
       "field_1": "Mr./Mrs. $name",
      "field_2":
          "most desired car",
      "field_3":
          "Abhishek Manjhi - 9926809870"
    },
    "contact": {
      "first_name":
          "Harish",
      "last_name":
          "Saini"
    }
  };

  var response = await http.post(
    url,
    headers: {
      "Content-Type":"application/json",
      "Authorization":"Bearer tUxEaKK7CtNazzPclhCWVMYpyi8extH7TxDE2h1ikvyEjTbVlTUKLODIj1JA6OL5"
    },
    body: jsonEncode(body),
  );
  print(response.statusCode);
  print(response.body);
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
        "Welcome ! $userName, - $userId",
        style: const TextStyle(color: Colors.white),
      ),
        actions: [
          TextButton(
            // onPressed: () {},
            onPressed: logout,
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.yellow),
            ),
          )
        ],
      ),

      backgroundColor: const Color.fromARGB(213, 13, 13, 13),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(20),

            // decoration: BoxDecoration(
            //   color: const Color(0xFFEFEBD8),
            //   borderRadius: BorderRadius.circular(12),
            // ),
              decoration: BoxDecoration(
                color: showroomType  == "Arena"
                    ? const Color(0xFFEFEBD8)
                    : showroomType  == "Nexa"
                        ?const Color.fromARGB(255, 238, 243, 252)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  
                  // Image.asset("assets/images/logo.png", height: 70),

                 showroomType == 'Nexa'
                  ? Image.asset(
                      "assets/images/newnexalogo.png",
                      height: 70,
                    )
                  : Image.asset(
                      "assets/images/logo.png",
                      height: 70,
                    ),

                  const SizedBox(height: 10),
                  const Text(
                    "Customer Quotations",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                    textField("Name", nameController, icon: Icons.person),
                    const SizedBox(height: 20),
                    textField("Mobile", phoneController, icon: Icons.phone, isPhone: true),
                    const SizedBox(height: 20),
                    // textField("Email", emailController, icon: Icons.email, isEmail: true),
                    textField(
                      "Email",
                      emailController,
                      icon: Icons.email,
                      isEmail: true,
                      isLowerCase: true,
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),
                    textField("City", cityController, icon: Icons.location_city),
                    const SizedBox(height: 20),

                    dropdown("Profession", profession, professionList,
                          (v) => setState(() => profession = v)),
                    const SizedBox(height: 20),

                      dropdown(
                        "Customer Type",
                        customerType,
                        ["Individual", "CSD"],
                        (v) async {
                          setState(() {
                            customerType = v;
                            model = null;
                            modelList.clear();
                          });

                          final prefs = await SharedPreferences.getInstance();
                          final locationCode = prefs.getString("locationCode") ?? "";

                          final models = await apiService.getModelsByCustomerType(
                            v!,
                            locationCode,
                          );

                          setState(() {
                            modelList = models;
                          });
                        },
                      ),
                    
                      const SizedBox(height: 20),

                      dropdown("Model with Fuel", model, modelList, onModelChanged),
                          
                        const SizedBox(height: 20),

                        dropdown(
                          "Variant",
                          selectedVariant,
                          variantList,
                          onVariantChanged,
                        ),
                        const SizedBox(height: 20),
                        dropdown(
                          "Variant Code",
                          selectedVariantCode,
                          variantCodeList,
                          onVariantCodeChanged,
                        ),
                        const SizedBox(height: 20),

                          // dropdown(
                          //   "Colour",
                          //   color,
                          //   colorList,
                          //   (v) => setState(() => color = v),
                          // ),
                          dropdown(
                            "Colour",
                            color,
                            colorList,
                            (v) => setState(() => color = v),
                          ),

                          const SizedBox(height: 20),

                          
                          // textField("Ex Showroom", exShowroomController),
                          textField(
                            "Ex Showroom",
                            exShowroomController,
                            isNumeric: true,
                            maxLength: 8,
                            // enabled: isExshowroomEnabled,
                          ),
                        const SizedBox(height: 20),
                        dropdown(
                          "Insurance",
                          insurance,
                          [
                            "FullPackage",
                            "ZeroDept",
                            "Commercial/Manual",
                            "None"
                          ],
                        (v) async {
                          setState(() {
                            insurance = v;
                            isInsuranceEnabled = v != "None";
                          });

                          final insuranceType = v; // 🔥 clear naming

                          final prefs = await SharedPreferences.getInstance();
                          final locationCode = prefs.getString("locationCode") ?? "";

                          if (model == null) {
                            print("Model missing");
                            return;
                          }

                          try {
                            final amount = await apiService.getInsuranceAmount(
                              model!,
                              locationCode,
                              insuranceType ?? "None",
                            );

                            setState(() {
                              txtInsAmtController.text = amount.toString();
                            });

                          } catch (e) {
                            print("Insurance Error: $e");
                          }
                        }
                        ),
                  const SizedBox(height: 20),                 
                    textField(
                      "Insurance Amount",
                      txtInsAmtController,
                      enabled: isInsuranceEnabled,
                      isNumeric: true,
                      maxLength: 5,
                    ),




                    const SizedBox(height: 20),
                    dropdown(
                    "RTO",
                    rto,
                    [
                      "Same State", 
                      "Other State(Only NCR)",
                      "Commercial/Manual",
                      "TRC",
                    ],
                    (v) async {
                      setState(() {
                        rto = v;

                        // Agar manual entry allow nahi karni hai
                        // isRTOEnabled = false;
                        isRTOEnabled = true;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      final locationCode = prefs.getString("locationCode") ?? "";

                      if (model == null || model!.isEmpty) {
                        print("Model missing");
                        return;
                      }

                      if (v == null || v.isEmpty) {
                        print("RTO type missing");
                        return;
                      }

                      try {
                        final amount = await apiService.getRTOAmout(
                          model!,       // Model Group
                          locationCode, // Location Code
                          rto  ?? "None",           // Same State / Other State(Only NCR) / Commercial/Manual / TRC
                        );

                        setState(() {
                          txtRTOAmtController.text = amount.toStringAsFixed(0);
                        });

                      } catch (e) {
                        print("RTO Error: $e");

                        setState(() {
                          txtRTOAmtController.text = "0";
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  textField(
                    "RTO Amount",
                    txtRTOAmtController,
                    isNumeric: true,
                    enabled: isRTOEnabled,
                    maxLength: 5,
                  ),
                  
                  const SizedBox(height: 20),

                  dropdown(
                    "Accessories",
                    accessories,
                    ["Basic", "Additional", "None"],
                    (v) async {
                      setState(() {
                        accessories = v;

                        // 🔥 LOGIC FIX
                      isAccessoriesEnabled =
                            (v == "Basic" || v == "Additional");
                      });

                      final prefs = await SharedPreferences.getInstance();
                      final locationCode = prefs.getString("locationCode") ?? "";

                      if (v == "Basic" && selectedVariantCode != null) {
                        try {
                          final amount = await apiService.getAccessoriesAmount(
                            selectedVariantCode!,
                            locationCode,
                          );

                          setState(() {
                            txtMGAAmtController.text = amount.toString();
                          });

                        } catch (e) {
                          print("Accessories Error: $e");
                        }
                      }

                      else if (v == "Additional") {
                        setState(() {
                          txtMGAAmtController.text = "0";
                        });
                      }

                      else {
                        setState(() {
                          txtMGAAmtController.text = "0";
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),                 
                    textField(
                    "Accessories Amount",
                    txtMGAAmtController,
                    isNumeric: true,
                    enabled: isAccessoriesEnabled,
                    maxLength: 5,
                  ),
                  


                  const SizedBox(height: 20),
                        dropdown(
                  "Ext.Warranty",
                  warranty,
                  [
                    "Extended Warranty Solitaire",
                    "Extended Warranty Royal Platinum",
                    "Extended Warranty Platinum",
                    "None",
                  ],
                  (v) async {
                    setState(() {
                      warranty = v;
                      isWarrantyEnabled = v != "None";
                    });

                    if (v == "None") {
                      txtEWAmountController.text = "0";
                      return;
                    }

                    try {
                      final prefs = await SharedPreferences.getInstance();

                      final locationCode =
                          prefs.getString("locationCode") ?? "";

                      if (model == null) {
                        print("Model Missing");
                        return;
                      }

                      final amount =
                          await apiService.getExtWarrantyAmount(
                        model!,
                        locationCode,
                        v!,
                      );

                      setState(() {
                        txtEWAmountController.text =
                            amount.toStringAsFixed(0);
                      });

                    } catch (e) {
                      print("Extended Warranty Error: $e");
                    }
                  },
                ),
                const SizedBox(height: 20),                 
                textField(
                  "Ext.Warranty Amount",
                  txtEWAmountController,
                  enabled: isWarrantyEnabled,
                  isNumeric: true,
                  maxLength: 5,
                ),

                  const SizedBox(height: 20),     
                  dropdown(
                    "CCP",
                    Ccp,
                    [
                      "CCP Royal Platinum",
                      "CCP Platinum",
                      "CCP Gold",
                      "None"
                    ],
                    (v) async {
                      setState(() {
                        Ccp = v;
                        isCcpEnabled = v != "None";
                      });

                      if (v == "None") {
                        txtCcpAmountController.text = "0";
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      final locationCode =
                          prefs.getString("locationCode") ?? "";

                      if (model == null) {
                        print("Model missing");
                        return;
                      }

                      try {
                        final amount = await apiService.getCcpAmount(
                          model!,
                          locationCode,
                          v!,
                        );

                        setState(() {
                          txtCcpAmountController.text = amount.toStringAsFixed(0);
                        });

                      } catch (e) {
                        print("CCP Error: $e");
                      }
                    },
                  ),
                  const SizedBox(height: 20),     
                  textField(
                    "CCP Amount",
                    txtCcpAmountController,
                    enabled: isCcpEnabled,
                    isNumeric: true,
                    maxLength: 5,
                  ),


                  const SizedBox(height: 20),

                      dropdown(
                        "FasTag",
                        FasTag,
                        ["Yes", "No"],
                        (v) async {
                          setState(() {
                            FasTag = v;
                          });

                          if (v == "Yes") {

                            final prefs = await SharedPreferences.getInstance();
                            final locationCode =
                                prefs.getString("locationCode") ?? "";

                            if (model == null) {
                              print("Model missing");
                              return;
                            }

                            try {
                              final amount = await apiService.fastagAmount(
                                model!,
                                locationCode,
                              );

                              setState(() {
                                FastagAmountController.text = amount.toStringAsFixed(0);
                              });

                            } catch (e) {
                              print("Fastag Error: $e");
                            }

                          } else {
                            setState(() {
                              FastagAmountController.text = "0";

                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      textField(
                        "FasTag Amount",
                        FastagAmountController,
                        isNumeric: true,
                        enabled: FasTag == "Yes",
                        maxLength: 5,
                      ),
                  

                   const SizedBox(height: 20),
                      dropdown(
                        "MCD Parking Charge (NCR Only)",
                        parkingCharge,
                        ["Yes", "No"],
                        (v) async {
                          setState(() {
                            parkingCharge = v;
                          });

                          if (v == "Yes") {
                            try {
                              final prefs = await SharedPreferences.getInstance();

                              final locationCode =
                                  prefs.getString("locationCode") ?? "";

                              if (model == null || model!.isEmpty) {
                                print("Model not selected");
                                return;
                              }

                              final amount = await apiService.parkingChargeAmount(
                                model!,
                                locationCode,
                              );

                              print("Parking Amount: $amount");

                              setState(() {
                                parkingChargeController.text =
                                    amount.toStringAsFixed(0);
                              });
                            } catch (e) {
                              print("Parking Charge Error: $e");

                              setState(() {
                                parkingChargeController.text = "0";
                              });
                            }
                          } else {
                            setState(() {
                              parkingChargeController.text = "0";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                                          textField(
                        "MCD Parking Charge Amount",
                        parkingChargeController,
                        isNumeric: true,
                        enabled: parkingCharge == "Yes",
                        maxLength: 5,
                      ),
                  
                  const SizedBox(height: 20),
                          dropdown(
                      " Corporate",
                      corporateList.contains(corporate) ? corporate : null,
                      corporateList,
                      (v) async {
                        setState(() {
                          corporate = v;
                          departmentList = []; // clear old
                          department = null;
                        });

                        if (v != null) {
                          await fetchDepartments(v); // 🔥 CALL API
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                  dropdown(
                    " Department",
                    departmentList.contains(department) ? department : null,
                    departmentList,
                    (v) async {
                      if (v == null) return;

                      setState(() {
                        department = v;
                        totalOfferController.clear(); // reset
                      });

                      print("Selected Dept: $v, Model: $model");

                      try {
                        final offer = await apiService.getTotalOffer(model!, v);

                        print("API OFFER: $offer"); // 🔍 check

                        setState(() {
                          totalOfferController.text = offer.toString();
                        });
                      } catch (e) {
                        print("ERROR: $e");
                      }
                    },
                  ),
                     const SizedBox(height: 20),    
                  TextField(
                  controller: totalOfferController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5), 
                  ],
                  decoration: const InputDecoration(
                    labelText: "Corporate Offer",
                    // prefixText: "₹ ",
                    
                    border: OutlineInputBorder(),
                    
                  ),
                ),
               
                    const SizedBox(height: 20),

                    dropdown(
                      "Consumer Offer",
                      consumerOffer,
                      [ "Yes", "No"],
                      (v) async {
                        setState(() {
                          consumerOffer = v;
                          isConsumerOfferEnabled = v == "Yes";
                        });

                        if (v == "Yes" && model != null) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final locationCode =
                                prefs.getString("locationCode") ?? "";

                            final amount = await apiService.getConsumerOffer(
                              model!,          // Model_Group
                              locationCode,    // Location_Code
                            );

                            setState(() {
                              txtConsumerOfferController.text =
                                  amount.toStringAsFixed(0);
                            });
                          } catch (e) {
                            print("Consumer Offer Error: $e");
                          }
                        } else {
                          setState(() {
                            txtConsumerOfferController.text = "0";
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    // textField("Consumer Offer Amt", txtConsumerOfferController, enabled: isConsumerOfferEnabled),
                  textField(
                    "Consumer Offer Amount",
                    txtConsumerOfferController,
                    enabled: isConsumerOfferEnabled,
                    isNumeric: true,
                  ),
                   const SizedBox(height: 20),


                    // dropdown(" Exchange", exchange, ["Select Exchange", "Yes", "No"], (v) {
                    //   setState(() {
                    //     exchange = v;
                    //     isExchangeEnabled = v == "Yes";
                    //     if (!isExchangeEnabled) {
                    //       txtExchangAmtController.clear();
                    //     }
                    //   });
                    // }),

                    dropdown(
                    "Exchange",
                    exchange,
                    [ "Yes", "No"],
                    (v) async {
                      setState(() {
                        exchange = v;
                        isExchangeEnabled = v == "Yes";
                      });

                      if (v == "Yes" && model != null) {
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final locationCode = prefs.getString("locationCode") ?? "";
                          final amount = await apiService.getExchangeOffer(
                            model!,        // Model_Group
                            locationCode,  // Location_Code
                          );

                          setState(() {
                            txtExchangAmtController.text =
                                amount.toStringAsFixed(0);
                          });
                        } catch (e) {
                          print("Exchange Offer Error: $e");
                        }
                      } else {
                        setState(() {
                          txtExchangAmtController.text = "0";
                        });
                      }
                    },
                    ),

                    const SizedBox(height: 20),
                    // textField("Exchange Amt", txtExchangAmtController,enabled: isExchangeEnabled),
                    textField(
                      "Exchange Amount",
                      txtExchangAmtController,
                      enabled: isExchangeEnabled,
                      isNumeric: true,
                    ),
                    
                    const SizedBox(height: 20),
                    dropdown(" Additional Discount", addDiscount, ["Yes", "No"], (v) {
                      setState(() {
                        addDiscount = v;
                        isDiscountEnabled = v == "Yes";
                        if (!isDiscountEnabled) {
                          
                          txtAddDisController.text = "0";

                        }
                      });
                    }),
                    const SizedBox(height: 20),
                    textField(
                      "Discount Amount",
                      txtAddDisController,
                      enabled: isDiscountEnabled,
                      isNumeric: true,
                    ),




                      // textField(
                      //   "Discount Amt",
                      //   txtAddDisController,
                      //    enabled: isDiscountEnabled,
                      // ),
                  // FINANCE SECTION
                  const SizedBox(height: 20),
                  const Text("EMI Calculator",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  dropdown("Financier Type", financier,
                      ["Cash", "Finance"], (v) {
                    setState(() {
                      financier = v;
                      isFinance = v == "Finance";
                      if (!isFinance) clearFinanceFields();
                    });
                  }),

                  const SizedBox(height: 20),
                   dropdown(
                    "Bank",
                    bank,
                    financerNames,   // ✅ API data here
                    isFinance ? (v) => setState(() => bank = v) : null,
                  ),    
                  const SizedBox(height: 20),


                  DropdownButtonFormField<String>(
                  value: tenureController.text.isNotEmpty
                      ? tenureController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: "Tenure",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    '12','24','36','48','60','72','84'
                  ].map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text('$value Months'),
                    );
                  }).toList(),
                  onChanged: isFinance
                  ? (value) {
                      setState(() {
                        tenureController.text = value!;
                      });

                      calculateEMI();
                    }
                  : null,
                ),
                
                 const SizedBox(height: 20),
                   TextFormField(
                    controller: interestController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Rate of Interest",
                    ),
                  ),
                  // textField("Tenure", tenureController, enabled: isFinance),

                  const SizedBox(height: 20),
                  dropdown( "Finance On", financeOn, ["ExShowroom", "OnRoad", "Manual", "Cash"],
                    isFinance
                        ? (v) {
                            setState(() {
                              financeOn = v;
                              // ✅ RESET %
                              percent = null;
                            });
                            calculateLoanAmount();
                          }
                        : null,
                  ),
                 
                  // textField("Loan Amount", loanAmountController, enabled: isFinance),
                     // ✅ Loan %
                  const SizedBox(height: 20),
                  dropdown( "Loan %", percent, ["100", "95", "90", "85", "80", "75", "70"],
                    isFinance
                        ? (v) {
                            setState(() {
                              percent = v;
                            });
                            calculateLoanAmount();
                          }
                        : null,
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                  controller: loanAmountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    calculateEMI();
                  },
                  decoration: const InputDecoration(
                    labelText: "Loan Amount",
                  ),
                ),
                  const SizedBox(height: 20),

                  // textField("EMI", emiController, enabled: isFinance),
                  TextFormField(
                    controller: emiController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "EMI",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                      ElevatedButton(
                    onPressed: () async {
                    try {

                      if (_formKey.currentState!
                          .validate()) {
                        // SAVE DATA
                        int? custId = await saveData();
                        if (custId == null) { return;  }
                        final prefs = await SharedPreferences .getInstance();
                        String locCode =  prefs.getString( "locationCode", ) ?? "";
                        final locationData = await apiService .getLocationByDmsCode( locCode,);
                        // CREATE DATA OBJECT
                        double exShowroom = double.tryParse(exShowroomController.text) ?? 0;
                        double totalOffers =
                            (double.tryParse(totalOfferController.text) ?? 0) +
                            (double.tryParse(txtConsumerOfferController.text) ?? 0) +
                            (double.tryParse(txtExchangAmtController.text) ?? 0) +
                            (double.tryParse(txtAddDisController.text) ?? 0);
                        double tcsPct = calculateTCS(
                          exShowroom,
                          totalOffers,
                        );
                        print("ExShowroom = $exShowroom");
                        print("TotalOffers = $totalOffers");
                        print("TCS = $tcsPct");

                        final data = QuoteData(
                          showroomType: showroomType ?? 'Arena',
                          customerName: nameController.text.trim(),
                          contactNo:phoneController.text.trim(),
                          email:emailController.text.trim(),
                          city:cityController.text.trim(),
                          professionType:profession ?? '',
                          corporateName:corporate ?? '',
                          departmentName:department ?? '',
                          rmName: userName,
                          rmPhone: userId,
                          srmName: teamLeaderName,
                          srmPhone: teamLeaderCont,
                          quotationDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          modelWithFuel:model ?? '',
                          variant: selectedVariant ?? '',
                          color: color ?? '',
                          customerFinancierType: '${customerType ?? "Customer"} / ${financier ?? "Cash"}',
                          exShowroom: double.tryParse(exShowroomController.text,) ?? 0,
                          insurance: double.tryParse( txtInsAmtController.text, ) ??0,
                          ewCcpAmount: double.tryParse( txtEWAmountController.text, ) ?? 0,
                          mgaOrGna: double.tryParse( txtMGAAmtController.text, ) ?? 0,
                          rtoAmount: double.tryParse( txtRTOAmtController.text, ) ?? 0,
                          fasTag: double.tryParse(FastagAmountController.text) ?? 0,
                          Ccp : double.tryParse(txtCcpAmountController.text) ?? 0,
                          mcdParking: double.tryParse(parkingChargeController.text) ?? 0,
                          corporateOffer: double.tryParse( totalOfferController.text,) ?? 0,
                          consumerOffer: double.tryParse( txtConsumerOfferController.text, ) ?? 0,
                          exchangeOffer: double.tryParse( txtExchangAmtController.text, ) ?? 0,
                          addnlDiscount: double.tryParse( txtAddDisController.text, ) ?? 0,
                          financeOn: financier == 'Finance' ? (bank ?? 'Finance')  : 'Cash',
                          loanAmount: double.tryParse( loanAmountController.text, ) ?? 0,
                          roi: double.tryParse(  interestController.text, ) ?? 0,
                          tenureYears: int.tryParse( tenureController.text, ) ?? 0,
                          emiAmount: double.tryParse( emiController.text,  ) ?? 0,
                          locationAddress: locationData['add1'] ?? '',
                          locationCity: locationData['locCity'] ?? '',
                          locationPincode: locationData['pincode'] ?? '',
                          contactPhone: locationData['contactNo'] ?? '',
                          locationEmail: locationData['locEmail'] ?? '',
                          accountNumber: locationData['accountNo'] ?? '',
                          bankName: locationData['bankname'] ?? '',
                          beneficiary: locationData['beneficiary'] ?? '',
                          ifscCode:locationData['ifscCode'] ?? '',
                          branchName: locationData['branchAddress'] ?? '',
                          hpnCharges: 0,
                          tcsPct: tcsPct,
                        );

                        // GENERATE PDF
                        String pdfPath =await generatePdfSave( data, custId, );
                        String pdfUrl = await uploadPdf( pdfPath, custId,);
                      //  String pdfUrl = "http://103.203.224.110/salesapi/uploads/PdfImage/3118.pdf";
                      //  String pdfUrl = "http://192.168.3.71/salesapi/uploads/PdfImage/3118.pdf";
                        // String pdfUrl = "http://103.168.210.89/salesapi/uploads/PdfImage/3118.pdf";
                        // SEND WHATSAPP
                        await sendWhatsApp( pdfUrl, );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "WhatsApp Sent Successfully",
                            ),
                          ),
                        );
                      }

                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "Error : $e",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),

const SizedBox(width: 10),

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
  ),
  onPressed: resetForm,
  child: const Text(
    "Reset",
    style: TextStyle(color: Colors.white),
  ),
),


                const SizedBox(width: 10), // spacing
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),   
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                        final prefs = await SharedPreferences.getInstance();
                        String locCode =prefs.getString("locationCode") ?? "";
                        final locationData =await apiService.getLocationByDmsCode(locCode);

                        final isNexa = showroomType == 'Nexa';

                        double exShowroom = double.tryParse(exShowroomController.text) ?? 0;
                        double totalOffers =
                            (double.tryParse(totalOfferController.text) ?? 0) +
                            (double.tryParse(txtConsumerOfferController.text) ?? 0) +
                            (double.tryParse(txtExchangAmtController.text) ?? 0) +
                            (double.tryParse(txtAddDisController.text) ?? 0);
                        double tcsPct = calculateTCS(
                          exShowroom,
                          totalOffers,
                        );
                        print("ExShowroom = $exShowroom");
                        print("TotalOffers = $totalOffers");
                        print("TCS = $tcsPct");

                        final data = QuoteData(
                            customerName: nameController.text.trim(),
                            contactNo: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            city: cityController.text.trim(),
                            professionType: profession ?? '',
                            corporateName: corporate ?? '',
                            departmentName: department ?? '',
                            rmName: userName,
                            rmPhone: userId,
                            srmName: teamLeaderName,
                            srmPhone: teamLeaderCont,
                            quotationDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            modelWithFuel: model ?? '',
                            variant: selectedVariant ?? '',
                            color: color ?? '',
                            // customerFinancierType: 'Individual / ${financier ?? "Cash"}',
                             customerFinancierType: '${customerType ?? "Customer"} / ${financier ?? "Cash"}',
                            exShowroom: double.tryParse(exShowroomController.text) ?? 0,
                            insurance: double.tryParse(txtInsAmtController.text) ?? 0,
                            ewCcpAmount: double.tryParse(txtEWAmountController.text) ?? 0,
                            Ccp: double.tryParse(txtCcpAmountController.text) ?? 0,
                            mgaOrGna: double.tryParse(txtMGAAmtController.text) ?? 0,
                            rtoAmount: double.tryParse(txtRTOAmtController.text) ?? 0,
                            fasTag: double.tryParse(FastagAmountController.text) ?? 0,
                            mcdParking: double.tryParse(parkingChargeController.text) ?? 0,
                            corporateOffer: double.tryParse(totalOfferController.text) ?? 0,
                            consumerOffer: double.tryParse(txtConsumerOfferController.text) ?? 0,
                            exchangeOffer: double.tryParse(txtExchangAmtController.text) ?? 0,
                            addnlDiscount: double.tryParse(txtAddDisController.text) ?? 0,
                            financeOn: financier == 'Finance' ? (bank ?? 'Finance') : 'Cash',
                            loanAmount: double.tryParse(loanAmountController.text) ?? 0,
                            roi: double.tryParse(interestController.text) ?? 0,
                            tenureYears: int.tryParse(tenureController.text) ?? 0,
                            emiAmount: double.tryParse(emiController.text) ?? 0,
                            showroomType: showroomType ?? 'Arena',
                            locationAddress: locationData['add1'] ?? '',
                            locationCity: locationData['locCity'] ?? '',
                            locationPincode: locationData['pincode'] ?? '',
                            contactPhone:locationData['contactNo'] ?? '',
                            locationEmail: locationData['locEmail'] ?? '',
                            accountNumber: locationData['accountNo'] ?? '',
                            bankName:locationData['bankname'] ?? '',     
                            beneficiary:locationData['beneficiary'] ?? '',
                            ifscCode:locationData['ifscCode'] ?? '',        
                            branchName: locationData['branchAddress'] ?? '',
                            hpnCharges: 0,   
                            tcsPct: tcsPct,
                              );
                          await generatePdf(data);
                        }
                      },
                      // child: Text("Preview $showroomType"),
                      child: Text("Preview"),
                      
                    ),
                  ],

                  
                )






                ],
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}