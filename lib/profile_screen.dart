import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'package:sales_quote_arnexa/services/api_service.dart';
import 'screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ShowroomType showroomType;
  const ProfileScreen({super.key, required this.showroomType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _statsLoading = true;
  int _totalQuotes = 0;
  int _convertedQuotes = 0;
  String _conversionRate = '0%';

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;
  Color get accent => isArena ? AppColors.arenaGold : AppColors.nexaAccent;

  // ── User info from login session ──────────────────────────────────────────
  String get fullName => ApiService.currentUserName ?? 'User';
  String get role => ApiService.currentRole ?? 'Consultant';
  String get initials => ApiService.userInitials;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final stats = await ApiService.getMyStats();
      if (mounted) setState(() {
        _statsLoading = false;
        _totalQuotes = stats['total'] ?? 0;
        _convertedQuotes = stats['converted'] ?? 0;
        _conversionRate = stats['rate'] ?? '0%';
      });
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  void _confirmLogout() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Sign Out', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            // ApiService.logout(); // ← clear session
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Text('Sign Out', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  void _showChangePasswordSheet() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving = false;
    bool obscureOld = true, obscureNew = true;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Change Password', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _passField(oldCtrl, 'Old Password', obscureOld, () => setSheet(() => obscureOld = !obscureOld)),
              const SizedBox(height: 12),
              _passField(newCtrl, 'New Password', obscureNew, () => setSheet(() => obscureNew = !obscureNew)),
              const SizedBox(height: 12),
              _passField(confirmCtrl, 'Confirm New Password', obscureNew, null),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (newCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error));
                      return;
                    }
                    setSheet(() => saving = true);
                    try {
                      final result = await ApiService.changePassword(oldCtrl.text, newCtrl.text);
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result['success'] == true ? 'Password changed successfully' : result['message'] ?? 'Failed'),
                          backgroundColor: result['success'] == true ? AppColors.success : AppColors.error,
                        ));
                      }
                    } catch (_) { setSheet(() => saving = false); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text('Update Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 30),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('My Profile', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadStats),
              ]),
              const SizedBox(height: 20),

              // ── Avatar (dynamic initials) ──────────────────────────────
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: accent.withOpacity(0.2),
                  border: Border.all(color: accent, width: 2),
                ),
                child: Center(child: Text(initials,
                    style: GoogleFonts.montserrat(color: accent, fontSize: 28, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 14),

              // ── Real name from JWT ─────────────────────────────────────
              Text(fullName, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              Text(role, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(isArena ? 'Arena Showroom' : 'Nexa Showroom',
                    style: GoogleFonts.poppins(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Stats from API ─────────────────────────────────────────
              _statsRow(),
              const SizedBox(height: 20),
              _menuSection('Account', [
                _menuItem(Icons.person_outline_rounded, 'Personal Information', () {}),
                _menuItem(Icons.lock_outline_rounded, 'Change Password', _showChangePasswordSheet),
                _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
              ]),
              const SizedBox(height: 16),
              _menuSection('Showroom', [
                _menuItem(Icons.store_outlined, 'Showroom Details', () {}),
                _menuItem(Icons.group_outlined, 'Team Members', () {}),
                _menuItem(Icons.bar_chart_rounded, 'Performance Report', () {}),
              ]),
              const SizedBox(height: 16),
              _menuSection('App', [
                _menuItem(Icons.help_outline_rounded, 'Help & Support', () {}),
                _menuItem(Icons.info_outline_rounded, 'About App', () {}),
                _menuItem(Icons.logout_rounded, 'Sign Out', _confirmLogout, color: AppColors.error),
              ]),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _statsRow() {
    if (_statsLoading) return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    return Row(children: [
      _statCard(_totalQuotes.toString(), 'Quotes', Icons.receipt_long_rounded),
      const SizedBox(width: 12),
      _statCard(_convertedQuotes.toString(), 'Converted', Icons.check_circle_rounded),
      const SizedBox(width: 12),
      _statCard(_conversionRate, 'Rate', Icons.trending_up_rounded),
    ]);
  }

  Widget _statCard(String value, String label, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _menuSection(String title, List<Widget> items) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Text(title.toUpperCase(), style: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
      ),
      ...items,
    ]),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final itemColor = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (color ?? primary).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color ?? primary),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: itemColor, fontWeight: FontWeight.w500))),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ]),
      ),
    );
  }

  Widget _passField(TextEditingController ctrl, String label, bool obscure, VoidCallback? onToggle) =>
      TextFormField(controller: ctrl, obscureText: obscure,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(labelText: label,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
              suffixIcon: onToggle != null
                  ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18, color: AppColors.textSecondary), onPressed: onToggle)
                  : null,
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
}
