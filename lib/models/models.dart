// ── Models ─────────────────────────────────────────────────────────────────

enum ShowroomType { arena, nexa }

enum QuoteStatus { draft, pending, approved, rejected, converted }

class Customer {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String city;
  final String state;
  final String? panNumber;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    this.panNumber,
    required this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'],
    name: map['name'],
    mobile: map['mobile'],
    email: map['email'],
    address: map['address'],
    city: map['city'],
    state: map['state'],
    panNumber: map['panNumber'],
    createdAt: DateTime.parse(map['createdAt']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'email': email,
    'address': address,
    'city': city,
    'state': state,
    'panNumber': panNumber,
    'createdAt': createdAt.toIso8601String(),
  };
}

class VehicleModel {
  final String id;
  final String name;
  final String variant;
  final String color;
  final String fuelType;
  final String transmission;
  final ShowroomType showroomType;
  final double exShowroomPrice;
  final String? imageUrl;

  VehicleModel({
    required this.id,
    required this.name,
    required this.variant,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.showroomType,
    required this.exShowroomPrice,
    this.imageUrl,
  });
}

class QuoteItem {
  final String description;
  final double amount;
  final bool isOptional;

  QuoteItem({required this.description, required this.amount, this.isOptional = false});
}

class SalesQuote {
  final String id;
  final String quoteNumber;
  final Customer customer;
  final VehicleModel vehicle;
  final ShowroomType showroomType;
  final QuoteStatus status;
  final DateTime createdAt;
  final String? consultantName;
  final String? consultantId;

  // Pricing breakdown
  final double exShowroomPrice;
  final double rto;
  final double insurance;
  final double fastTag;
  final double accessories;
  final double extendedWarranty;
  final double discount;
  final double exchangeBonus;
  final double corporateDiscount;
  final double otherCharges;
  final String? remarks;

  SalesQuote({
    required this.id,
    required this.quoteNumber,
    required this.customer,
    required this.vehicle,
    required this.showroomType,
    this.status = QuoteStatus.draft,
    required this.createdAt,
    this.consultantName,
    this.consultantId,
    required this.exShowroomPrice,
    this.rto = 0,
    this.insurance = 0,
    this.fastTag = 0,
    this.accessories = 0,
    this.extendedWarranty = 0,
    this.discount = 0,
    this.exchangeBonus = 0,
    this.corporateDiscount = 0,
    this.otherCharges = 0,
    this.remarks,
  });

  double get totalOnRoad =>
      exShowroomPrice + rto + insurance + fastTag + accessories +
      extendedWarranty + otherCharges - discount - exchangeBonus - corporateDiscount;

  double get totalDiscount => discount + exchangeBonus + corporateDiscount;

  List<QuoteItem> get lineItems => [
    QuoteItem(description: 'Ex-Showroom Price', amount: exShowroomPrice),
    QuoteItem(description: 'RTO (Registration)', amount: rto),
    QuoteItem(description: 'Insurance', amount: insurance),
    QuoteItem(description: 'FASTag', amount: fastTag),
    if (accessories > 0) QuoteItem(description: 'Accessories', amount: accessories, isOptional: true),
    if (extendedWarranty > 0) QuoteItem(description: 'Extended Warranty', amount: extendedWarranty, isOptional: true),
    if (otherCharges > 0) QuoteItem(description: 'Other Charges', amount: otherCharges),
    if (discount > 0) QuoteItem(description: 'Cash Discount', amount: -discount),
    if (exchangeBonus > 0) QuoteItem(description: 'Exchange Bonus', amount: -exchangeBonus),
    if (corporateDiscount > 0) QuoteItem(description: 'Corporate Discount', amount: -corporateDiscount),
  ];
}

class DashboardStats {
  final int totalQuotes;
  final int pendingQuotes;
  final int convertedQuotes;
  final double totalRevenue;
  final double monthlyTarget;
  final int todayEnquiries;
  final List<MonthlyData> monthlyData;

  DashboardStats({
    required this.totalQuotes,
    required this.pendingQuotes,
    required this.convertedQuotes,
    required this.totalRevenue,
    required this.monthlyTarget,
    required this.todayEnquiries,
    required this.monthlyData,
  });

  double get conversionRate =>
      totalQuotes > 0 ? (convertedQuotes / totalQuotes * 100) : 0;
  double get targetAchieved =>
      monthlyTarget > 0 ? (totalRevenue / monthlyTarget * 100).clamp(0, 100) : 0;
}

class MonthlyData {
  final String month;
  final double revenue;
  final int quotes;

  MonthlyData({required this.month, required this.revenue, required this.quotes});
}

// ── Sample Data ────────────────────────────────────────────────────────────

