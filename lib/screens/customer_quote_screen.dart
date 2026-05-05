import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_quote_arnexa/screens/login_screen.dart';
import 'package:sales_quote_arnexa/screens/pdf_screen.dart';
import 'package:sales_quote_arnexa/services/auth_service.dart';
import 'package:sales_quote_arnexa/models/price_model.dart';

class CustomerQuoteScreen extends StatefulWidget {
  final String userName;
  const CustomerQuoteScreen({super.key, required this.userName});
  @override
  State<CustomerQuoteScreen> createState() => _CustomerQuoteScreenState();
}

class _CustomerQuoteScreenState extends State<CustomerQuoteScreen> {
  /// FORM KEY
  final _formKey = GlobalKey<FormState>();
   String userName = "";
   String userId = "";
   String? locationCode;
   String? showroomType = "";
  //  final String modelGroup;
  /// 🔹 BASIC CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();

  /// 🔹 PRICE CONTROLLERS
  final exShowroomController = TextEditingController();
  final txtCorporateOfferController = TextEditingController();
  final txtInsAmtController = TextEditingController();
  final txtMGAAmtController = TextEditingController();
  final txtRTOAmtController = TextEditingController();
  final txtEWAmountController = TextEditingController();
  final txtConsumerOfferController = TextEditingController();
  final txtExchangAmtController = TextEditingController();
  final txtAddDisController = TextEditingController();

  /// 🔹 FINANCE CONTROLLERS
  final tenureController = TextEditingController();
  final interestController = TextEditingController();
  final loanAmountController = TextEditingController();
  final emiController = TextEditingController();

  /// 🔹 DROPDOWN VARIABLES
  String? customerType, model;
  String? color, profession, corporate, department, parking;
  String? fastag, insurance, accessories, rto, warranty;
  String? consumerOffer, exchange, addDiscount;
  String? financier, bank, financeOn, percent;
  bool isFinance = false;
 
  /// 🔹 LISTS
  
  /// LISTS
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
  bool isConsumerOfferEnabled = false;
  bool isExchangeEnabled = false;
  bool isDiscountEnabled = false;
  List<String> corporateList = [];
  double totalOffer = 0;
  final totalOfferController = TextEditingController();
  String? parkingCharge;
 
  

 /// ================= API LOAD =================
final AuthService apiService = AuthService();
void loadData() async {
  allData = await apiService.getAllData();

  modelList = allData
      .map((e) => e.modelGroup)
      .toSet()
      .toList();

  setState(() {});
}
Future<void> onModelChanged(String? v) async {
  if (v == null) return;
  setState(() {
    model = v;
    variantList = allData
        .where((e) => e.modelGroup == v)
        .map((e) => e.description)
        .toSet()
        .toList();

    selectedVariant = null;
    selectedVariantCode = null;
    departmentList = [];   // 🔥 clear old data
    department = null;
    corporateList = [];   // 🔥 clear old data
    corporate = null;
  });
   
  // 🔥 CALL API AFTER STATE UPDATE
  await fetchCorporate(v);
}
void loadFinancers() async {
  financerNames = await apiService.getFinancerNames();
  // financerNames = await getFinancerNames();
  setState(() {});
}
void onVariantChanged(String? v) {
  selectedVariant = v;

  // 🔹 Filter variant codes
  var filtered = allData
      .where((e) =>
          e.modelGroup == model &&
          e.description == v)
      .toList();

  variantCodeList = filtered
      .map((e) => e.modelWithType)
      .toSet()
      .toList();

  // 🔥 AUTO FILL Ex Showroom (take first item)
  if (filtered.isNotEmpty) {
    exShowroomController.text =
        filtered.first.exShowroom.toString();
  }

  selectedVariantCode = null;
  colorList = [];

  setState(() {});
}

void onVariantCodeChanged(String? v) async {
  if (v == null) return;
  selectedVariantCode = v;
  // 🔥 Load colors from API
  colorList = await apiService.getColors(v);
  colorList.insert(0, "Select Colour");
  color = "Select Colour";
  setState(() {});
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


Future<void> saveData() async {
  if (!_formKey.currentState!.validate()) return;

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
    "ExShowroomPrice":
        double.tryParse(exShowroomController.text) ?? 0,
    "CorporateName": corporate,
    "DeptName": department,
    "MCDParkingCharges": parking == "Yes" ? 1 : 0,
    "CorporateOffer":
        double.tryParse(txtCorporateOfferController.text) ?? 0,
    "InsurancePer": 0,
    "FastTag": fastag == "Yes" ? 1 : 0,
    "InsuranceAmt":
        double.tryParse(txtInsAmtController.text) ?? 0,
    "AccessoriesPer": 0,
    "AccessoriesAmt":
        double.tryParse(txtMGAAmtController.text) ?? 0,
    "RTOPer": 0,
    "RTOAmt":
        double.tryParse(txtRTOAmtController.text) ?? 0,
    "WarrantyPer": 0,
    "WarrantyAmt":
        double.tryParse(txtEWAmountController.text) ?? 0,
    "ConsumerOffer": 0,
    "ConsumerOfferAmt":
        double.tryParse(txtConsumerOfferController.text) ?? 0,
     "ExchangePer": 0,
    "ExchangeAmt":
        double.tryParse(txtExchangAmtController.text) ?? 0,
    "AdditionalDisAmt":
        double.tryParse(txtAddDisController.text) ?? 0,
    "FinanceBank": bank,
    "Tenure": int.tryParse(tenureController.text) ?? 0,
    "InterestType": interestController.text,
    "LoanPer": double.tryParse(
            percent?.replaceAll("%", "") ?? "0") ??
        0,
    "Loanamount":
        double.tryParse(loanAmountController.text) ?? 0,
    "EMI": double.tryParse(emiController.text) ?? 0,
    "IsActive": true
  };

  final success = await apiService.submitData(body);
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Data Saved Successfully")),
    );

