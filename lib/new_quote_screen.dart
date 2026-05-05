import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class NewQuoteScreen extends StatefulWidget {
  final ShowroomType showroomType;
  const NewQuoteScreen({super.key, required this.showroomType});
  @override
  State<NewQuoteScreen> createState() => _NewQuoteScreenState();
}

class _NewQuoteScreenState extends State<NewQuoteScreen> with TickerProviderStateMixin {
  int _step = 0;
  late PageController _pageController;

  // Step 1 — Customer
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _selectedState = 'Rajasthan';
  int? _existingCustomerId;
  bool _lookingUpCustomer = false;

  // Step 2 — Vehicle
  List<dynamic> _vehicles = [];
  bool _vehiclesLoading = true;
  Map<String, dynamic>? _selectedVehicle;

  // Step 3 — Pricing
  final _rtoCtrl = TextEditingController(text: '0');
  final _insuranceCtrl = TextEditingController(text: '0');
  final _accessoriesCtrl = TextEditingController(text: '0');
  final _extWarrantyCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController(text: '0');
  final _exchangeCtrl = TextEditingController(text: '0');
  final _corpDiscountCtrl = TextEditingController(text: '0');

  bool _saving = false;

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;
  Color get accent => isArena ? AppColors.arenaGold : AppColors.nexaAccent;

  double get totalOnRoad {
    if (_selectedVehicle == null) return 0;
    final base = (_selectedVehicle!['exShowroomPrice'] ?? 0).toDouble();
    return base
        + (double.tryParse(_rtoCtrl.text) ?? 0)
        + (double.tryParse(_insuranceCtrl.text) ?? 0)
        + 500  // FASTag
        + (double.tryParse(_accessoriesCtrl.text) ?? 0)
        + (double.tryParse(_extWarrantyCtrl.text) ?? 0)
        - (double.tryParse(_discountCtrl.text) ?? 0)
        - (double.tryParse(_exchangeCtrl.text) ?? 0)
        - (double.tryParse(_corpDiscountCtrl.text) ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadVehicles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose(); _mobileCtrl.dispose(); _emailCtrl.dispose(); _cityCtrl.dispose();
    _rtoCtrl.dispose(); _insuranceCtrl.dispose(); _accessoriesCtrl.dispose();
    _extWarrantyCtrl.dispose(); _discountCtrl.dispose(); _exchangeCtrl.dispose(); _corpDiscountCtrl.dispose();
    super.dispose();
  }

  // ── Load vehicles from API ────────────────────────────────────────────────
  Future<void> _loadVehicles() async {
    setState(() => _vehiclesLoading = true);
    try {
      final result = await ApiService.getVehicles(
          showroomType: isArena ? 'Arena' : 'Nexa');
      if (mounted) setState(() {
        _vehiclesLoading = false;
        if (result['success'] == true) _vehicles = result['data'] ?? [];
      });
    } catch (e) {
      if (mounted) setState(() => _vehiclesLoading = false);
    }
  }

  // ── Auto-fill customer by mobile ──────────────────────────────────────────
  Future<void> _lookupCustomer(String mobile) async {
    if (mobile.length != 10) return;
    setState(() => _lookingUpCustomer = true);
    try {
      final result = await ApiService.searchCustomerByMobile(mobile);
      if (mounted && result['success'] == true) {
        final c = result['data'];
        setState(() {
          _existingCustomerId = c['customerId'];
          _nameCtrl.text = c['name'] ?? '';
          _emailCtrl.text = c['email'] ?? '';
          _cityCtrl.text = c['city'] ?? '';
          if (c['state'] != null) _selectedState = c['state'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Customer found: ${c['name']}'),
                backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
      } else {
        setState(() => _existingCustomerId = null);
      }
    } catch (_) {}
    if (mounted) setState(() => _lookingUpCustomer = false);
  }

  void _nextStep() {
    if (_step == 0 && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter customer name')));
      return;
    }
    if (_step == 1 && _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _saveQuote();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  // ── SAVE QUOTE TO API ─────────────────────────────────────────────────────
  Future<void> _saveQuote() async {
    setState(() => _saving = true);
    try {
      // Step 1: Create or reuse customer
      int customerId;
      if (_existingCustomerId != null) {
        customerId = _existingCustomerId!;
      } else {
        final custResult = await ApiService.createCustomer({
          'name': _nameCtrl.text.trim(),
          'mobile': _mobileCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _selectedState,
        });
        if (custResult['success'] != true) {
          throw Exception(custResult['message'] ?? 'Failed to create customer');
        }
        customerId = custResult['data']['customerId'];
      }

      // Step 2: Create quote
      final quoteResult = await ApiService.createQuote({
        'customerId': customerId,
        'vehicleId': _selectedVehicle!['vehicleId'],
        'showroomType': isArena ? 'Arena' : 'Nexa',
        'exShowroomPrice': (_selectedVehicle!['exShowroomPrice'] ?? 0).toDouble(),
        'rto': double.tryParse(_rtoCtrl.text) ?? 0,
        'insurance': double.tryParse(_insuranceCtrl.text) ?? 0,
        'fastTag': 500,
        'accessories': double.tryParse(_accessoriesCtrl.text) ?? 0,
        'extendedWarranty': double.tryParse(_extWarrantyCtrl.text) ?? 0,
        'cashDiscount': double.tryParse(_discountCtrl.text) ?? 0,
        'exchangeBonus': double.tryParse(_exchangeCtrl.text) ?? 0,
        'corporateDiscount': double.tryParse(_corpDiscountCtrl.text) ?? 0,
      });

      if (!mounted) return;
      setState(() => _saving = false);

      if (quoteResult['success'] == true) {
        final qNum = quoteResult['data']?['quoteNumber'] ?? '';
        _showSuccessDialog(qNum);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(quoteResult['message'] ?? 'Failed to create quote'),
            backgroundColor: AppColors.error));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showSuccessDialog(String quoteNumber) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48)),
        const SizedBox(height: 16),
        Text('Quote Created!', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Quote $quoteNumber has been created successfully.',
            textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Share', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)))),
        ]),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final steps = ['Customer', 'Vehicle', 'Pricing'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: dark,
        title: Text('New Quote', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: _step == 0 ? null : _prevStep),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(children: steps.asMap().entries.map((entry) {
              final i = entry.key; final label = entry.value;
              final isActive = i == _step; final isDone = i < _step;
              return Expanded(child: Row(children: [
                if (i > 0) Expanded(child: Container(height: 2,
                    color: isDone || isActive ? accent : Colors.white.withOpacity(0.2))),
                Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.success : isActive ? accent : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                    child: Center(child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : Text('${i + 1}', style: GoogleFonts.poppins(
                            color: isActive ? dark : Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: GoogleFonts.poppins(fontSize: 9,
                      color: isActive ? accent : Colors.white.withOpacity(0.5),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                ]),
                if (i < steps.length - 1) Expanded(child: Container(height: 2,
                    color: isDone ? accent : Colors.white.withOpacity(0.2))),
              ]));
            }).toList()),
          ),
        ),
      ),
      body: Column(children: [
        Expanded(child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_customerStep(), _vehicleStep(rupee), _pricingStep(rupee)],
        )),
        _bottomBar(),
      ]),
    );
  }