class SampleData {
  static List<VehicleModel> get arenaVehicles => [
    VehicleModel(id: 'a1', name: 'Swift', variant: 'ZXi+', color: 'Magma Grey', fuelType: 'Petrol', transmission: 'MT', showroomType: ShowroomType.arena, exShowroomPrice: 879000),
    VehicleModel(id: 'a2', name: 'Baleno', variant: 'Alpha', color: 'Pearl Arctic White', fuelType: 'Petrol', transmission: 'AT', showroomType: ShowroomType.arena, exShowroomPrice: 985000),
    VehicleModel(id: 'a3', name: 'Brezza', variant: 'ZXi', color: 'Brave Khaki', fuelType: 'Petrol', transmission: 'AT', showroomType: ShowroomType.arena, exShowroomPrice: 1385000),
    VehicleModel(id: 'a4', name: 'Ertiga', variant: 'ZXi+', color: 'Auburn Red', fuelType: 'CNG', transmission: 'MT', showroomType: ShowroomType.arena, exShowroomPrice: 1245000),
    VehicleModel(id: 'a5', name: 'WagonR', variant: 'ZXi', color: 'Silky Silver', fuelType: 'CNG', transmission: 'MT', showroomType: ShowroomType.arena, exShowroomPrice: 745000),
  ];

  static List<VehicleModel> get nexaVehicles => [
    VehicleModel(id: 'n1', name: 'Grand Vitara', variant: 'Alpha+', color: 'Nexa Blue', fuelType: 'Hybrid', transmission: 'AT', showroomType: ShowroomType.nexa, exShowroomPrice: 2195000),
    VehicleModel(id: 'n2', name: 'Fronx', variant: 'Alpha+', color: 'Grandeur Grey', fuelType: 'Petrol Turbo', transmission: 'DCT', showroomType: ShowroomType.nexa, exShowroomPrice: 1285000),
    VehicleModel(id: 'n3', name: 'Invicto', variant: 'Zeta+', color: 'Opulent Red', fuelType: 'Hybrid', transmission: 'AT', showroomType: ShowroomType.nexa, exShowroomPrice: 2595000),
    VehicleModel(id: 'n4', name: 'Jimny', variant: 'Zeta', color: 'Kinetic Yellow', fuelType: 'Petrol', transmission: 'MT', showroomType: ShowroomType.nexa, exShowroomPrice: 1295000),
    VehicleModel(id: 'n5', name: 'Ciaz', variant: 'Alpha', color: 'Premium Silver', fuelType: 'Petrol', transmission: 'AT', showroomType: ShowroomType.nexa, exShowroomPrice: 1085000),
  ];

  static DashboardStats get stats => DashboardStats(
    totalQuotes: 248,
    pendingQuotes: 43,
    convertedQuotes: 156,
    totalRevenue: 28450000,
    monthlyTarget: 35000000,
    todayEnquiries: 12,
    monthlyData: [
      MonthlyData(month: 'Aug', revenue: 2100000, quotes: 31),
      MonthlyData(month: 'Sep', revenue: 2450000, quotes: 36),
      MonthlyData(month: 'Oct', revenue: 3200000, quotes: 48),
      MonthlyData(month: 'Nov', revenue: 2800000, quotes: 42),
      MonthlyData(month: 'Dec', revenue: 3600000, quotes: 52),
      MonthlyData(month: 'Jan', revenue: 4100000, quotes: 61),
    ],
  );

  static List<SalesQuote> get recentQuotes {
    final customer1 = Customer(id: 'c1', name: 'Rajesh Kumar', mobile: '9876543210', email: 'rajesh@email.com', address: '12, Shastri Nagar', city: 'Jaipur', state: 'Rajasthan', createdAt: DateTime.now());
    final customer2 = Customer(id: 'c2', name: 'Priya Sharma', mobile: '9876543211', email: 'priya@email.com', address: '45, Civil Lines', city: 'Jaipur', state: 'Rajasthan', createdAt: DateTime.now());
    final customer3 = Customer(id: 'c3', name: 'Anil Mehta', mobile: '9876543212', email: 'anil@email.com', address: '8, Malviya Nagar', city: 'Jaipur', state: 'Rajasthan', createdAt: DateTime.now());

    return [
      SalesQuote(id: 'q1', quoteNumber: 'ARN-2024-0248', customer: customer1, vehicle: arenaVehicles[2], showroomType: ShowroomType.arena, status: QuoteStatus.pending, createdAt: DateTime.now().subtract(Duration(hours: 2)), consultantName: 'Vikram Singh', exShowroomPrice: 1385000, rto: 138500, insurance: 42000, fastTag: 500, accessories: 25000, discount: 15000),
      SalesQuote(id: 'q2', quoteNumber: 'NXA-2024-0156', customer: customer2, vehicle: nexaVehicles[0], showroomType: ShowroomType.nexa, status: QuoteStatus.approved, createdAt: DateTime.now().subtract(Duration(hours: 5)), consultantName: 'Meena Rathore', exShowroomPrice: 2195000, rto: 219500, insurance: 68000, fastTag: 500, discount: 30000, exchangeBonus: 50000),
      SalesQuote(id: 'q3', quoteNumber: 'ARN-2024-0247', customer: customer3, vehicle: arenaVehicles[0], showroomType: ShowroomType.arena, status: QuoteStatus.converted, createdAt: DateTime.now().subtract(Duration(days: 1)), consultantName: 'Rahul Jain', exShowroomPrice: 879000, rto: 87900, insurance: 28000, fastTag: 500, discount: 10000),
    ];
  }

  
}
