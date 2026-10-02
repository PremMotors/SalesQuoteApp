import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final ShowroomType showroomType;
  const DashboardScreen({super.key, required this.showroomType});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final fmt = NumberFormat.compact(locale: 'en_IN');
  final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // ── State ─────────────────────────────────────────────────────────────────
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _dashData;

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primary => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get accent => isArena ? AppColors.arenaGold : AppColors.nexaAccent;
  Color get dark => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _loadDashboard();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── FETCH REAL DATA ───────────────────────────────────────────────────────
  Future<void> _loadDashboard() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getDashboard();
      if (mounted) {
        setState(() {
          _loading = false;
          if (result['success'] == true) {
            _dashData = result['data'];
          } else {
            _error = result['message'] ?? 'Failed to load dashboard';
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
      body: _loading
          ? _buildSkeleton()
          : _error != null
              ? _buildError()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTodayBanner(),
                            const SizedBox(height: 20),
                            _buildKpiGrid(),
                            const SizedBox(height: 24),
                            _buildTargetProgress(),
                            const SizedBox(height: 24),
                            _buildRevenueChart(),
                            const SizedBox(height: 24),
                            _buildRecentQuotes(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSkeleton() => const Center(child: CircularProgressIndicator());

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
      const SizedBox(height: 16),
      Text(_error!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: _loadDashboard,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
        style: ElevatedButton.styleFrom(backgroundColor: primary),
      ),
    ]),
  );

  Widget _buildSliverAppBar() {
    final fullName = ApiService.currentUserName ?? 'Consultant';
    final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

    return SliverAppBar(
      expandedHeight: 160, floating: false, pinned: true, backgroundColor: dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good ${_greeting()},',
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    Text('$fullName 👋',
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: accent.withOpacity(0.2),
                      border: Border.all(color: accent.withOpacity(0.5))),
                    child: Center(child: Text(initials,
                        style: GoogleFonts.montserrat(color: accent, fontSize: 12, fontWeight: FontWeight.w700))),
                  ),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isArena ? Icons.store_rounded : Icons.star_rounded, color: accent, size: 14),
                    const SizedBox(width: 6),
                    Text(isArena ? 'Arena Showroom' : 'Nexa Showroom',
                        style: GoogleFonts.poppins(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
      title: Text(isArena ? 'ARENA' : 'NEXA',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 3)),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadDashboard),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildTodayBanner() {
    final todayEnquiries = _dashData?['todayEnquiries'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.calendar_today_rounded, color: primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('$todayEnquiries new enquiries today',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('+$todayEnquiries',
              style: GoogleFonts.poppins(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildKpiGrid() {
    final total = _dashData?['totalQuotes'] ?? 0;
    final converted = _dashData?['convertedQuotes'] ?? 0;
    final pending = _dashData?['pendingQuotes'] ?? 0;
    final revenue = (_dashData?['totalRevenue'] ?? 0).toDouble();

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.4,
      children: [
        _kpiCard('Total Quotes', total.toString(), Icons.receipt_long_rounded, primary, '+12%'),
        _kpiCard('Converted', converted.toString(), Icons.check_circle_rounded, AppColors.success, '+8%'),
        _kpiCard('Pending', pending.toString(), Icons.pending_rounded, AppColors.warning, ''),
        _kpiCard('Revenue', '₹${fmt.format(revenue)}', Icons.currency_rupee_rounded, AppColors.nexaRed, '+15%'),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
          if (change.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(change, style: GoogleFonts.poppins(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildTargetProgress() {
    final totalRevenue = (_dashData?['totalRevenue'] ?? 0).toDouble();
    final monthlyTarget = (_dashData?['monthlyTarget'] ?? 3500000).toDouble();
    final targetAchieved = (_dashData?['targetAchieved'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isArena ? AppColors.arenaGradient : AppColors.nexaGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: dark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Monthly Target', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            Text(rupee.format(monthlyTarget),
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Achieved', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            Text('${targetAchieved.toStringAsFixed(1)}%',
                style: GoogleFonts.montserrat(color: accent, fontSize: 20, fontWeight: FontWeight.w700)),
          ]),
        ]),
        const SizedBox(height: 16),
        Stack(children: [
          Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(4))),
          AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => FractionallySizedBox(
              widthFactor: ((targetAchieved / 100).clamp(0.0, 1.0)) * _animController.value,
              child: Container(height: 8,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text('${rupee.format(totalRevenue)} of ${rupee.format(monthlyTarget)} achieved',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ]),
    );
  }

  Widget _buildRevenueChart() {
    final monthlyData = (_dashData?['monthlyData'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Revenue Trend', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
            child: Text('6 Months', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: monthlyData.isEmpty
              ? Center(child: Text('No data', style: GoogleFonts.poppins(color: AppColors.textSecondary)))
              : BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5000000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < monthlyData.length) {
                          return Text(monthlyData[i]['month'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary));
                        }
                        return const SizedBox();
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false, horizontalInterval: 1000000,
                    getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 1, dashArray: [4, 4]),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyData.asMap().entries.map((entry) {
                    final revenue = (entry.value['revenue'] ?? 0).toDouble();
                    return BarChartGroupData(x: entry.key, barRods: [
                      BarChartRodData(
                        toY: revenue,
                        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.6)],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: 5000000, color: AppColors.background),
                      ),
                    ]);
                  }).toList(),
                )),
        ),
      ]),
    );
  }

  Widget _buildRecentQuotes() {
    final recentQuotes = (_dashData?['recentQuotes'] as List?) ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Quotes', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        TextButton(onPressed: () {}, child: Text('View All',
            style: GoogleFonts.poppins(color: primary, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 12),
      if (recentQuotes.isEmpty)
        Center(child: Text('No quotes yet', style: GoogleFonts.poppins(color: AppColors.textSecondary)))
      else
        ...recentQuotes.map((q) => _quoteItem(q)),
    ]);
  }

  Widget _quoteItem(Map<String, dynamic> q) {
    final status = q['status'] ?? 'Draft';
    final statusColor = {
      'Draft': AppColors.textSecondary, 'Pending': AppColors.warning,
      'Approved': AppColors.success, 'Rejected': AppColors.error, 'Converted': primary,
    }[status] ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(
            (q['customerName'] as String? ?? '?').isNotEmpty ? (q['customerName'] as String)[0] : '?',
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: primary))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(q['customerName'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('${q['vehicleName']} ${q['vehicleVariant']} • ${q['quoteNumber']}',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rupee.format((q['totalOnRoad'] ?? 0).toDouble()),
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}
