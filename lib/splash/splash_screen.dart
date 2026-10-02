import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pmpl_salesquote/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLogin;

  const SplashScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 5),
      _goToLogin,
    );
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isMobile = size.width < 600;

    // ============================================================
    // CARD WIDTH
    // ============================================================

    final double cardWidth = isMobile
        ? size.width * 0.90
        : 560;

    // ============================================================
    // LOGO SIZE
    // ============================================================

    final double logoWidth = isMobile
        ? 180
        : 220;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
            ),

            child: Container(
              width: cardWidth,

              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 25 : 45,
                vertical: isMobile ? 35 : 45,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.10),

                    blurRadius: 30,

                    spreadRadius: 2,

                    offset: const Offset(
                      0,
                      12,
                    ),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  // ==================================================
                  // LOGO
                  // ==================================================

                  SizedBox(
                    height: isMobile ? 110 : 130,

                    child: Image.asset(
                      "assets/images/logo.png",

                      width: logoWidth,

                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // WELCOME
                  // ==================================================

                  Text(
                    "Welcome to",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: isMobile ? 21 : 24,

                      color:
                          const Color(0xff777777),

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // PREM MOTORS
                  // ==================================================

                  Text(
                    "PREM MOTORS",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize:
                          isMobile ? 32 : 40,

                      fontWeight:
                          FontWeight.w800,

                      color: Colors.black,

                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // TAGLINE
                  // ==================================================

                  Text(
                    "Caring for you... Always!",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize:
                          isMobile ? 16 : 18,

                      color:
                          const Color(0xff777777),

                      fontStyle:
                          FontStyle.italic,

                      fontWeight:
                          FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 38),

                  // ==================================================
                  // LOADING
                  // ==================================================

                  const SizedBox(
                    width: 38,
                    height: 38,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,

                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        Color(0xff111111),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // LOADING TEXT
                  // ==================================================

                  const Text(
                    "Loading...",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,

                      color:
                          Color(0xff999999),

                      fontWeight:
                          FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // DIVIDER
                  // ==================================================

                  Container(
                    width: 100,
                    height: 1,

                    color:
                        const Color(0xffEEEEEE),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // APP NAME
                  // ==================================================

                  const Text(
                    "Sales Quote Management",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 13,

                      color:
                          Color(0xffAAAAAA),

                      letterSpacing: 0.5,

                      fontWeight:
                          FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}