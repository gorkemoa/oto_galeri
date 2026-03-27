/// ApiConstants - Tüm API endpoint tanımları
/// Service veya ViewModel içinde endpoint string yazmak YASAKTIR.
class ApiConstants {
  ApiConstants._();

  // ─── BASE URL ──────────────────────────────────────────
  static const String baseUrl = 'https://api.example.com'; // TODO: Gerçek API URL ile değiştirilecek
  static const String apiVersion = '/v1';

  // ─── AUTH ──────────────────────────────────────────────
  static const String login = '$apiVersion/auth/login';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';

  // ─── VEHICLES (ARAÇLAR) ────────────────────────────────
  static const String vehicles = '$apiVersion/vehicles';
  static String vehicleDetail(int id) => '$apiVersion/vehicles/$id';
  static String vehicleSell(int id) => '$apiVersion/vehicles/$id/sell';

  // ─── EXPENSES (GİDERLER) ───────────────────────────────
  static const String expenses = '$apiVersion/expenses';
  static String vehicleExpenses(int vehicleId) => '$apiVersion/vehicles/$vehicleId/expenses';

  // ─── REPORTS (RAPORLAR) ────────────────────────────────
  static const String reports = '$apiVersion/reports';
  static const String reportSummary = '$apiVersion/reports/summary';
  static const String reportVehicleProfitability = '$apiVersion/reports/vehicle-profitability';
  static const String reportMonthlyProfit = '$apiVersion/reports/monthly-profit';
  static const String reportExpenseDistribution = '$apiVersion/reports/expense-distribution';
  static const String reportMostProfitable = '$apiVersion/reports/most-profitable';
  static const String reportMostExpense = '$apiVersion/reports/most-expense';

  // ─── DASHBOARD ─────────────────────────────────────────
  static const String dashboard = '$apiVersion/dashboard';
  static const String dashboardSummary = '$apiVersion/dashboard/summary';
  static const String dashboardRecentVehicles = '$apiVersion/dashboard/recent-vehicles';
  static const String dashboardUpcomingAlerts = '$apiVersion/dashboard/upcoming-alerts';

  // ─── PROFILE ───────────────────────────────────────────
  static const String profile = '$apiVersion/profile';
  static const String gallery = '$apiVersion/gallery';
}
