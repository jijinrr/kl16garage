import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/service_model.dart';
import 'currency_helpers.dart';
import 'date_helpers.dart';

/// Generates a styled PDF invoice for a given [ServiceModel].
class PdfGenerator {
  PdfGenerator._();

  static const _red = PdfColor(0.898, 0.035, 0.078);       // #E50914
  static const _dark = PdfColor(0.051, 0.051, 0.051);       // #0D0D0D
  static const _grey = PdfColor(0.6, 0.6, 0.6);
  static const _lightGrey = PdfColor(0.92, 0.92, 0.92);

  /// Returns the raw PDF bytes for the given service invoice.
  static Future<Uint8List> generateInvoice(ServiceModel service) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            _buildHeader(),
            pw.SizedBox(height: 24),

            // ── Invoice metadata ──────────────────────────────────────
            _buildMeta(service),
            pw.SizedBox(height: 20),

            // ── Customer + vehicle ────────────────────────────────────
            _buildCustomerSection(service),
            pw.SizedBox(height: 20),

            // ── Services table ────────────────────────────────────────
            _buildServicesTable(service),
            pw.SizedBox(height: 20),

            // ── Payment summary ───────────────────────────────────────
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: _buildPaymentSummary(service),
            ),
            pw.Spacer(),

            // ── Footer ────────────────────────────────────────────────
            _buildFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _dark,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'KL16 GARAGE PRO',
                style: pw.TextStyle(
                  color: _red,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Vehicle Wash & Detailing',
                style: const pw.TextStyle(color: _grey, fontSize: 11),
              ),
            ],
          ),
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(
              color: _red,
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMeta(ServiceModel service) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _labelValue('Invoice No', '#${service.id.substring(0, 8).toUpperCase()}'),
        _labelValue(
          'Date',
          service.createdAt != null
              ? DateHelpers.formatDate(service.createdAt!)
              : '—',
        ),
        _labelValue('Payment Method', service.paymentMethod),
        _labelValue(
          'Status',
          service.paymentStatus,
          valueColor: service.paymentStatus == 'Completed'
              ? const PdfColor(0, 0.7, 0.4)
              : service.paymentStatus == 'Partial'
                  ? const PdfColor(1, 0.6, 0)
                  : _red,
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerSection(ServiceModel service) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGrey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CUSTOMER',
                  style: const pw.TextStyle(
                      color: _grey, fontSize: 9, letterSpacing: 1),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  service.customerName,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                if (service.phone.isNotEmpty)
                  pw.Text(service.phone,
                      style: const pw.TextStyle(color: _grey, fontSize: 11)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'VEHICLE',
                  style: const pw.TextStyle(
                      color: _grey, fontSize: 9, letterSpacing: 1),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  service.vehicleNumber,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _red,
                  ),
                ),
                pw.Text(
                  service.vehicleType,
                  style: const pw.TextStyle(color: _grey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (service.staffName.isNotEmpty)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SERVICED BY',
                    style: const pw.TextStyle(
                        color: _grey, fontSize: 9, letterSpacing: 1),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    service.staffName,
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildServicesTable(ServiceModel service) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FixedColumnWidth(60),
      },
      border: pw.TableBorder.all(color: _lightGrey, width: 0.5),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _dark),
          children: [
            _tableCell('SERVICE', isHeader: true),
            _tableCell('PRICE', isHeader: true, align: pw.Alignment.centerRight),
          ],
        ),
        // Service rows — split total evenly across services
        ...() {
          final count = service.services.length;
          final perItem = count > 0 ? service.totalAmount / count : 0.0;
          return service.services.map(
            (s) => pw.TableRow(
              children: [
                _tableCell(s),
                _tableCell(
                  CurrencyHelpers.format(perItem),
                  align: pw.Alignment.centerRight,
                ),
              ],
            ),
          );
        }(),
        // If no services listed, show a single row
        if (service.services.isEmpty)
          pw.TableRow(
            children: [
              _tableCell('General Service'),
              _tableCell(
                CurrencyHelpers.format(service.totalAmount),
                align: pw.Alignment.centerRight,
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildPaymentSummary(ServiceModel service) {
    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          _summaryRow('Total Amount', CurrencyHelpers.format(service.totalAmount)),
          pw.Divider(color: _grey, thickness: 0.5),
          _summaryRow(
              'Advance Paid', CurrencyHelpers.format(service.advanceAmount)),
          pw.Divider(color: _grey, thickness: 0.5),
          _summaryRow(
            'Balance Due',
            CurrencyHelpers.format(service.balanceAmount),
            bold: true,
            valueColor: service.balanceAmount > 0 ? _red : const PdfColor(0, 0.7, 0.4),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _lightGrey)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Thank you for choosing KL16 Garage Pro!',
            style: const pw.TextStyle(color: _grey, fontSize: 10),
          ),
          pw.Text(
            'Generated by KL16 Garage Pro',
            style: const pw.TextStyle(color: _grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────

  static pw.Widget _labelValue(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(color: _grey, fontSize: 9)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: isHeader ? PdfColors.white : null,
            fontSize: isHeader ? 10 : 12,
            fontWeight:
                isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            letterSpacing: isHeader ? 0.8 : 0,
          ),
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}
