import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sales_quote_arnexa/theme/app_theme.dart';
import 'package:sales_quote_arnexa/models/models.dart';
import 'package:sales_quote_arnexa/services/api_service.dart';

class QuoteDetailScreen extends StatefulWidget {
  final int quoteId;
  final ShowroomType showroomType;
  const QuoteDetailScreen({super.key, required this.quoteId, required this.showroomType});
  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _quote;

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;
  Color get accent => isArena ? AppColors.arenaGold : AppColors.nexaAccent;

  @override
  void initState() { super.initState(); _loadQuote(); }

  Future<void> _loadQuote() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getQuoteById(widget.quoteId);
      if (mounted) setState(() {
        _loading = false;
        if (result['success'] == true) _quote = result['data'];
        else _error = result['message'] ?? 'Failed to load quote';
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Servers connection error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: dark, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context))),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(_error!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadQuote, child: const Text('Retry')),
        ])));

    final q = _quote!;
    final customer = (q['customer'] as Map?) ?? {};
    final vehicle = (q['vehicle'] as Map?) ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 200, backgroundColor: dark,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), onPressed: () {}),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (val) => _onMenuAction(val, q),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'approve', child: Text('Approve')),
                PopupMenuItem(value: 'convert', child: Text('Mark Converted')),
                PopupMenuItem(value: 'reject', child: Text('Reject')),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(q['quoteNumber'] ?? '', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      Text(q['customerName'] ?? '', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('${q['vehicleName']} ${q['vehicleVariant']}', style: GoogleFonts.poppins(color: accent, fontSize: 13, fontWeight: FontWeight.w500)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('On-Road Price', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                      Text(rupee.format((q['totalOnRoad'] ?? 0).toDouble()),
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    ]),
                  ]),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _actionButtons(),
            const SizedBox(height: 16),
            _section('Customer Details', Icons.person_rounded, Column(children: [
              _row('Name', customer['name']), _row('Mobile', customer['mobile']),
              _row('Email', customer['email'] ?? 'N/A'),
              _row('City', '${customer['city'] ?? ''}, ${customer['state'] ?? ''}'),
              if ((customer['panNumber'] ?? '').toString().isNotEmpty) _row('PAN', customer['panNumber']),
            ])),
            const SizedBox(height: 14),
            _section('Vehicle Details', Icons.directions_car_rounded, Column(children: [
              _row('Model', vehicle['modelName']), _row('Variant', vehicle['variant']),
              _row('Colour', vehicle['color'] ?? 'N/A'), _row('Fuel Type', vehicle['fuelType']),
              _row('Transmission', vehicle['transmission']), _row('Showroom', q['showroomType']),
            ])),
            const SizedBox(height: 14),
            _section('Price Breakdown', Icons.currency_rupee_rounded, _priceBreakdown(q)),
            const SizedBox(height: 14),
            _section('Consultant Details', Icons.badge_rounded, Column(children: [
              _row('Consultant', q['consultantName']),
              _row('Quote Date', _fmtDate(q['createdAt'])),
              _row('Status', q['status']),
              if ((q['remarks'] ?? '').toString().isNotEmpty) _row('Remarks', q['remarks']),
            ])),
            const SizedBox(height: 100),
          ]),
        )),
      ]),
    );
  }

  Widget _actionButtons() => Row(children: [
    Expanded(child: _actionCard(Icons.picture_as_pdf_rounded, 'PDF', AppColors.error, () {})),
    const SizedBox(width: 10),
    Expanded(child: _actionCard(Icons.chat_rounded, 'WhatsApp', const Color(0xFF25D366), () {})),
    const SizedBox(width: 10),
    Expanded(child: _actionCard(Icons.share_rounded, 'Share', primary, () {})),
    const SizedBox(width: 10),
    Expanded(child: _actionCard(Icons.print_rounded, 'Print', AppColors.textSecondary, () {})),
  ]);

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w600))]),
      ));

  Widget _section(String title, IconData icon, Widget child) => Container(
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [Icon(icon, color: primary, size: 18), const SizedBox(width: 8),
            Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))])),
      Container(height: 1, color: AppColors.divider),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]),
  );

  Widget _priceBreakdown(Map<String, dynamic> q) {
    final items = [
      ['Ex-Showroom Price', (q['exShowroomPrice'] ?? 0).toDouble(), false],
      ['RTO (Registration)', (q['rto'] ?? 0).toDouble(), false],
      ['Insurance', (q['insurance'] ?? 0).toDouble(), false],
      ['FASTag', (q['fastTag'] ?? 500).toDouble(), false],
      if ((q['accessories'] ?? 0) > 0) ['Accessories', (q['accessories']).toDouble(), true],
      if ((q['extendedWarranty'] ?? 0) > 0) ['Extended Warranty', (q['extendedWarranty']).toDouble(), true],
      if ((q['otherCharges'] ?? 0) > 0) ['Other Charges', (q['otherCharges']).toDouble(), false],
      if ((q['cashDiscount'] ?? 0) > 0) ['Cash Discount', -(q['cashDiscount']).toDouble(), false],
      if ((q['exchangeBonus'] ?? 0) > 0) ['Exchange Bonus', -(q['exchangeBonus']).toDouble(), false],
      if ((q['corporateDiscount'] ?? 0) > 0) ['Corporate Discount', -(q['corporateDiscount']).toDouble(), false],
    ];
    final totalOnRoad = (q['totalOnRoad'] ?? 0).toDouble();
    final totalDiscount = (q['totalDiscount'] ?? 0).toDouble();

    return Column(children: [
      ...items.map((item) => _priceRow(item[0] as String, item[1] as double, isOptional: item[2] as bool)),
      const SizedBox(height: 12),
      Container(height: 1, color: AppColors.divider),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total On-Road Price', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(rupee.format(totalOnRoad), style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: primary)),
      ]),
      if (totalDiscount > 0) ...[
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerRight,
            child: Text('You save ${rupee.format(totalDiscount)}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600))),
      ],
    ]);
  }

  Widget _row(String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary))),
      Expanded(child: Text(value?.toString() ?? 'N/A', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    ]),
  );

  Widget _priceRow(String label, double amount, {bool isOptional = false}) {
    final isDeduction = amount < 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Row(children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12,
              color: isDeduction ? AppColors.success : AppColors.textPrimary,
              fontWeight: isDeduction ? FontWeight.w600 : FontWeight.w400)),
          if (isOptional) ...[const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('OPT', style: GoogleFonts.poppins(fontSize: 8, color: primary, fontWeight: FontWeight.w700)))],
        ])),
        Text(isDeduction ? '- ${rupee.format(amount.abs())}' : rupee.format(amount),
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
                color: isDeduction ? AppColors.success : AppColors.textPrimary)),
      ]),
    );
  }

  String _fmtDate(dynamic val) {
    if (val == null) return 'N/A';
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse(val.toString())); }
    catch (_) { return val.toString(); }
  }

  void _onMenuAction(String action, Map<String, dynamic> q) async {
    final statusMap = {'approve': 'Approved', 'convert': 'Converted', 'reject': 'Rejected'};
    final newStatus = statusMap[action];
    if (newStatus == null) return;
    try {
      await ApiService.updateQuoteStatus(q['quoteId'], newStatus);
      _loadQuote();
    } catch (_) {}
  }
}
