import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/expense_provider.dart';

/// Bottom sheet modal for adding a new expense.
class ExpenseModal extends StatefulWidget {
  const ExpenseModal({super.key});

  @override
  State<ExpenseModal> createState() => _ExpenseModalState();
}

class _ExpenseModalState extends State<ExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = AppStrings.expenseCategories.first;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ExpenseProvider>();
    final ok = await provider.addExpense(
      category: _category,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      notes: _notesCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, AppStrings.savedSuccessfully);
      Navigator.pop(context);
    } else {
      AppSnackbar.error(
          context, provider.error ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl)),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.pagePaddingH,
        right: AppSizes.pagePaddingH,
        top: AppSizes.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSizes.xxl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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

            Text(
              AppStrings.addExpense,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.xxl),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: AppStrings.expenseCategory,
                prefixIcon: Icon(Icons.category_outlined,
                    color: AppColors.textHint,
                    size: AppSizes.iconSm),
              ),
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              items: AppStrings.expenseCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _titleCtrl,
              label: AppStrings.expenseTitle,
              prefixIcon: Icons.title,
              textCapitalization: TextCapitalization.sentences,
              validator: Validators.required,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _amountCtrl,
              label: AppStrings.expenseAmount,
              prefixIcon: Icons.currency_rupee,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _notesCtrl,
              label: AppStrings.expenseNotes,
              prefixIcon: Icons.notes,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.xxl),

            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: AppStrings.cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppButton(
                    label: AppStrings.addExpense,
                    onPressed: _submit,
                    isLoading: provider.isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
