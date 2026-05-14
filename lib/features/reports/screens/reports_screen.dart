import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/utils/qr_helpers.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/service_model.dart';
import '../../../repositories/service_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<ServiceModel> _services = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _statusFilter = 'All';
  DateTimeRange? _dateRange;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final repo = context.read<ServiceRepository>();
      final list = await repo.fetchHistory(
        limit: 20,
        statusFilter: _statusFilter,
      );
      setState(() {
        _services.addAll(list);
        _hasMore = list.length == 20;
      });
    } catch (_) {
      // silently fail
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _refresh() {
    setState(() {
      _services.clear();
      _hasMore = true;
    });
    _load();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() => _dateRange = range);
      _refresh();
    }
  }

  void _clearDateFilter() {
    setState(() => _dateRange = null);
    _refresh();
  }

  Future<void> _exportPdf(ServiceModel service) async {
    try {
      final bytes = await PdfGenerator.generateInvoice(service);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Invoice_${service.vehicleNumber}_${service.id.substring(0, 8)}',
      );
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to generate PDF: $e');
      }
    }
  }

  void _showQrSheet(ServiceModel service) {
    final payload = QrHelpers.buildPayload(service);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => _QrInvoiceSheet(service: service, payload: payload),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply client-side date filter on top of loaded results
    final filtered = _dateRange == null
        ? _services
        : _services.where((s) {
            if (s.createdAt == null) return false;
            return s.createdAt!.isAfter(
                    _dateRange!.start.subtract(const Duration(seconds: 1))) &&
                s.createdAt!.isBefore(
                    _dateRange!.end.add(const Duration(days: 1)));
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Invoices'),
        actions: [
          // Date range filter
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: _dateRange != null ? AppColors.primary : null,
            ),
            tooltip: 'Filter by date',
            onPressed: _pickDateRange,
          ),
          // Status filter
          PopupMenuButton<String>(
            color: AppColors.surface,
            icon: Icon(
              Icons.filter_list,
              color: _statusFilter != 'All' ? AppColors.primary : null,
            ),
            tooltip: 'Filter by status',
            onSelected: (v) {
              setState(() => _statusFilter = v);
              _refresh();
            },
            itemBuilder: (_) => ['All', 'Completed', 'Pending', 'Partial']
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          if (_statusFilter == s)
                            const Icon(Icons.check,
                                size: AppSizes.iconSm, color: AppColors.primary)
                          else
                            const SizedBox(width: AppSizes.iconSm),
                          const SizedBox(width: AppSizes.sm),
                          Text(s,
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Active filters row ───────────────────────────────────────
          if (_dateRange != null || _statusFilter != 'All')
            _ActiveFiltersBar(
              statusFilter: _statusFilter,
              dateRange: _dateRange,
              onClearDate: _clearDateFilter,
              onClearStatus: () {
                setState(() => _statusFilter = 'All');
                _refresh();
              },
            ),

          // ── Results count ────────────────────────────────────────────
          if (!_isLoading || _services.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} record${filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
              ),
            ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: _services.isEmpty && _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    child: ShimmerList(count: 5),
                  )
                : filtered.isEmpty && !_isLoading
                    ? const EmptyStateWidget(
                        title: 'No records found',
                        subtitle:
                            'Try adjusting your filters or date range.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _refresh(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePaddingH,
                            vertical: AppSizes.md,
                          ),
                          itemCount:
                              filtered.length + (_hasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == filtered.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSizes.lg),
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              );
                            }
                            return _ReportCard(
                              service: filtered[i],
                              onPdf: () => _exportPdf(filtered[i]),
                              onQr: () => _showQrSheet(filtered[i]),
                              onWhatsApp: () =>
                                  WhatsAppHelper.shareInvoice(filtered[i]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Report card ─────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.service,
    required this.onPdf,
    required this.onQr,
    required this.onWhatsApp,
  });

  final ServiceModel service;
  final VoidCallback onPdf;
  final VoidCallback onQr;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          service.vehicleNumber,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: AppSizes.fontLg,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          service.vehicleType,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: AppSizes.fontXs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.customerName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                    if (service.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        DateHelpers.formatDateTime(service.createdAt!),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: AppSizes.fontXs,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelpers.format(service.totalAmount),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: AppSizes.fontLg,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  StatusChip(
                    status: statusTypeFromString(service.paymentStatus),
                    fontSize: AppSizes.fontXs,
                  ),
                ],
              ),
            ],
          ),

          // ── Services preview ───────────────────────────────────────
          if (service.services.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              service.services.take(3).join(' • ') +
                  (service.services.length > 3
                      ? ' +${service.services.length - 3}'
                      : ''),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: AppSizes.fontXs,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Balance ────────────────────────────────────────────────
          if (service.balanceAmount > 0) ...[
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: AppSizes.iconXs, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'Balance: ${CurrencyHelpers.format(service.balanceAmount)}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // ── Action buttons ─────────────────────────────────────────
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              _ActionChip(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF',
                color: AppColors.error,
                onTap: onPdf,
              ),
              const SizedBox(width: AppSizes.sm),
              _ActionChip(
                icon: Icons.qr_code,
                label: 'QR',
                color: AppColors.primary,
                onTap: onQr,
              ),
              const SizedBox(width: AppSizes.sm),
              _ActionChip(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: onWhatsApp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action chip ──────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs + 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconXs + 2, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active filters bar ───────────────────────────────────────────────────────

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar({
    required this.statusFilter,
    required this.dateRange,
    required this.onClearDate,
    required this.onClearStatus,
  });

  final String statusFilter;
  final DateTimeRange? dateRange;
  final VoidCallback onClearDate;
  final VoidCallback onClearStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (statusFilter != 'All')
            _FilterPill(
              label: statusFilter,
              onRemove: onClearStatus,
            ),
          if (dateRange != null)
            _FilterPill(
              label:
                  '${dateRange!.start.day}/${dateRange!.start.month} – ${dateRange!.end.day}/${dateRange!.end.month}',
              onRemove: onClearDate,
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: AppSizes.iconXs,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR invoice bottom sheet ──────────────────────────────────────────────────

class _QrInvoiceSheet extends StatefulWidget {
  const _QrInvoiceSheet({
    required this.service,
    required this.payload,
  });

  final ServiceModel service;
  final String payload;

  @override
  State<_QrInvoiceSheet> createState() => _QrInvoiceSheetState();
}

class _QrInvoiceSheetState extends State<_QrInvoiceSheet> {
  bool _pdfLoading = false;

  Future<void> _printPdf() async {
    setState(() => _pdfLoading = true);
    try {
      final bytes = await PdfGenerator.generateInvoice(widget.service);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name:
            'Invoice_${widget.service.vehicleNumber}_${widget.service.id.substring(0, 8)}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'PDF error: $e');
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.lg,
          AppSizes.pagePaddingH,
          AppSizes.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Title ────────────────────────────────────────────────
            Text(
              'Invoice QR Code',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.fontXl,
              ),
            ),
            Text(
              '${s.vehicleNumber} • ${s.customerName}',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: AppSizes.fontSm,
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ── QR Code ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: QrImageView(
                data: widget.payload,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0D0D0D),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ── Quick summary ────────────────────────────────────────
            GlassmorphismCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  _SummaryRow(
                    'Total',
                    CurrencyHelpers.format(s.totalAmount),
                    valueColor: AppColors.textPrimary,
                  ),
                  const Divider(color: AppColors.border, height: AppSizes.lg),
                  _SummaryRow(
                    'Advance',
                    CurrencyHelpers.format(s.advanceAmount),
                    valueColor: AppColors.success,
                  ),
                  const Divider(color: AppColors.border, height: AppSizes.lg),
                  _SummaryRow(
                    'Balance',
                    CurrencyHelpers.format(s.balanceAmount),
                    valueColor: s.balanceAmount > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ── Action buttons ───────────────────────────────────────
            AppButton(
              label: 'Export PDF / Print',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: _printPdf,
              isLoading: _pdfLoading,
            ),
            const SizedBox(height: AppSizes.md),
            AppOutlinedButton(
              label: 'Share via WhatsApp',
              icon: Icons.chat_outlined,
              onPressed: () => WhatsAppHelper.shareInvoice(widget.service),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.fontMd)),
      ],
    );
  }
}
