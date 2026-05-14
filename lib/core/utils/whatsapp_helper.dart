import 'package:url_launcher/url_launcher.dart';
import '../../models/service_model.dart';
import 'qr_helpers.dart';

/// Launches WhatsApp with a pre-filled invoice summary message.
class WhatsAppHelper {
  WhatsAppHelper._();

  /// Opens WhatsApp with the invoice text pre-filled.
  /// If [phone] is provided (digits only, with country code), opens a direct chat.
  /// Otherwise opens the share sheet.
  static Future<void> shareInvoice(ServiceModel service) async {
    final text = Uri.encodeComponent(QrHelpers.buildTextSummary(service));

    // Try direct chat if a phone number is available
    final phone = service.phone.replaceAll(RegExp(r'[^\d]'), '');
    final hasPhone = phone.length >= 10;

    Uri uri;
    if (hasPhone) {
      // Prepend Malaysian country code if needed (for local numbers starting with 0)
      final normalised = phone.startsWith('0') ? '6$phone' : phone;
      uri = Uri.parse('https://wa.me/$normalised?text=$text');
    } else {
      uri = Uri.parse('https://wa.me/?text=$text');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fall back to generic share URL
      final fallback = Uri.parse('whatsapp://send?text=$text');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Shares a raw text message via WhatsApp to a specific number.
  static Future<void> sendMessage(String phone, String message) async {
    final normalised = phone.startsWith('0') ? '6$phone' : phone;
    final text = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$normalised?text=$text');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
