import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'add_quotation_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ============================================================
  // NAVIGATION
  // ============================================================

  int selectedIndex = 0;

  // ============================================================
  // USER DATA
  // ============================================================

  String userName = "";
  String userType = "";
  String userId = "";
  String showroomType = "";
  String locationCode = "";
  String locationName = "";

  // ============================================================
  // SHOWROOM THEME
  // ============================================================

  bool get isNexa =>
      showroomType.trim().toUpperCase() == "NEXA";

  bool get isArena =>
      showroomType.trim().toUpperCase() == "ARENA";

  Color get dashboardBackgroundColor {
    if (isNexa) {
      return const Color(0xffEEF6FF);
    }

    if (isArena) {
      return const Color(0xfffff3f3);
    }

    return const Color(0xffF1F6FC);
  }

  Color get primaryColor {
    if (isNexa) {
      return const Color(0xff123B66);
    }

    if (isArena) {
      return const Color(0xffB5121B);
    }

    return const Color(0xff145DA0);
  }

  List<Color> get headerGradient {
    if (isNexa) {
      return const [
        Color(0xff0B1F33),
        Color(0xff123B66),
      ];
    }

    if (isArena) {
      return const [
        Color(0xff4A68B9),
        Color(0xff6158E2),
      ];
    }

    return const [
      Color(0xff145DA0),
      Color(0xff1F66B2),
    ];
  }

  // ============================================================
  // DASHBOARD SUMMARY
  // ============================================================

  int totalQuotations = 0;
  int cashQuotations = 0;
  int financeQuotations = 0;
  int individualCustomers = 0;
  int csdCustomers = 0;

  bool isDashboardLoading = false;
  String dashboardError = "";

  // ============================================================
  // RECENT QUOTATIONS
  // ============================================================

  bool isQuotationsLoading = false;
  String quotationsError = "";

  List<Map<String, dynamic>> recentQuotations = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      userName = prefs.getString("userName") ?? "";

      userId = prefs.getString("userId") ?? "";

      userType = prefs.getString("userType") ??
          prefs.getString("role") ??
          "";

      showroomType =
          prefs.getString("showroomType") ?? "";

      locationName =
          prefs.getString("locationName") ?? "";

      locationCode =
          prefs.getString("locationCode") ?? "";
    });

    // Dashboard summary API
    await loadDashboardSummary();

    // Recent quotations API
    await loadRecentQuotations();
  }

  // ============================================================
  // DASHBOARD SUMMARY API
  //
  // GET:
  // /api/dashboard-summary?userId={userId}
  // ============================================================

  Future<void> loadDashboardSummary() async {
    if (userId.trim().isEmpty) {
      debugPrint(
        "DASHBOARD SUMMARY: userId is empty",
      );
      return;
    }

    if (mounted) {
      setState(() {
        isDashboardLoading = true;
        dashboardError = "";
      });
    }

    try {
      debugPrint(
        "========================================",
      );
      debugPrint(
        "DASHBOARD SUMMARY API",
      );
      debugPrint(
        "USER ID: $userId",
      );
      debugPrint(
        "========================================",
      );

      final uri = Uri.parse(
        // "https://premerp.in/salesquote/api/dashboard-summary",
        "http://103.168.210.85:4005/api/dashboard-summary",

      ).replace(
        queryParameters: {
          "userId": userId.trim(),
        },
      );

      debugPrint(
        "DASHBOARD SUMMARY URL = $uri",
      );

      final apiResponse = await http.get(
        uri,
        headers: const {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      debugPrint(
        "DASHBOARD SUMMARY STATUS = "
        "${apiResponse.statusCode}",
      );

      debugPrint(
        "DASHBOARD SUMMARY BODY = "
        "${apiResponse.body}",
      );

      if (apiResponse.statusCode != 200) {
        throw Exception(
          "Dashboard Summary API failed: "
          "${apiResponse.statusCode} "
          "${apiResponse.body}",
        );
      }

      final decoded =
          jsonDecode(apiResponse.body);

      if (decoded is! Map) {
        throw Exception(
          "Invalid dashboard summary response",
        );
      }

      final response =
          Map<String, dynamic>.from(decoded);

      if (response["success"] != true) {
        throw Exception(
          response["message"]?.toString() ??
              "Dashboard summary failed",
        );
      }

      final dynamic rawSummary =
          response["summary"] ?? response;

      final Map<String, dynamic> summary =
          rawSummary is Map
              ? Map<String, dynamic>.from(
                  rawSummary,
                )
              : <String, dynamic>{};

      int toInt(dynamic value) {
        if (value is int) {
          return value;
        }

        if (value is num) {
          return value.toInt();
        }

        return int.tryParse(
              value?.toString() ?? "0",
            ) ??
            0;
      }

      if (!mounted) return;

      setState(() {
        totalQuotations = toInt(
          summary["TotalQuotations"],
        );

        cashQuotations = toInt(
          summary["CashQuotations"],
        );

        financeQuotations = toInt(
          summary["FinanceQuotations"],
        );

        individualCustomers = toInt(
          summary["IndividualCustomer"],
        );

        csdCustomers = toInt(
          summary["CSDCustomer"],
        );

        isDashboardLoading = false;
        dashboardError = "";
      });

      debugPrint(
        "TOTAL QUOTATIONS = $totalQuotations",
      );

      debugPrint(
        "CASH QUOTATIONS = $cashQuotations",
      );

      debugPrint(
        "FINANCE QUOTATIONS = $financeQuotations",
      );

      debugPrint(
        "INDIVIDUAL CUSTOMER = "
        "$individualCustomers",
      );

      debugPrint(
        "CSD CUSTOMER = $csdCustomers",
      );
    } catch (e) {
      debugPrint(
        "DASHBOARD SUMMARY ERROR = $e",
      );

      if (!mounted) return;

      setState(() {
        isDashboardLoading = false;
        dashboardError = e.toString();
      });
    }
  }

  // ============================================================
  // RECENT QUOTATIONS API
  //
  // GET:
  // /api/quotations?userId={userId}
  // ============================================================

  Future<void> loadRecentQuotations() async {
    if (userId.trim().isEmpty) {
      debugPrint(
        "QUOTATIONS API: userId is empty",
      );
      return;
    }

    if (mounted) {
      setState(() {
        isQuotationsLoading = true;
        quotationsError = "";
      });
    }

    try {
      debugPrint(
        "========================================",
      );

      debugPrint(
        "RECENT QUOTATIONS API",
      );

      debugPrint(
        "USER ID: $userId",
      );

      debugPrint(
        "========================================",
      );

      final uri = Uri.parse(
        // "https://premerp.in/salesquote/api/quotations",
        "http://103.168.210.85:4005/api/quotations",
        
      ).replace(
        queryParameters: {
          "userId": userId.trim(),
        },
      );

      debugPrint(
        "QUOTATIONS URL = $uri",
      );

      final apiResponse = await http.get(
        uri,
        headers: const {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      debugPrint(
        "QUOTATIONS STATUS = "
        "${apiResponse.statusCode}",
      );

      debugPrint(
        "QUOTATIONS BODY = "
        "${apiResponse.body}",
      );

      if (apiResponse.statusCode != 200) {
        throw Exception(
          "Quotations API failed: "
          "${apiResponse.statusCode} "
          "${apiResponse.body}",
        );
      }

      final decoded =
          jsonDecode(apiResponse.body);

      List<dynamic> rawList = [];

      // --------------------------------------------------------
      // CASE 1:
      // API directly returns List
      // --------------------------------------------------------

      if (decoded is List) {
        rawList = decoded;
      }

      // --------------------------------------------------------
      // CASE 2:
      // API returns object
      // --------------------------------------------------------

      else if (decoded is Map) {
        final map =
            Map<String, dynamic>.from(decoded);

        if (map["data"] is List) {
          rawList = map["data"];
        } else if (map["quotations"] is List) {
          rawList = map["quotations"];
        } else if (map["result"] is List) {
          rawList = map["result"];
        } else if (map["items"] is List) {
          rawList = map["items"];
        }
      }

      final List<Map<String, dynamic>>
          quotationList = [];

      for (final item in rawList) {
        if (item is Map) {
          quotationList.add(
            Map<String, dynamic>.from(item),
          );
        }
      }

      // Latest 5 quotations
      final latestQuotations =
          quotationList.take(5).toList();

      if (!mounted) return;

      setState(() {
        recentQuotations =
            latestQuotations;

        isQuotationsLoading = false;

        quotationsError = "";
      });

      debugPrint(
        "RECENT QUOTATIONS COUNT = "
        "${recentQuotations.length}",
      );
    } catch (e) {
      debugPrint(
        "RECENT QUOTATIONS ERROR = $e",
      );

      if (!mounted) return;

      setState(() {
        isQuotationsLoading = false;

        quotationsError = e.toString();

        recentQuotations = [];
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String getCurrentDate() {
    final now = DateTime.now();

    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return "${weekdays[now.weekday - 1]}, "
        "${now.day.toString().padLeft(2, '0')} "
        "${months[now.month - 1]} "
        "${now.year}";
  }

  // ============================================================
  // GREETING
  // ============================================================

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void onBottomNavigationTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ============================================================
  // ADD QUOTATION
  // ============================================================

  void openAddQuotation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddQuotationPage(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildQuotationPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor:
          dashboardBackgroundColor,

      body: SafeArea(
        child: pages[selectedIndex],
      ),

      bottomNavigationBar:
          buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // HOME PAGE
  // ============================================================

  Widget buildHomePage() {
    return RefreshIndicator(
      onRefresh: loadUserData,
      child: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: buildTopHeader(),
          ),

          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              30,
            ),
            sliver: SliverList(
              delegate:
                  SliverChildListDelegate(
                [
                  buildWelcomeSection(),

                  const SizedBox(
                    height: 18,
                  ),

                  buildStatistics(),

                  const SizedBox(
                    height: 18,
                  ),

                  buildQuickActions(),

                  const SizedBox(
                    height: 18,
                  ),

                  buildRecentQuotations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget buildTopHeader() {
    return Container(
      height: 70,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: headerGradient,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: showAppMenu,
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Center(
              child: Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error,
                          stackTrace) {
                    return const Center(
                      child: Text(
                        "PREM MOTORS",
                        style: TextStyle(
                          color:
                              Color(0xffD71920),
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons
                      .notifications_none,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment:
                      Alignment.center,
                  decoration:
                      const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget buildWelcomeSection() {
    String shortName = "U";

    if (userName.isNotEmpty) {
      shortName = userName
          .split(" ")
          .where(
            (e) => e.isNotEmpty,
          )
          .take(2)
          .map(
            (e) => e[0],
          )
          .join()
          .toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        8,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style:
                      const TextStyle(
                    color:
                        Color(0xff26384F),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                RichText(
                  text:
                      TextSpan(
                    children: [
                      TextSpan(
                        text: userName
                                .isEmpty
                            ? "User"
                            : userName,
                        style:
                            const TextStyle(
                          color:
                              Color(0xff145DA0),
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      TextSpan(
                        text: showroomType
                                .isNotEmpty
                            ? " ($showroomType)"
                            : "",
                        style:
                            const TextStyle(
                          color:
                              Color(0xff303030),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  getCurrentDate(),
                  style:
                      const TextStyle(
                    color:
                        Color(0xff667085),
                    fontSize: 14,
                  ),
                ),

                if (locationCode
                    .isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      "$locationCode • "
                      "$locationName",
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Color(0xff667085),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            width: 64,
            height: 64,
            decoration:
                const BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  Color(0xff1976D2),
                  Color(0xff0D47A1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment:
                Alignment.center,
            child: Text(
              shortName,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget buildStatistics() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.only(
            left: 3,
            bottom: 10,
          ),
          child: Text(
            "Overview",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xff102A43),
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: statisticCard(
                title:
                    "Total\nQuotations",
                value:
                    totalQuotations,
                icon:
                    Icons.description_outlined,
                iconColor:
                    const Color(
                  0xff1976D2,
                ),
                backgroundColor:
                    const Color(
                  0xffE8F3FF,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: statisticCard(
                title:
                    "Cash\nQuotations",
                value:
                    cashQuotations,
                icon:
                    Icons.currency_rupee,
                iconColor:
                    const Color(
                  0xff16A05D,
                ),
                backgroundColor:
                    const Color(
                  0xffE9F9F0,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: statisticCard(
                title:
                    "Finance\nQuotations",
                value:
                    financeQuotations,
                icon:
                    Icons.bar_chart,
                iconColor:
                    const Color(
                  0xffF59E0B,
                ),
                backgroundColor:
                    const Color(
                  0xfffff5df,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          children: [
            Expanded(
              child: statisticCard(
                title:
                    "Individual\nCustomer",
                value:
                    individualCustomers,
                icon:
                    Icons.person,
                iconColor:
                    const Color(
                  0xff7C3AED,
                ),
                backgroundColor:
                    const Color(
                  0xffF2ECFF,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: statisticCard(
                title:
                    "CSD\nCustomer",
                value:
                    csdCustomers,
                icon:
                    Icons.groups,
                iconColor:
                    const Color(
                  0xffE11D48,
                ),
                backgroundColor:
                    const Color(
                  0xffffedf2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATISTIC CARD
  // ============================================================

  Widget statisticCard({
    required String title,
    required int value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 118,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 25,
          ),

          const Spacer(),

          Text(
            title,
            maxLines: 2,
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  Color(0xff344054),
              height: 1.1,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget buildQuickActions() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xff102A43),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              Expanded(
                child: quickAction(
                  title:
                      "Add\nQuotation",
                  icon:
                      Icons.add_circle,
                  color:
                      const Color(
                    0xff1683E8,
                  ),
                  onTap:
                      openAddQuotation,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: quickAction(
                  title:
                      "My\nQuotations",
                  icon:
                      Icons.list_alt,
                  color:
                      const Color(
                    0xff16A05D,
                  ),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION ITEM
  // ============================================================

  Widget quickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 105,
        decoration:
            BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:
                  color.withOpacity(
                0.25,
              ),
              blurRadius: 8,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(0.2),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              maxLines: 2,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECENT QUOTATIONS
  // ============================================================

  Widget buildRecentQuotations() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ----------------------------------------------------
          // HEADER
          // ----------------------------------------------------

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Recent Quotations",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xff102A43),
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color:
                        Color(0xff1565C0),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (isQuotationsLoading)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 35,
              ),
              child:
                  CircularProgressIndicator(),
            )

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          else if (quotationsError
              .isNotEmpty)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xfffff5f5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .error_outline,
                    size: 40,
                    color:
                        Colors.red,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    "Unable to load quotations.",
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    quotationsError,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ElevatedButton(
                    onPressed:
                        loadRecentQuotations,
                    child:
                        const Text(
                      "Retry",
                    ),
                  ),
                ],
              ),
            )

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          else if (recentQuotations
              .isEmpty)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 30,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffF8FAFC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xffE8F3FF),
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        const Icon(
                      Icons
                          .description_outlined,
                      size: 32,
                      color:
                          Color(0xff1976D2),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    "No quotations found.",
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xff102A43),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    "Manage customer quotations for your location.",
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Color(0xff667085),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )

          // ----------------------------------------------------
          // QUOTATION LIST
          // ----------------------------------------------------

          else
            Column(
              children:
                  recentQuotations
                      .map(
                (
                  quotation,
                ) {
                  return buildRecentQuotationItem(
                    quotation,
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT QUOTATION ITEM
  // ============================================================

  Widget buildRecentQuotationItem(
    Map<String, dynamic> quotation,
  ) {
    String getValue(
      List<String> keys,
    ) {
      for (final key in keys) {
        if (quotation[key] != null &&
            quotation[key]
                .toString()
                .trim()
                .isNotEmpty) {
          return quotation[key]
              .toString();
        }
      }

      return "-";
    }

    final custId = getValue([
      "CUSTID",
      "CustId",
      "custId",
      "CustomerId",
      "customerId",
    ]);

    final location = getValue([
      "Location",
      "location",
      "LocationCode",
      "locationCode",
    ]);

    final customerName =
        getValue([
      "CustomerName",
      "customerName",
      "Customer_Name",
      "Name",
      "name",
    ]);

    final phoneNumber =
        getValue([
      "PhoneNumber",
      "phoneNumber",
      "Phone",
      "phone",
      "Mobile",
      "mobile",
    ]);

    final customerType =
        getValue([
      "CustomerType",
      "customerType",
      "Customer_Type",
    ]);

    final variantDescription =
        getValue([
      "VariantDescription",
      "variantDescription",
      "Variant_Description",
      "Variant",
      "variant",
    ]);

    final loanType = getValue([
      "LoanType",
      "loanType",
      "Loan_Type",
    ]);

    final onRoadPrice =
        getValue([
      "OnRoadPrice",
      "onRoadPrice",
      "On_Road_Price",
      "OnRoad",
    ]);

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF8FAFC),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // TOP ROW
          // ----------------------------------------------------

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffE8F3FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons
                      .description_outlined,
                  color:
                      Color(0xff1976D2),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Color(
                          0xff102A43,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      "$variantDescription • "
                      "$customerType",
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Color(
                          0xff667085,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                "₹$onRoadPrice",
                style:
                    const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xff16A05D),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          const Divider(
            height: 1,
            color:
                Color(0xffE2E8F0),
          ),

          const SizedBox(
            height: 10,
          ),

          // ----------------------------------------------------
          // DETAILS
          // ----------------------------------------------------

          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              quotationDetail(
                Icons.badge_outlined,
                "CUSTID",
                custId,
              ),

              quotationDetail(
                Icons.location_on_outlined,
                "Location",
                location,
              ),

              quotationDetail(
                Icons.phone_outlined,
                "Phone",
                phoneNumber,
              ),

              quotationDetail(
                Icons
                    .account_balance_outlined,
                "Loan",
                loanType,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUOTATION DETAIL
  // ============================================================

  Widget quotationDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color:
              const Color(0xff64748B),
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          "$title: ",
          style:
              const TextStyle(
            fontSize: 11,
            color:
                Color(0xff64748B),
          ),
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xff334155),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUOTATION PAGE
  // ============================================================

  Widget buildQuotationPage() {
    return Scaffold(
      backgroundColor:
          dashboardBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            primaryColor,
        foregroundColor:
            Colors.white,
        title: const Text(
          "Quotations",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                openAddQuotation,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body:
          isQuotationsLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : recentQuotations
                      .isEmpty
                  ? Center(
                      child:
                          Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons
                                .description_outlined,
                            size: 70,
                            color:
                                Color(
                              0xff1976D2,
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            "My Quotations",
                            style:
                                TextStyle(
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            "No quotations found.",
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          ElevatedButton
                              .icon(
                            onPressed:
                                openAddQuotation,
                            icon:
                                const Icon(
                              Icons.add,
                            ),
                            label:
                                const Text(
                              "Add Quotation",
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xff145DA0,
                              ),
                              foregroundColor:
                                  Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          loadRecentQuotations,
                      child:
                          ListView
                              .builder(
                        padding:
                            const EdgeInsets
                                .all(
                          16,
                        ),
                        itemCount:
                            recentQuotations
                                .length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          return buildRecentQuotationItem(
                            recentQuotations[
                                index],
                          );
                        },
                      ),
                    ),
    );
  }

  // ============================================================
  // PROFILE PAGE
  // ============================================================

  Widget buildProfilePage() {
    return Scaffold(
      backgroundColor:
          dashboardBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            primaryColor,
        foregroundColor:
            Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),

            CircleAvatar(
              radius: 42,
              backgroundColor:
                  primaryColor,
              child: Text(
                userName.isNotEmpty
                    ? userName[0]
                        .toUpperCase()
                    : "U",
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              userName.isEmpty
                  ? "User"
                  : userName,
              style:
                  const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              userType.isEmpty
                  ? "-"
                  : userType,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            profileItem(
              Icons.person_outline,
              "User Name",
              userName,
            ),

            profileItem(
              Icons.badge_outlined,
              "User ID",
              userId,
            ),

            profileItem(
              Icons.badge_outlined,
              "User Type",
              userType,
            ),

            profileItem(
              Icons.store_outlined,
              "Showroom",
              showroomType,
            ),

            profileItem(
              Icons.location_on_outlined,
              "Location Code",
              locationCode,
            ),

            profileItem(
              Icons.location_city_outlined,
              "Location Name",
              locationName,
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton.icon(
                onPressed: logout,
                icon:
                    const Icon(
                  Icons.logout,
                ),
                label:
                    const Text(
                  "Logout",
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget profileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                primaryColor,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value.isEmpty
                      ? "-"
                      : value,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget buildBottomNavigationBar() {
    return NavigationBar(
      height: 68,
      selectedIndex:
          selectedIndex,
      backgroundColor:
          Colors.white,
      indicatorColor:
          isNexa
              ? const Color(
                  0xffDCEBFA,
                )
              : isArena
                  ? const Color(
                      0xffffdfe1,
                    )
                  : const Color(
                      0xffE4F0FF,
                    ),
      onDestinationSelected:
          onBottomNavigationTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon:
              Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(
            Icons
                .description_outlined,
          ),
          selectedIcon: Icon(
            Icons.description,
          ),
          label: "Quotations",
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon: Icon(
            Icons.person,
          ),
          label: "Profile",
        ),
      ],
    );
  }

  // ============================================================
  // SIDE MENU
  // ============================================================

  void showAppMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey
                        .shade300,
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                menuItem(
                  Icons
                      .add_circle_outline,
                  "Add Quotation",
                  () async {
                    Navigator.pop(
                      context,
                    );

                    await Navigator
                        .push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddQuotationPage(),
                      ),
                    );

                    // Refresh after
                    // returning
                    await loadRecentQuotations();
                    await loadDashboardSummary();
                  },
                ),

                menuItem(
                  Icons
                      .description_outlined,
                  "My Quotations",
                  () {
                    Navigator.pop(
                      context,
                    );

                    setState(() {
                      selectedIndex =
                          1;
                    });
                  },
                ),

                menuItem(
                  Icons.person_outline,
                  "Profile",
                  () {
                    Navigator.pop(
                      context,
                    );

                    setState(() {
                      selectedIndex =
                          2;
                    });
                  },
                ),

                menuItem(
                  Icons.logout,
                  "Logout",
                  () {
                    Navigator.pop(
                      context,
                    );

                    logout();
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color =
        const Color(0xff145DA0),
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              FontWeight.w600,
          color: color == Colors.red
              ? Colors.red
              : const Color(
                  0xff263238,
                ),
        ),
      ),
      trailing:
          const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
    );
  }
}