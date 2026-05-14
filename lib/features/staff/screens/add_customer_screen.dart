import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../models/service_model.dart';
import '../../../providers/service_provider.dart';
import '../widgets/payment_section.dart';
import '../widgets/service_chip.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key, this.existingService});
  final ServiceModel? existingService;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  String _vehicleType = AppStrings.vehicleTypes.first;
  String _paymentMethod = AppStrings.methodCash;
  String _paymentStatus = 'Pending';
  List<String> _selectedServices = [];
  List<File> _beforePhotos = [];
  List<File> _afterPhotos = [];

  bool get _isEditMode => widget.existingService != null;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _populateFields();
  }

  void _populateFields() {
    final s = widget.existingService!;
    _nameCtrl.text = s.customerName;
    _vehicleCtrl.text = s.vehicleNumber;
    _phoneCtrl.text = s.phone;
    _totalCtrl.text = s.totalAmount.toString();
    _advanceCtrl.text = s.advanceAmount.toString();
    _commentsCtrl.text = s.comments;
    _vehicleType = s.vehicleType;
    _paymentMethod = s.paymentMethod;
    _paymentStatus = s.paymentStatus;
    _selectedServices = List.from(s.services);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _vehicleCtrl.dispose();
    _phoneCtrl.dispose();
    _totalCtrl.dispose();
    _advanceCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos(bool isBefore) async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked.isEmpty) return;
    final files = picked.map((x) => File(x.path)).toList();
    setState(() {
      if (isBefore) {
        _beforePhotos = [..._beforePhotos, ...files].take(4).toList();
      } else {
        _afterPhotos = [..._afterPhotos, ...files].take(4).toList();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      AppSnackbar.error(context, 'Please select at least one service.');
      return;
    }

    final provider = context.read<ServiceProvider>();
    final double total =
        double.tryParse(_totalCtrl.text) ?? 0;
    final double advance =
        double.tryParse(_advanceCtrl.text) ?? 0;

    final service = ServiceModel(
      id: widget.existingService?.id ?? '',
      customerName: _nameCtrl.text.trim(),
      vehicleNumber: _vehicleCtrl.text.trim().toUpperCase(),
      phone: _phoneCtrl.text.trim(),
      vehicleType: _vehicleType,
      services: _selectedServices,
      totalAmount: total,
      advanceAmount: advance,
      balanceAmount: (total - advance).clamp(0, double.infinity),
      paymentStatus: _paymentStatus,
      paymentMethod: _paymentMethod,
      comments: _commentsCtrl.text.trim(),
    );

    bool ok;
    if (_isEditMode) {
      ok = await provider.updateService(service);
    } else {
      ok = await provider.addService(
        service: service,
        beforePhotos: _beforePhotos,
        afterPhotos: _afterPhotos,
      );
    }

    if (!mounted) return;
    if (ok) {
      context.pop();
      AppSnackbar.success(context, AppStrings.savedSuccessfully);
    } else {
      AppSnackbar.error(
          context, provider.error ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
              _isEditMode ? AppStrings.editService : AppStrings.addCustomer),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            children: [
              // ── Customer Details ──────────────────────────────────────
              _SectionHeader(title: AppStrings.customerDetails),
              const SizedBox(height: AppSizes.md),
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: AppStrings.customerName,
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _vehicleCtrl,
                      label: AppStrings.vehicleNumber,
                      hint: 'KL16AB1234',
                      prefixIcon: Icons.directions_car_outlined,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(12),
                        _UpperCaseFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        // Indian vehicle: 2 letters + 2 digits + 1–3 letters + 4 digits
                        final re = RegExp(
                            r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$');
                        if (!re.hasMatch(v)) {
                          return 'Format: KL16AB1234';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: AppStrings.contactNumber,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length != 10) return 'Enter exactly 10 digits';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Vehicle type dropdown
                    DropdownButtonFormField<String>(
                      value: _vehicleType,
                      decoration: const InputDecoration(
                        labelText: AppStrings.vehicleType,
                        prefixIcon: Icon(Icons.commute_outlined,
                            color: AppColors.textHint,
                            size: AppSizes.iconSm),
                      ),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: AppStrings.vehicleTypes
                          .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _vehicleType = v ?? _vehicleType),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // ── Payment Section ───────────────────────────────────────
              PaymentSection(
                totalCtrl: _totalCtrl,
                advanceCtrl: _advanceCtrl,
                onStatusChanged: (s) =>
                    setState(() => _paymentStatus = s),
              ),

              const SizedBox(height: AppSizes.xxl),

              // ── Services ──────────────────────────────────────────────
              _SectionHeader(title: AppStrings.selectServices),
              const SizedBox(height: AppSizes.md),
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: ServiceChipSelector(
                  selected: _selectedServices,
                  onChanged: (s) =>
                      setState(() => _selectedServices = s),
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // ── Payment Method ────────────────────────────────────────
              _SectionHeader(title: AppStrings.paymentMethod),
              const SizedBox(height: AppSizes.md),
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Row(
                  children: [AppStrings.methodCash, AppStrings.methodUpi, AppStrings.methodBoth]
                      .map((m) => Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _paymentMethod = m),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.md,
                                  horizontal: AppSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: _paymentMethod == m
                                      ? AppColors.primary
                                          .withValues(alpha: 0.2)
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSm),
                                  border: Border.all(
                                    color: _paymentMethod == m
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  m,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _paymentMethod == m
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: _paymentMethod == m
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: AppSizes.fontSm,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // ── Photos ─────────────────────────────────────────────────
              _SectionHeader(title: 'Photos (Optional)'),
              const SizedBox(height: AppSizes.md),
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PhotoPicker(
                      label: AppStrings.beforePhotos,
                      photos: _beforePhotos,
                      onPick: () => _pickPhotos(true),
                      onRemove: (i) => setState(
                          () => _beforePhotos.removeAt(i)),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    _PhotoPicker(
                      label: AppStrings.afterPhotos,
                      photos: _afterPhotos,
                      onPick: () => _pickPhotos(false),
                      onRemove: (i) => setState(
                          () => _afterPhotos.removeAt(i)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // ── Comments ──────────────────────────────────────────────
              _SectionHeader(title: AppStrings.comments),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                controller: _commentsCtrl,
                hint: 'Any additional notes…',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppSizes.xxxl),

              // ── Buttons ───────────────────────────────────────────────
              AppButton(
                label: AppStrings.saveCustomer,
                onPressed: _submit,
                isLoading: provider.isLoading,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: AppSizes.md),
              AppOutlinedButton(
                label: AppStrings.cancel,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: AppSizes.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.label,
    required this.photos,
    required this.onPick,
    required this.onRemove,
  });

  final String label;
  final List<File> photos;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontSm,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            ...photos.asMap().entries.map((e) => _PhotoThumb(
                  file: e.value,
                  onRemove: () => onRemove(e.key),
                )),
            if (photos.length < 4)
              GestureDetector(
                onTap: onPick,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                        color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.file, required this.onRemove});
  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Image.file(
            file,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Forces all typed characters to uppercase — used for vehicle number field.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
