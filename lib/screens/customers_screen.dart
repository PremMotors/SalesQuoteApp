import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CustomersScreen extends StatefulWidget {
  final ShowroomType showroomType;
  const CustomersScreen({super.key, required this.showroomType});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<dynamic> _customers = [];
  int _total = 0;

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;

  @override
  void initState() { super.initState(); _loadCustomers(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadCustomers({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getCustomers(search: search);
      if (mounted) setState(() {
        _loading = false;
        if (result['success'] == true) {
          final data = result['data'];
          _customers = data['data'] ?? [];
          _total = data['total'] ?? 0;
        } else {
          _error = result['message'] ?? 'Failed to load customers';
        }
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Server connection error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: dark,
        title: Text('Customers ($_total)',
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => _loadCustomers()),
          IconButton(icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              onPressed: () => _showAddCustomerSheet()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => _loadCustomers(search: v.isNotEmpty ? v : null),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name or mobile...',
                hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.4), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.5), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () { _searchCtrl.clear(); _loadCustomers(); })
                    : null,
                filled: true, fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.6)),
                  const SizedBox(height: 12),
                  Text(_error!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadCustomers, child: const Text('Retry')),
                ]))
              : _customers.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline, size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('No customers found', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _customers.length,
                      itemBuilder: (context, i) => _customerCard(_customers[i]),
                    ),
    );
  }

  Widget _customerCard(Map<String, dynamic> c) {
    final colors = [primary, AppColors.success, AppColors.warning, AppColors.error, AppColors.nexaRed];
    final colorIndex = (c['customerId'] ?? 0) % colors.length;
    final color = colors[colorIndex];
    final name = c['name'] ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 46, height: 46,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text(initials,
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: color)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Row(children: [
            Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(c['mobile'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${c['city'] ?? ''}, ${c['state'] ?? ''}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ])),
        Column(children: [
          // WhatsApp quick action
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 16)),
          ),
          const SizedBox(height: 6),
          // Quotes count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${c['totalQuotes'] ?? 0} quotes',
                style: GoogleFonts.poppins(color: primary, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  void _showAddCustomerSheet() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Add New Customer', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _sheetField(nameCtrl, 'Full Name *', Icons.person_outline),
            const SizedBox(height: 12),
            _sheetField(mobileCtrl, 'Mobile Number *', Icons.phone_outlined, inputType: TextInputType.phone),
            const SizedBox(height: 12),
            _sheetField(emailCtrl, 'Email', Icons.email_outlined, inputType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _sheetField(cityCtrl, 'City', Icons.location_on_outlined),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: saving ? null : () async {
                  if (nameCtrl.text.isEmpty || mobileCtrl.text.isEmpty) return;
                  setSheetState(() => saving = true);
                  try {
                    final result = await ApiService.createCustomer({
                      'name': nameCtrl.text.trim(),
                      'mobile': mobileCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                      'state': 'Rajasthan',
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      if (result['success'] == true) {
                        _loadCustomers();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Customer added successfully'),
                                backgroundColor: AppColors.success));
                      }
                    }
                  } catch (_) { setSheetState(() => saving = false); }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text('Add Customer', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, IconData icon, {TextInputType? inputType}) =>
      TextFormField(controller: ctrl, keyboardType: inputType,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(labelText: label,
              prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
}
