import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../models/stock_model.dart';
import '../../../providers/stock_provider.dart';

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({super.key, this.existingStock});
  final StockModel? existingStock;

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _minQuantityCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _supplierNameCtrl = TextEditingController();
  final _supplierPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Liquids';

  static const _categories = ['Towels', 'Liquids', 'Accessories', 'Machines'];

  bool get _isEditMode => widget.existingStock != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _populate();
  }

  void _populate() {
    final s = widget.existingStock!;
    _nameCtrl.text = s.name;
    _brandCtrl.text = s.brand;
    _quantityCtrl.text = '${s.quantity}';
    _minQuantityCtrl.text = '${s.minQuantity}';
    _purchasePriceCtrl.text = '${s.purchasePrice}';
    _sellingPriceCtrl.text = '${s.sellingPrice}';
    _supplierNameCtrl.text = s.supplierName;
    _supplierPhoneCtrl.text = s.supplierPhone;
    _notesCtrl.text = s.notes;
    _category = s.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _quantityCtrl.dispose();
    _minQuantityCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _supplierNameCtrl.dispose();
    _supplierPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<StockProvider>();

    final stock = StockModel(
      id: widget.existingStock?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _category,
      brand: _brandCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 0,
      minQuantity: int.tryParse(_minQuantityCtrl.text.trim()) ?? 5,
      purchasePrice: double.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
      sellingPrice: double.tryParse(_sellingPriceCtrl.text.trim()) ?? 0,
      supplierName: _supplierNameCtrl.text.trim(),
      supplierPhone: _supplierPhoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      lastUpdated: DateTime.now(),
    );

    final ok = _isEditMode
        ? await provider.updateStock(stock)
        : await provider.addStock(stock);

    if (!mounted) return;
    if (ok) {
      context.pop();
      AppSnackbar.success(context,
          _isEditMode ? 'Stock updated successfully' : 'Stock added successfully');
    } else {
      AppSnackbar.error(context, provider.error ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Stock' : 'Add Stock'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            children: [
              // ── Product details ──────────────────────────────────────
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        icon: Icons.inventory_2_outlined,
                        label: 'Product Details'),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Product Name',
                      prefixIcon: Icons.label_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _brandCtrl,
                      label: 'Brand',
                      prefixIcon: Icons.business_outlined,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined,
                            color: AppColors.textHint, size: AppSizes.iconSm),
                      ),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _quantityCtrl,
                            label: 'Quantity',
                            prefixIcon: Icons.inventory_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: Validators.required,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: AppTextField(
                            controller: _minQuantityCtrl,
                            label: 'Min Qty',
                            prefixIcon: Icons.warning_amber_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: Validators.required,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Pricing ───────────────────────────────────────────────
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        icon: Icons.currency_rupee, label: 'Pricing'),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _purchasePriceCtrl,
                            label: 'Purchase Price',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: Validators.amount,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: AppTextField(
                            controller: _sellingPriceCtrl,
                            label: 'Selling Price',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: Validators.amount,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Supplier info ─────────────────────────────────────────
              GlassmorphismCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        icon: Icons.local_shipping_outlined,
                        label: 'Supplier Info'),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _supplierNameCtrl,
                      label: 'Supplier Name',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _supplierPhoneCtrl,
                      label: 'Supplier Phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _notesCtrl,
                      label: 'Notes',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xxxl),

              AppButton(
                label: _isEditMode ? 'Save Changes' : 'Add to Stock',
                onPressed: _submit,
                isLoading: provider.isLoading,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: AppSizes.md),
              AppOutlinedButton(
                label: 'Cancel',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: AppSizes.iconSm),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
