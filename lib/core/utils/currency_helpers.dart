import 'package:intl/intl.dart';

/// Currency formatting helpers — Indian Rupee (INR).
class CurrencyHelpers {
  CurrencyHelpers._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  /// e.g. "₹1,200"
  static String format(double amount) => _formatter.format(amount);

  /// e.g. "₹1.2K" — for dashboard stat cards
  static String compact(double amount) => _compactFormatter.format(amount);

  /// Parse a string like "1200.50" to double. Returns 0.0 on failure.
  static double parse(String value) =>
      double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;

  /// Returns the balance = total - advance (clamped to 0).
  static double balance(double total, double advance) =>
      (total - advance).clamp(0, double.infinity);

  /// Returns payment status string based on amounts.
  static String paymentStatus(double total, double advance) {
    if (advance <= 0) return 'Pending';
    if (advance >= total) return 'Completed';
    return 'Partial';
  }
}
