import 'dart:convert';
import '../../models/service_model.dart';
import 'currency_helpers.dart';
import 'date_helpers.dart';

/// Builds compact JSON payloads for QR-code invoices.
class QrHelpers {
  QrHelpers._();

  /// Returns a JSON string that encodes the most important invoice fields.
  /// Keep it short — QR capacity degrades with payload size.
  static String buildPayload(ServiceModel service) {
    final payload = {
      'app': 'KL16 Garage Pro',
      'id': service.id.length > 8 ? service.id.substring(0, 8) : service.id,
      'customer': service.customerName,
      'vehicle': service.vehicleNumber,
      'type': service.vehicleType,
      'services': service.services.join(', '),
      'total': CurrencyHelpers.format(service.totalAmount),
      'advance': CurrencyHelpers.format(service.advanceAmount),
      'balance': CurrencyHelpers.format(service.balanceAmount),
      'payment': service.paymentStatus,
      'method': service.paymentMethod,
      if (service.createdAt != null)
        'date': DateHelpers.formatDate(service.createdAt!),
    };

    return const JsonEncoder().convert(payload);
  }

  /// Returns a human-readable plain-text version for WhatsApp / SMS sharing.
  static String buildTextSummary(ServiceModel service) {
    final sb = StringBuffer();
    sb.writeln('🔧 *KL16 GARAGE PRO — Invoice*');
    sb.writeln('─────────────────────');
    sb.writeln('🚗 Vehicle  : ${service.vehicleNumber} (${service.vehicleType})');
    sb.writeln('👤 Customer : ${service.customerName}');
    if (service.phone.isNotEmpty) {
      sb.writeln('📞 Phone    : ${service.phone}');
    }
    sb.writeln('');
    sb.writeln('🛠 Services :');
    for (final s in service.services) {
      sb.writeln('   • $s');
    }
    sb.writeln('');
    sb.writeln('💰 Total    : ${CurrencyHelpers.format(service.totalAmount)}');
    sb.writeln('✅ Advance  : ${CurrencyHelpers.format(service.advanceAmount)}');
    sb.writeln('🔴 Balance  : ${CurrencyHelpers.format(service.balanceAmount)}');
    sb.writeln('📋 Status   : ${service.paymentStatus}');
    sb.writeln('💳 Method   : ${service.paymentMethod}');
    if (service.createdAt != null) {
      sb.writeln('📅 Date     : ${DateHelpers.formatDateTime(service.createdAt!)}');
    }
    sb.writeln('─────────────────────');
    sb.write('Thank you for choosing KL16 Garage Pro! 🚀');
    return sb.toString();
  }
}
