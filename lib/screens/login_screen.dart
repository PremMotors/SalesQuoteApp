import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sales_quote_arnexa/theme/app_theme.dart';
import 'package:sales_quote_arnexa/main_shell.dart';
import 'package:sales_quote_arnexa/services/auth_service.dart';
import 'package:sales_quote_arnexa/screens/customer_quote_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key });
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;
  ShowroomType _selectedShowroom = ShowroomType.arena;

  late AnimationController _bgController;
  late AnimationController _formController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _formController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _formController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic));
    _formController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _formController.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }




final AuthService _apiService = AuthService();

Future<void> _login() async {
  if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
    setState(() => _errorMsg = 'Please enter username and password');
    return;
  }

  setState(() {
    _loading = true;
    _errorMsg = null;
  });

  try {
    final data = await _apiService.login(
      _userCtrl.text.trim(),
      _passCtrl.text.trim(),
      _selectedShowroom == ShowroomType.arena ? 'arena' : 'nexa',
    );

    if (data != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLogin", true);
      await prefs.setString("token", data['token'] ?? "");

      // ✅ FIXED KEYS
      await prefs.setString("UserName", data['username'] ?? "");
      await prefs.setString("userId", data['userID'] ?? "");
      await prefs.setString("role", data['role'] ?? "");
       await prefs.setString("locationCode", data['loc_Code'] ?? "");
       await prefs.setString("showroomType", data['showroomType'] ?? "");
      // 👉 Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerQuoteScreen(
            userName: data['username'],   // pass here
            // showroomType: data['showroomType'], // pass here
          ),
        ),
      );
    } else {
      setState(() {
        _errorMsg = "Invalid username or password";
        _loading = false;
      });
    }
  } catch (e) {
    print("ERROR → $e"); // 👈 add this for debugging

    setState(() {
      _errorMsg = "Server error or parsing issue";
      _loading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    final isArena = _selectedShowroom == ShowroomType.arena;
    final accentColor = isArena ? AppColors.arenaGold : AppColors.nexaRed;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isArena
                  ? [Color.lerp(AppColors.arenaNavy, AppColors.arenaBlue, _bgController.value)!,
                     Color.lerp(AppColors.arenaBlue, const Color(0xFF1E40AF), _bgController.value)!]
                  : [Color.lerp(AppColors.nexaCharcoal, AppColors.nexaDark, _bgController.value)!,
                     Color.lerp(AppColors.nexaDark, const Color(0xFF0F3460), _bgController.value)!],
            ),
          ),
          child: child,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _logoSection(accentColor, isArena),
                    const SizedBox(height: 40),
                    _showroomToggle(),
                    const SizedBox(height: 32),
                    _loginCard(accentColor, isArena),
                    const SizedBox(height: 24),
                    Text('Powered by Prem Motors Group',
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoSection(Color accentColor, bool isArena) => Column(children: [
    Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: 2),
        gradient: LinearGradient(colors: [accentColor.withOpacity(0.2), accentColor.withOpacity(0.05)]),
      ),
      child: Center(child: Icon(isArena ? Icons.directions_car_rounded : Icons.star_rounded, color: accentColor, size: 36)),
    ),
    const SizedBox(height: 20),
    Text(isArena ? 'ARENA' : 'NEXA',
        style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8)),
    const SizedBox(height: 4),
    Text('Sales Quote Management',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.6), letterSpacing: 1.5)),
    const SizedBox(height: 8),
    Container(width: 50, height: 2, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(1))),
  ]);

  Widget _showroomToggle() => Container(
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12))),
    padding: const EdgeInsets.all(4),
    child: Row(children: [
      _toggleBtn('Arena', ShowroomType.arena, AppColors.arenaGold),
      _toggleBtn('Nexa', ShowroomType.nexa, AppColors.nexaRed),
    ]),
  );

  Widget _toggleBtn(String label, ShowroomType type, Color color) {
    final isSelected = _selectedShowroom == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedShowroom = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
          ),
          child: Center(child: Text(label, style: GoogleFonts.montserrat(
              color: isSelected ? color : Colors.white.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13, letterSpacing: 2))),
        ),
      ),
    );
  }

  Widget _loginCard(Color accentColor, bool isArena) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Welcome Back', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 4),
      Text('Sign in to your account', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.5))),
      const SizedBox(height: 28),
      _inputField(controller: _userCtrl, label: 'Username', icon: Icons.person_outline_rounded, accentColor: accentColor),
      const SizedBox(height: 16),
      _inputField(
        controller: _passCtrl, label: 'Password', icon: Icons.lock_outline_rounded,
        accentColor: accentColor, obscure: _obscure,
        suffix: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white.withOpacity(0.5), size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      // Error message
      if (_errorMsg != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(_errorMsg!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: 12))),
          ]),
        ),
      ],
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: _loading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: isArena ? AppColors.arenaNavy : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : Text('SIGN IN', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ),
      ),
    ]),
  );

  Widget _inputField({required TextEditingController controller, required String label,
      required IconData icon, required Color accentColor, bool obscure = false, Widget? suffix}) {
    return TextFormField(
      controller: controller, obscureText: obscure,
      onFieldSubmitted: (_) => _login(),
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
        suffixIcon: suffix, filled: true, fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor, width: 1.5)),
      ),
    );
  }
}