    void clearForm() {
    // 🔹 Text fields
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    cityController.clear();
    exShowroomController.clear();
    txtCorporateOfferController.clear();
    txtInsAmtController.clear();
    txtMGAAmtController.clear();
    txtRTOAmtController.clear();
    txtEWAmountController.clear();
    txtConsumerOfferController.clear();
    txtExchangAmtController.clear();
    txtAddDisController.clear();
    tenureController.clear();
    interestController.clear();
    loanAmountController.clear();
    emiController.clear();

  // 🔹 Dropdowns reset
  setState(() {
    customerType = null;
    model = "Select Model With Fuel";
    selectedVariant = "Select Variant Name";
    selectedVariantCode = "Select Variant Code";
    color = null;
    profession = null;
    corporate = null;
    department = null;
    parking = null;
    fastag = null;
    insurance = null;
    accessories = null;
    rto = null;
    warranty = null;
    consumerOffer = null;
    exchange = null;
    addDiscount = null;
    financier = null;
    bank = null;
    financeOn = null;
    percent = null;
    isFinance = false;
  });
} // reset form
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Failed to save data")),
    );
  }
}

  @override
  void initState() {
    super.initState();
    loadData();
    loadUserData();
    loadFinancers();
    txtAddDisController.text = "0";
    txtExchangAmtController.text = "0";
    txtConsumerOfferController.text ="0";
  }

  List<String> professionList = 
  [
    "Select Profession Type",
    "Farmers", 
    "HouseWife",
    "NRI",
    "Other",
    "Proprietor/Trade",
    "Retired",
    "Salaried Govt.",
    "Salaried Private",
    "Student"
  ];



  /// 🔹 TEXTFIELD
 Widget textField(
  String label,
  TextEditingController controller, {
  bool enabled = true,
  bool isPhone = false,
  IconData? icon,
  bool isEmail = false,
  bool isRequired = true, // 🔥 NEW ADD
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    keyboardType: isPhone ? TextInputType.number : TextInputType.text,
    inputFormatters: isPhone
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
        : [],
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade300,
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      // 🔥 KEY LOGIC
      if (!enabled) return null; // disabled → no validation

      if (isRequired && (value == null || value.isEmpty)) {
        return "$label required";
      }

      if (isPhone && value!.length != 10) {
        return "Phone must be 10 digits";
      }

      if (isEmail && value != null && value.isNotEmpty) {
        final regex =
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!regex.hasMatch(value)) {
          return "Invalid email";
        }
      }

      return null;
    },
  );
}




Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    userName = prefs.getString("UserName") ?? "";
     userId = prefs.getString("userId") ?? "";
     showroomType = prefs.getString("showroomType") ?? "";
  });
}

  /// 🔹 DROPDOWN
  Widget dropdown(String label, String? value, List<String> items,
      Function(String?)? onChange) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      hint: Text(label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChange,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
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
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
        "Welcome ! $userName - $userId",
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
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBD8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  Image.asset("assets/images/logo.png", height: 70),
                  const SizedBox(height: 10),

                  const Text(
                    "Customer Quotation",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                    textField("Name", nameController, icon: Icons.person),
                    const SizedBox(height: 20),
                    textField("PhoneNo", phoneController, icon: Icons.phone, isPhone: true),
                    const SizedBox(height: 20),
                    textField("Email", emailController, icon: Icons.email, isEmail: true),
                    const SizedBox(height: 20),
                    textField("City", cityController, icon: Icons.location_city),
                    const SizedBox(height: 20),


                          dropdown(
                            "Select Customer Type",
                            customerType,
                            ["Select Customer Type", "Individual", "CSD"],
                            (v) {
                              setState(() {
                                customerType = v;
                              });
                            },
                          ),
                          const SizedBox(height: 20),



                          dropdown("Select Model", model, modelList, onModelChanged),
                          const SizedBox(height: 20),


                          dropdown(
                            "Select Variant",
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
                          dropdown(
                            "Select Colour",
                            color,
                            colorList,
                            (v) => setState(() => color = v),
                          ),


                      const SizedBox(height: 20),

                      
                      textField("Ex Showroom", exShowroomController),
                      const SizedBox(height: 20),


                      dropdown("Profession", profession, professionList,
                          (v) => setState(() => profession = v)),
                      const SizedBox(height: 20),
                     

                    dropdown(
                      "Select Corporate",
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
                    "Select Department",
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
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Total",
                    prefixText: "₹ ",
                    border: OutlineInputBorder(),
                  ),
                ),


                       const SizedBox(height: 20),

                      dropdown(
                        "Select MCD Parking Charge(NCR Only)",
                        parkingCharge,
                        ["Select MCD Parking Charge(NCR Only)", "Yes", "No"],
                        (v) {
                          setState(() {
                            parkingCharge = v;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      dropdown(
                        "Select Fastag",
                        fastag,
                        ["Select Fastag", "Yes", "No"],
                        (v) {
                          setState(() {
                            fastag = v;
                          });
                        },
                      ),


                    const SizedBox(height: 20),
                    dropdown(
                      "Select Insurance",
                      insurance,
                      ["Select Insurance", "FullPackage", "ZeroDept", "Commercial/Manual", "None"],
                      (v) async {
                        setState(() {
                          insurance = v;
                          isInsuranceEnabled = v == "FullPackage"; // ✅ correct condition
                        });

                        // ✅ API call only for FullPackage
                        if (v == "FullPackage" && selectedVariantCode != null) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final locationCode = prefs.getString("locationCode") ?? "";

                            final amount = await apiService.getInsuranceAmount(
                              selectedVariantCode!, // model_with_Type
                              locationCode,         // Location_Code
                            );

                            setState(() {
                              txtInsAmtController.text = amount.toString(); // ✅ AUTO FILL
                            });

                          } catch (e) {
                            print("Insurance Error: $e");
                          }
                        } else {
                          txtInsAmtController.clear();
                        }
                      },
                    ),           
                  const SizedBox(height: 20),                 
                    textField(
                      "Insurance Amt",
                      txtInsAmtController,
                      enabled: isInsuranceEnabled,
                    ),




                  const SizedBox(height: 20),
                   dropdown(
                      "Select Accessories",
                      accessories,
                      ["Select Accessories", "Basic", "Additional","None"],
                      (v) async {
                        setState(() {
                          accessories = v;
                          isAccessoriesEnabled = v == "Basic"; // ✅ correct condition
                        });

                        // ✅ API call only for FullPackage
                        if (v == "Basic" && selectedVariantCode != null) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final locationCode = prefs.getString("locationCode") ?? "";

                            final amount = await apiService.getAccessoriesAmount(
                              selectedVariantCode!, // model_with_Type
                              locationCode,         // Location_Code
                            );

                            setState(() {
                              txtMGAAmtController.text = amount.toString(); // ✅ AUTO FILL
                            });

                          } catch (e) {
                            print("Accessories Error: $e");
                          }
                        } else {
                          txtMGAAmtController.clear();
                        }
                      },
                    ),           
                  const SizedBox(height: 20),                 
                    textField(
                      "Accessories Amt",
                      txtMGAAmtController,
                      enabled: isAccessoriesEnabled,
                    ),

                    const SizedBox(height: 20),
                    dropdown(
                      "Select RTO",
                      rto,
                      ["Select RTO", "Same State", "Other State(Only NCR)", "Commercial/Manual/TRC"],
                      (v) {
                        setState(() {
                          rto = v;
                        });

                        if (selectedVariantCode == null) return;

                        var data = allData.firstWhere(
                          (e) => e.modelWithType == selectedVariantCode,
                        );

                        // 🔥 SAME STATE → RTO_Permanent
                        if (v == "Same State") {
                          setState(() {
                            isRTOEnabled = false;
                            txtRTOAmtController.text = data.rtOPermanent.toString();
                          });
                        }

                        // 🔥 OTHER STATE → OtherStateRTO
                        else if (v == "Other State(Only NCR)") {
                          setState(() {
                            isRTOEnabled = false;
                            txtRTOAmtController.text = data.otherStateRTO.toString();
                          });
                        }

                        // 🔥 COMMERCIAL → disable + clear
                        else if (v == "Commercial/Manual/TRC") {
                          setState(() {
                            isRTOEnabled = false;
                            txtRTOAmtController.text = "0";
                          });
                        }

                        // 🔥 DEFAULT
                        else {
                          setState(() {
                            isRTOEnabled = false;
                            txtRTOAmtController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    textField(
                      "RTO Amt",
                      txtRTOAmtController,
                      enabled: isRTOEnabled,
                    ),


                    const SizedBox(height: 20),

                    dropdown(
                      "Select Ext.Warranty",
                      warranty,
                      [
                        "Select Ext.Warranty",
                        "EW 6Yr With CCP 2Yr",
                        "EW 6Yr Without CCP",
                        "EW 5Yr With CCP 2Yr",
                        "EW 5Yr Without CCP",
                        "None"
                      ],
                      (v) async {

                        setState(() {
                          warranty = v;
                        });

                        if (selectedVariantCode == null) return;

                        String ewType = "";
                        String ccpType = "";

                        // 👉 Mapping (AUTO — user doesn’t select this)
                        switch (v) {
                          case "EW 6Yr With CCP 2Yr":
                            ewType = "EW_Platinum_4th_Year";
                            ccpType = "CCPPlatinum";
                            break;

                          case "EW 6Yr Without CCP":
                            ewType = "EW_Platinum_4th_Year";
                            break;

                          case "EW 5Yr With CCP 2Yr":
                            ewType = "EW_Royal_5th_Year";
                            ccpType = "CCPPlatinum";
                            break;

                          case "EW 5Yr Without CCP":
                            ewType = "EW_Royal_5th_Year";
                            break;

                          case "None":
                            setState(() {
                              isWarrantyEnabled = false;
                              txtEWAmountController.text = "0";
                            });
                            return;

                          default:
                            setState(() {
                              isWarrantyEnabled = false;
                              txtEWAmountController.clear();
                            });
                            return;
                        }

                        // 🔥 CALL API (no manual ew/ccp input)
                        final amount = await apiService.getWarrantyAmount(
                          selectedVariantCode!,
                          ewType,
                          ccpType,
                        );

                        setState(() {
                          isWarrantyEnabled = false;
                          txtEWAmountController.text = amount.toString();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    textField(
                      "Warranty Amt",
                      txtEWAmountController,
                      enabled: isWarrantyEnabled,
                    ),
                    




                    const SizedBox(height: 20),
                    dropdown("Select Consumer Offer", consumerOffer, ["Select Consumer Offer", "Yes", "No"], (v) {
                      setState(() {
                        consumerOffer = v;
                        isConsumerOfferEnabled = v == "Yes";

                        if (!isConsumerOfferEnabled) {
                          txtConsumerOfferController.clear();
                        }
                      });
                    }),
                    const SizedBox(height: 20),
                    textField("Consumer Offer Amt", txtConsumerOfferController,
                        enabled: isConsumerOfferEnabled),


                    const SizedBox(height: 20),
                    dropdown("Select Exchange", exchange, ["Select Exchange", "Yes", "No"], (v) {
                      setState(() {
                        exchange = v;
                        isExchangeEnabled = v == "Yes";

                        if (!isExchangeEnabled) {
                          txtExchangAmtController.clear();
                        }
                      });
                    }),
                    const SizedBox(height: 20),
                    textField("Exchange Amt", txtExchangAmtController,
                        enabled: isExchangeEnabled),


                    const SizedBox(height: 20),
                    dropdown("Select Additional Discount", addDiscount, ["Select Additional Discount", "Yes", "No"], (v) {
                      setState(() {
                        addDiscount = v;
                        isDiscountEnabled = v == "Yes";

                        if (!isDiscountEnabled) {
                          txtAddDisController.clear();
                        }
                      });
                    }),
                    const SizedBox(height: 20),

                      textField(
                        "Discount Amt",
                        txtAddDisController,
                         enabled: isDiscountEnabled,
                      ),


                  

                  // FINANCE SECTION
                   const SizedBox(height: 20),
                  const Text("EMI Calculator",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  dropdown("Financier", financier,
                      ["Cash", "Finance"], (v) {
                    setState(() {
                      financier = v;
                      isFinance = v == "Finance";
                      if (!isFinance) clearFinanceFields();
                    });
                  }),
                  const SizedBox(height: 20),
                   dropdown(
                    "Select Bank",
                    bank,
                    financerNames,   // ✅ API data here
                    isFinance ? (v) => setState(() => bank = v) : null,
                  ),
                  // dropdown("Bank", bank,
                  //     ["HDFC", "ICICI", "SBI"],
                  //     isFinance ? (v) => setState(() => bank = v) : null),

                      
                  const SizedBox(height: 20),

                  textField("Tenure", tenureController, enabled: isFinance),
                  const SizedBox(height: 20),


                  dropdown("Finance On", financeOn,
                        ["ExShowroom", "OnRoad" ,"Manual","Cash"],
                        isFinance ? (v) => setState(() => financeOn = v) : null),
                    const SizedBox(height: 20),


                  textField("Interest", interestController, enabled: isFinance),
                  const SizedBox(height: 20),

                     // ✅ Loan %
                    dropdown("Loan %", percent,
                        ["100", "95", "90","85", "80", "75","70"],
                        isFinance ? (v) => setState(() => percent = v) : null),

                  const SizedBox(height: 20),
                  textField("Loan Amount", loanAmountController, enabled: isFinance),
                  const SizedBox(height: 20),
                  textField("EMI", emiController, enabled: isFinance),

                  const SizedBox(height: 20),


                  Row(
                  mainAxisAlignment: MainAxisAlignment.end, 
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveData();
                        }
                      },
                      child: const Text("Submit"),
                    ),

                    const SizedBox(width: 10), // spacing
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      // onPressed: () {
                      //   if (_formKey.currentState!.validate()) {
                      //      generatePdf();
                      //   }
                      // },
                      onPressed: () async {
  if (_formKey.currentState!.validate()) {
    final isNexa = showroomType == 'Nexa';
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
      srmName: '',
      srmPhone: '',
      quotationDate: DateTime.now().toString(),
      modelWithFuel: model ?? '',
      variant: selectedVariant ?? '',
      // variantCode: selectedVariantCode ?? '',
      color: color ?? '',
      customerFinancierType: 'Individual / ${financier ?? "Cash"}',
      exShowroom: double.tryParse(exShowroomController.text) ?? 0,
      insurance: double.tryParse(txtInsAmtController.text) ?? 0,
      ewCcpAmount: double.tryParse(txtEWAmountController.text) ?? 0,
      mgaOrGna: double.tryParse(txtMGAAmtController.text) ?? 0,
      rtoAmount: double.tryParse(txtRTOAmtController.text) ?? 0,
      fasTag: fastag == 'Yes' ? 600 : 0,
      mcdParking: parkingCharge == 'Yes' ? 2500 : 0,
      corporateOffer: double.tryParse(txtCorporateOfferController.text) ?? 0,
      consumerOffer: double.tryParse(txtConsumerOfferController.text) ?? 0,
      exchangeOffer: double.tryParse(txtExchangAmtController.text) ?? 0,
      addnlDiscount: double.tryParse(txtAddDisController.text) ?? 0,
      financeOn: financier == 'Finance' ? (bank ?? 'Finance') : 'Cash',
      loanAmount: double.tryParse(loanAmountController.text) ?? 0,
      roi: double.tryParse(interestController.text) ?? 0,
      tenureYears: int.tryParse(tenureController.text) ?? 0,
      emiAmount: double.tryParse(emiController.text) ?? 0,
      showroomType: showroomType ?? 'Arena',
      locationAddress: isNexa
          ? 'Survey No. 54/207 Gopalpura Flyover Near Manav Ashram, Tonk Road, Gopal Pura'
          : 'Ajmer Pulia, GopalbariJaipur-302006',
      locationCity: 'Jaipur',
      locationPincode: isNexa ? '302018' : '302006',
      contactPhone: isNexa ? '8929782575' : '8929268096',
      locationEmail: isNexa
          ? 'nexajpr.tdm@premmotors.com'
          : 'cp.sales@premmotors.com',
      accountNumber: isNexa ? '50200029573580' : '50200029378770',


      bankName: 'HDFC BANK LTD.',       // ✅ FIXED
  beneficiary: 'M/S PREM MOTORS',   // ✅ FIXED
  // accountNumber: '1234567890',
  ifscCode: 'HDFC0001585',          // ✅ FIXED
  branchName: 'JAIPUR',

  hpnCharges: 0,   // ✅ FIXED
  tcsPct: 0, 
    );
    await generatePdf(data);
  }
},

                      // child: const Text("Preview",$showroomType ),
                      child: Text("Preview $showroomType"),
                      
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