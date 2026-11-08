import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemDropDownField.dart';
import '../CustemTextField.dart';

/// Small dialog to add / edit one expense inside the reservation form.
/// Workers (category 1) are entered by count × price per person, with the
/// prices of the reservation's event type filled in.
/// Returns {type, description, value, workers_count, female_workers_count,
/// worker_price, female_worker_price} (plus the original uuid when editing).
class ReservationExpenseDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  // Per-person prices of the reservation's event type
  final double? defaultWorkerPrice;
  final double? defaultFemaleWorkerPrice;

  const ReservationExpenseDialog({
    super.key,
    this.initial,
    this.defaultWorkerPrice,
    this.defaultFemaleWorkerPrice,
  });

  @override
  State<ReservationExpenseDialog> createState() =>
      _ReservationExpenseDialogState();
}

class _ReservationExpenseDialogState extends State<ReservationExpenseDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _amount;
  late TextEditingController _workersCount;
  late TextEditingController _femaleWorkersCount;
  late TextEditingController _workerPrice;
  late TextEditingController _femaleWorkerPrice;
  int? _type;

  bool get _isWorkers => _type == 1;

  String _plain(num? v) {
    if (v == null || v == 0) return '';
    final d = v.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

  double get _workersTotal =>
      _num(_workersCount) * _num(_workerPrice) +
      _num(_femaleWorkersCount) * _num(_femaleWorkerPrice);

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?['description']?.toString() ?? '');
    _amount = TextEditingController(text: _plain(i?['value'] as num?));
    _type = i?['type'] as int?;
    _workersCount = TextEditingController(
      text: (i?['workers_count'] as num?)?.toInt().toString() ?? '',
    );
    _femaleWorkersCount = TextEditingController(
      text: (i?['female_workers_count'] as num?)?.toInt().toString() ?? '',
    );
    // Saved price first, otherwise the event type's price
    _workerPrice = TextEditingController(
      text: _plain((i?['worker_price'] as num?) ?? widget.defaultWorkerPrice),
    );
    _femaleWorkerPrice = TextEditingController(
      text: _plain(
        (i?['female_worker_price'] as num?) ?? widget.defaultFemaleWorkerPrice,
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _workersCount.dispose();
    _femaleWorkersCount.dispose();
    _workerPrice.dispose();
    _femaleWorkerPrice.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isWorkers && _workersTotal <= 0) {
      Get.snackbar('error'.tr, 'enter_workers_count'.tr);
      return;
    }
    Get.back(
      result: {
        if (widget.initial?['uuid'] != null) 'uuid': widget.initial!['uuid'],
        'type': _type,
        'description': _name.text.trim(),
        'value': _isWorkers ? _workersTotal : (double.tryParse(_amount.text) ?? 0.0),
        if (_isWorkers) ...{
          'workers_count': _num(_workersCount).toInt(),
          'female_workers_count': _num(_femaleWorkersCount).toInt(),
          'worker_price': _num(_workerPrice),
          'female_worker_price': _num(_femaleWorkerPrice),
        },
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return CustemTextField(
      controller: controller,
      label: label.tr,
      hint: '0',
      icon: icon,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final textColor = theme.colorScheme.onSurface;
    final compact = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? double.infinity : 480),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initial == null ? 'add_expense'.tr : 'edit_expense'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                CustemTextField(
                  controller: _name,
                  label: 'expense_name'.tr,
                  hint: 'expense_name'.tr,
                  icon: Icons.description_outlined,
                  validator: (val) => validInput(val!, 1000, 1, "Text"),
                ),
                const SizedBox(height: 16),
                Text(
                  'category'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                CustemDropDownField<int>(
                  value: _type,
                  onChanged: (val) => setState(() => _type = val),
                  validator: (val) =>
                      val == null ? "please_select_category".tr : null,
                  items: [
                    DropdownMenuItem(value: 1, child: Text('workers'.tr)),
                    DropdownMenuItem(value: 4, child: Text('maintenance'.tr)),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('cleaning_materials'.tr),
                    ),
                    DropdownMenuItem(value: 3, child: Text('other_expenses'.tr)),
                  ],
                ),
                const SizedBox(height: 16),

                // Workers: count × price per person, otherwise the amount
                if (_isWorkers) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          _workersCount,
                          'workers_count',
                          Icons.man_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          _workerPrice,
                          'worker_price',
                          Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          _femaleWorkersCount,
                          'female_workers_count',
                          Icons.woman_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          _femaleWorkerPrice,
                          'female_worker_price',
                          Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColor.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.primaryPurple.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'workers_total'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${formatMoney(_workersTotal)} DA",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  CustemTextField(
                    controller: _amount,
                    label: 'amount_da'.tr,
                    hint: '0',
                    icon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) => validInput(val!, 1000, 1, "number"),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(color: colors.subtitleColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('save'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
