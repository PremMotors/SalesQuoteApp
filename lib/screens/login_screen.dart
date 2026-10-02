import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  final authService = AuthService();

Future<void> login() async {
  if (userIdController.text.trim().isEmpty) {
    showMessage("Please enter User ID");
    return;
  }

  if (passwordController.text.trim().isEmpty) {
    showMessage("Please enter Password");
    return;
  }

  setState(() {
    loading = true;
  });

  try {
    final data = await authService.login(
      userIdController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (data != null && data["success"] == true) {
      // =========================================
      // SAVE LOGIN USER DATA
      // =========================================

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        "isLogin",
        true,
      );

      await prefs.setString(
        "userName",
        data["userName"]?.toString() ?? "",
      );

      // Existing quotation code ke liye
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

      print("LOGIN SUCCESS");
      print("User Name: ${data["userName"]}");
      print("User ID: ${data["userId"]}");
      print("Showroom: ${data["showroomType"]}");
      print("Location: ${data["locationName"]}");

      // =========================================
      // GO TO DASHBOARD
      // =========================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    } else {
      showMessage(
        data?["message"]?.toString() ??
            "Invalid User ID or Password",
      );
    }
  } catch (e) {
    if (!mounted) return;

    showMessage(
      e.toString().replaceFirst(
        "Exception: ",
        "",
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void forgotPassword() {
    showMessage('Please contact administrator to reset password.');
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8FAAD6),
      body: Stack(
        children: [

          // ==================================================
          // BACKGROUND DIAGONAL SHAPE
          // ==================================================

          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(),
            ),
          ),

          // ==================================================
          // LOGIN CARD
          // ==================================================

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: Container(
                width: 580,
                constraints: const BoxConstraints(
                  maxWidth: 580,
                ),
                padding: const EdgeInsets.fromLTRB(
                  53,
                  55,
                  53,
                  40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 25,
                      offset: const Offset(8, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // ==================================================
                    // PREM MOTORS LOGO
                    // ==================================================

                    SizedBox(
                      height: 105,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 50,
                                color: Color(0xffe21e2b),
                              ),
                              Text(
                                'PREM MOTORS',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xffe21e2b),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // CUSTOMER QUOTATION TITLE
                    // ==================================================

                    Container(
                      width: double.infinity,
                      height: 66,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xff526E9B),
                        borderRadius:
                            BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Customer Quotation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // USER ID LABEL
                    // ==================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'User ID',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    // ==================================================
                    // USER ID FIELD
                    // ==================================================

                    TextField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      textInputAction:
                          TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            const Color(0xffE7EEF9),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xffC4C4C4),
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xffC4C4C4),
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xff526E9B),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 27),

                    // ==================================================
                    // PASSWORD LABEL
                    // ==================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    // ==================================================
                    // PASSWORD FIELD
                    // ==================================================

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction:
                          TextInputAction.done,
                      onSubmitted: (_) => login(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            const Color(0xffE7EEF9),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xffC4C4C4),
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xffC4C4C4),
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(
                            color: Color(0xff526E9B),
                            width: 2,
                          ),
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton(
                        onPressed:
                            loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff526E9B),
                          disabledBackgroundColor:
                              const Color(0xff526E9B),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // FORGOT PASSWORD
                    // ==================================================

                    GestureDetector(
                      onTap: forgotPassword,
                      child: const Text(
                        'Forgot User Password?',
                        style: TextStyle(
                          color: Color(0xff0645AD),
                          fontSize: 16,
                          decoration:
                              TextDecoration.underline,
                          decorationColor:
                              Color(0xff0645AD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BACKGROUND PAINTER
// ================================================================

class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    // Light blue background
    paint.color = const Color(0xff8FAAD6);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      paint,
    );

    // Dark diagonal bottom-right section
    paint.color = const Color(0xff292929);

    final path = Path();

    path.moveTo(
      size.width * 0.22,
      size.height,
    );

    path.lineTo(
      size.width,
      size.height * 0.55,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.close();

    canvas.drawPath(path, paint);

    // Dark diagonal top-right section
    final topPath = Path();

    topPath.moveTo(
      size.width,
      0,
    );

    topPath.lineTo(
      size.width,
      size.height * 0.22,
    );

    topPath.lineTo(
      size.width * 0.94,
      size.height * 0.28,
    );

    topPath.close();

    canvas.drawPath(
      topPath,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}