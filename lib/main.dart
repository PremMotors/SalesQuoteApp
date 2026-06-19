import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:pmpl_salesquote/theme/app_theme.dart';
import 'package:pmpl_salesquote/screens/login_screen.dart';
import 'package:pmpl_salesquote/screens/customer_quote_screen.dart';
=======
import 'package:sales_quote_arnexa/theme/app_theme.dart';
import 'package:sales_quote_arnexa/screens/login_screen.dart';
import 'package:sales_quote_arnexa/screens/customer_quote_screen.dart';
>>>>>>> 3c3e8268674e7fa0c9a0abfba205afc34835c983
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();
  bool isLogin = prefs.getBool("isLogin") ?? false;

  runApp(SalesQuoteApp(isLogin: isLogin));
}

class SalesQuoteApp extends StatelessWidget {
  final bool isLogin;

  const SalesQuoteApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalesQuote ArNexa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // 🔹 LOGIN CHECK
      home: isLogin
<<<<<<< HEAD
          ? CustomerQuoteScreen(userName: "", teamLeaderName: "", teamLeaderCont: "")
=======
          ? CustomerQuoteScreen(userName: "")
>>>>>>> 3c3e8268674e7fa0c9a0abfba205afc34835c983
          : const LoginScreen(),
    );
  }
}