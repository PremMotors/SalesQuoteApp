class EndPoints {
  // 🔐 AUTH
  static const String login = "Auth/login";

  static const String register = "Auth/register";
  
  static const String manager = "FuelRequests/manager";
  // 🚗 FUEL REQUESTS
  static const String createRequest = "FuelRequests/create";
  static const String getAllRequests = "FuelRequests/all";

  static String getUserRequests(int userId) =>
      "FuelRequests/user/$userId";

  // ✅ STATUS UPDATE (POST body preferred)
  static const String updateStatus = "FuelRequests/status";

  // 📤 RECEIPT UPLOAD (multipart – NO query params)
  static const String uploadReceipt = "FuelReceipts/upload";


  

  // 💰 FINANCE
  static const String financeSummary = "Finance/summary";
  static const String financeExpense = "Finance/expense";
  static const String financePaidRecords = "Finance/paid";
}
