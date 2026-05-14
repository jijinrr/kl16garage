import '../constants/app_strings.dart';

/// Form field validators. All methods return null (valid) or an error string.
class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    // Accepts Malaysian (01x-xxxx xxxx) and generic 8–15 digit numbers
    final digits = value.replaceAll(RegExp(r'[\s\-+()]'), '');
    if (digits.length < 8 || digits.length > 15) return AppStrings.invalidPhone;
    if (!RegExp(r'^\d+$').hasMatch(digits)) return AppStrings.invalidPhone;
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) return AppStrings.invalidAmount;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.fieldRequired;
    if (value.length < 6) return AppStrings.passwordMinLength;
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    return email(value);
  }

  /// Validates advance amount does not exceed total.
  static String? advance(String? value, double total) {
    final base = amount(value);
    if (base != null) return base;
    final advance = double.tryParse(value!.trim()) ?? 0;
    if (advance > total) return AppStrings.advanceExceedsTotal;
    return null;
  }
}
