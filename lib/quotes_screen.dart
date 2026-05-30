import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'screens/quote_detail_screen.dart';

class QuotesScreen extends StatefulWidget {
  final ShowroomType showroomType;
  const QuotesScreen({super.key, required this.showroomType});
  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  List<dynamic> _quotes = [];
  int _total = 0;
  String _currentTab = 'All';

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;

  final tabs = ['All', 'Pending', 'Approved', 'Converted', 'Draft'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _currentTab = tabs[_tabController.index];
        _loadQuotes();
      }
    });
    _loadQuotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── FETCH QUOTES FROM API ─────────────────────────────────────────────────
  Future<void> _loadQuotes({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getQuotes(
        status: _currentTab == 'All' ? null : _currentTab,
        search: search,
      );
      if (mounted) {
        setState(() {
          _loading = false;
          if (result['success'] == true) {
            final data = result['data'];
            _quotes = data['data'] ?? [];
            _total = data['total'] ?? 0;
          } else {
            _error = result['message'] ?? 'Failed to load quotes';
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Server connection error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: dark,
            title: Text('Sales Quotes ($_total)',
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: () => _loadQuotes()),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _loadQuotes(search: v.isNotEmpty ? v : null),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search quotes, customers...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.4), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.5), size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () { _searchCtrl.clear(); _loadQuotes(); })
                          : null,
                      filled: true, fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white, indicatorWeight: 2,
                  labelColor: Colors.white, unselectedLabelColor: Colors.white.withOpacity(0.5),
                  labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                  tabs: tabs.map((t) => Tab(text: t)).toList(),
                ),
              ]),
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    Text(_error!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadQuotes, child: const Text('Retry')),
                  ]))
                : _quotes.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text('No quotes found', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _quotes.length,
                        itemBuilder: (context, index) => _buildQuoteCard(_quotes[index]),
                      ),
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> q) {
    final status = q['status'] ?? 'Draft';
    final statusColors = {
      'Draft': AppColors.textSecondary, 'Pending': AppColors.warning,
      'Approved': AppColors.success, 'Rejected': AppColors.error, 'Converted': primary,
    };
    final statusColor = statusColors[status] ?? AppColors.textSecondary;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => QuoteDetailScreen(
            quoteId: q['quoteId'], showroomType: widget.showroomType))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient,
                  borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(
                  (q['customerName'] as String? ?? '?').isNotEmpty ? (q['customerName'] as String)[0] : '?',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(q['customerName'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.2))),
                    child: Text(status.toUpperCase(),
                        style: GoogleFonts.poppins(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(q['quoteNumber'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: _infoChip(Icons.directions_car_outlined, '${q['vehicleName']} ${q['vehicleVariant']}')),
              const SizedBox(width: 8),
              Expanded(child: _infoChip(Icons.person_outline, q['consultantName'] ?? 'N/A')),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('On-Road Price', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                Text(rupee.format((q['totalOnRoad'] ?? 0).toDouble()),
                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: primary)),
              ]),
              Row(children: [
                _actionBtn(Icons.share_outlined, () {}),
                const SizedBox(width: 8),
                _actionBtn(Icons.picture_as_pdf_outlined, () {}),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isArena
                        ? const LinearGradient(colors: [AppColors.arenaMidBlue, Color(0xFF1E40AF)])
                        : const LinearGradient(colors: [AppColors.nexaRed, Color(0xFFB91C1C)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('View', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(children: [
    Icon(icon, size: 13, color: AppColors.textSecondary),
    const SizedBox(width: 4),
    Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
  ]);

  Widget _actionBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    ),
  );
}
