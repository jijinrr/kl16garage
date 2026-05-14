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
import '../../../models/staff_model.dart';
import '../../../providers/staff_provider.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key, this.existingStaff});
  final StaffModel? existingStaff;

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  String _role = 'staff';
  File? _photo;
  DateTime? _joinDate;
  final _picker = ImagePicker();

  bool get _isEditMode => widget.existingStaff != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _populate();
  }

  void _populate() {
    final s = widget.existingStaff!;
    _nameCtrl.text = s.name;
    _phoneCtrl.text = s.phone;
    _emailCtrl.text = s.email;
    _salaryCtrl.text = s.salary.toString();
    _emergencyCtrl.text = s.emergencyContact;
    _role = s.role;
    _joinDate = s.joinDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _salaryCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _joinDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<StaffProvider>();

    final staff = StaffModel(
      id: widget.existingStaff?.id ?? '',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text.trim()) ?? 0,
      role: _role,
      joinDate: _joinDate,
      emergencyContact: _emergencyCtrl.text.trim(),
    );

    bool ok;
    if (_isEditMode) {
      ok = await provider.updateStaff(staff, photo: _photo);
    } else {
      ok = await provider.addStaff(staff, photo: _photo);
    }

    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, AppStrings.savedSuccessfully);
      context.pop();
    } else {
      AppSnackbar.error(
          context, provider.error ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
              _isEditMode ? AppStrings.editStaff : AppStrings.addStaff),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            children: [
              // ── Photo picker ──────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.avatarXl / 2,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: _photo != null
                            ? FileImage(_photo!) as ImageProvider
                            : (widget.existingStaff?.photoUrl.isNotEmpty == true
                                ? NetworkImage(
                                    widget.existingStaff!.photoUrl)
                                : null),
                        child: _photo == null &&
                                widget.existingStaff?.photoUrl.isEmpty != false
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: AppSizes.iconXs,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: AppStrings.staffName,
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: AppStrings.staffPhone,
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
                    AppTextField(
                      controller: _emailCtrl,
                      label: AppStrings.staffEmail,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.optionalEmail,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _salaryCtrl,
                      label: AppStrings.monthlySalary,
                      prefixIcon: Icons.currency_rupee,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Role selector
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge_outlined,
                            color: AppColors.textHint,
                            size: AppSizes.iconSm),
                      ),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 'staff', child: Text('Staff')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) =>
                          setState(() => _role = v ?? 'staff'),
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Join date
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: AppTextField(
                          label: AppStrings.joinDate,
                          prefixIcon: Icons.calendar_today_outlined,
                          initialValue: _joinDate != null
                              ? '${_joinDate!.day}/${_joinDate!.month}/${_joinDate!.year}'
                              : null,
                          hint: 'Select join date',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _emergencyCtrl,
                      label: AppStrings.emergencyContact,
                      prefixIcon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return null; // optional
                        if (v.length != 10) return 'Enter exactly 10 digits';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xxxl),

              AppButton(
                label: _isEditMode
                    ? AppStrings.save
                    : AppStrings.addStaff,
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