  // ── Step 1: Customer ──────────────────────────────────────────────────────
  Widget _customerStep() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Customer Information', 'Enter or search customer details'),
      const SizedBox(height: 24),
      // Mobile first — auto-lookup
      _field(_mobileCtrl, 'Mobile Number *', Icons.phone_outlined,
          inputType: TextInputType.phone,
          onChanged: (v) { if (v.length == 10) _lookupCustomer(v); },
          suffix: _lookingUpCustomer ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)) : null),
      const SizedBox(height: 14),
      if (_existingCustomerId != null)
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withOpacity(0.3))),
          child: Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 16), const SizedBox(width: 8),
            Text('Existing customer found & auto-filled', style: GoogleFonts.poppins(color: AppColors.success, fontSize: 12))]),
        ),
      _field(_nameCtrl, 'Customer Name *', Icons.person_outline),
      const SizedBox(height: 14),
      _field(_emailCtrl, 'Email Address', Icons.email_outlined, inputType: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _field(_cityCtrl, 'City', Icons.location_on_outlined),
      const SizedBox(height: 14),
      _dropdownField('State', _selectedState, (v) => setState(() => _selectedState = v ?? _selectedState),
          ['Rajasthan', 'Gujarat', 'Maharashtra', 'Delhi', 'Uttar Pradesh', 'Madhya Pradesh', 'Karnataka', 'Tamil Nadu']),
    ]),
  );

  // ── Step 2: Vehicle ───────────────────────────────────────────────────────
  Widget _vehicleStep(NumberFormat rupee) => _vehiclesLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _stepHeader('Select Vehicle', 'Choose the vehicle for this quote'),
            const SizedBox(height: 24),
            ..._vehicles.map((v) => _vehicleCard(v, rupee)),
          ]),
        );

  Widget _vehicleCard(Map<String, dynamic> v, NumberFormat rupee) {
    final isSelected = _selectedVehicle?['vehicleId'] == v['vehicleId'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedVehicle = v);
        // Auto-calculate RTO (8% of ex-showroom is typical)
        final exPrice = (v['exShowroomPrice'] ?? 0).toDouble();
        _rtoCtrl.text = (exPrice * 0.08).toInt().toString();
        _insuranceCtrl.text = (exPrice * 0.03).toInt().toString();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primary : AppColors.divider, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(children: [
          Container(width: 56, height: 56,
              decoration: BoxDecoration(color: isSelected ? primary.withOpacity(0.1) : AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.directions_car_rounded, color: isSelected ? primary : AppColors.textSecondary, size: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${v['modelName']} ${v['variant']}',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${v['fuelType']} • ${v['transmission']} • ${v['color'] ?? ''}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(rupee.format((v['exShowroomPrice'] ?? 0).toDouble()),
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: primary)),
          ])),
          if (isSelected)
            Container(padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
        ]),
      ),
    );
  }

  // ── Step 3: Pricing ───────────────────────────────────────────────────────
  Widget _pricingStep(NumberFormat rupee) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Pricing Details', 'Configure the complete on-road price'),
      const SizedBox(height: 20),
      if (_selectedVehicle != null)
        Container(
          padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.directions_car_rounded, color: primary, size: 20), const SizedBox(width: 10),
            Expanded(child: Text('${_selectedVehicle!['modelName']} ${_selectedVehicle!['variant']}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: primary))),
            Text(rupee.format((_selectedVehicle!['exShowroomPrice'] ?? 0).toDouble()),
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: primary)),
          ]),
        ),
      _priceField(_rtoCtrl, 'RTO (Registration)', 'Auto-calculated'),
      const SizedBox(height: 14),
      _priceField(_insuranceCtrl, 'Insurance', 'Comprehensive'),
      const SizedBox(height: 14),
      _priceField(TextEditingController(text: '500'), 'FASTag', 'Mandatory', readOnly: true),
      const SizedBox(height: 14),
      _priceField(_accessoriesCtrl, 'Accessories', 'Optional'),
      const SizedBox(height: 14),
      _priceField(_extWarrantyCtrl, 'Extended Warranty', 'Optional'),
      const SizedBox(height: 20),
      Container(height: 1, color: AppColors.divider),
      const SizedBox(height: 16),
      Text('Discounts & Offers', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
      const SizedBox(height: 14),
      _priceField(_discountCtrl, 'Cash Discount', 'Enter amount', isDeduction: true),
      const SizedBox(height: 14),
      _priceField(_exchangeCtrl, 'Exchange Bonus', 'If applicable', isDeduction: true),
      const SizedBox(height: 14),
      _priceField(_corpDiscountCtrl, 'Corporate Discount', 'If applicable', isDeduction: true),
      const SizedBox(height: 20),
      // Live total
      AnimatedBuilder(
        animation: Listenable.merge([_rtoCtrl, _insuranceCtrl, _discountCtrl, _exchangeCtrl]),
        builder: (_, __) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient,
              borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total On-Road Price', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              Text(rupee.format(totalOnRoad), style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ]),
            Icon(Icons.currency_rupee_rounded, color: Colors.white.withOpacity(0.3), size: 48),
          ]),
        ),
      ),
    ]),
  );

  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))]),
    child: SafeArea(child: Row(children: [
      if (_step > 0)
        GestureDetector(onTap: _prevStep,
            child: Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 18))),
      Expanded(child: SizedBox(height: 50,
          child: ElevatedButton(
            onPressed: _saving ? null : _nextStep,
            style: ElevatedButton.styleFrom(backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _saving
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_step == 2 ? 'Create Quote' : 'Continue',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    if (_step < 2) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18)],
                  ]),
          ))),
    ])),
  );

  Widget _stepHeader(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
  ]);

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? inputType, void Function(String)? onChanged, Widget? suffix}) =>
      TextFormField(controller: ctrl, keyboardType: inputType, onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(labelText: label,
              prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
              suffixIcon: suffix, filled: true, fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));

  Widget _dropdownField(String label, String value, void Function(String?) onChanged, List<String> items) =>
      DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          decoration: InputDecoration(labelText: label,
              prefixIcon: const Icon(Icons.map_outlined, size: 18, color: AppColors.textSecondary),
              filled: true, fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged);

  Widget _priceField(TextEditingController ctrl, String label, String hint,
      {bool isDeduction = false, bool readOnly = false}) =>
      TextFormField(controller: ctrl, readOnly: readOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.'))],
          style: GoogleFonts.poppins(fontSize: 14, color: isDeduction ? AppColors.success : AppColors.textPrimary),
          decoration: InputDecoration(labelText: label, hintText: hint,
              prefixIcon: Icon(isDeduction ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  size: 18, color: isDeduction ? AppColors.success : AppColors.textSecondary),
              prefixText: '₹ ', prefixStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              filled: true, fillColor: readOnly ? AppColors.background : isDeduction ? AppColors.success.withOpacity(0.04) : AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDeduction ? AppColors.success.withOpacity(0.3) : AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
}
