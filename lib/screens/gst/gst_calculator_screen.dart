import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/services/gst_service.dart';
import 'package:expense_tracker/models/gst_calculation_model.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:flutter/services.dart';

final gstServiceProvider = Provider((ref) => GSTService());

class GSTCalculatorScreen extends ConsumerStatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  ConsumerState<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends ConsumerState<GSTCalculatorScreen> {
  final _amountController = TextEditingController();
  final _gstPercentController = TextEditingController(text: '18');
  
  double? _baseAmount;
  double? _gstPercent;
  double? _cgst;
  double? _sgst;
  double? _totalAmount;

  @override
  void dispose() {
    _amountController.dispose();
    _gstPercentController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text);
    final gstPercent = double.tryParse(_gstPercentController.text);

    if (amount != null && gstPercent != null) {
      setState(() {
        _baseAmount = amount;
        _gstPercent = gstPercent;
        final gstAmount = amount * (gstPercent / 100);
        _cgst = gstAmount / 2;
        _sgst = gstAmount / 2;
        _totalAmount = amount + gstAmount;
      });
    }
  }

  Future<void> _saveCalculation() async {
    if (_baseAmount != null && _gstPercent != null) {
      final user = ref.read(authNotifierProvider).value;
      if (user == null) return;

      final gstService = ref.read(gstServiceProvider);
      await gstService.calculateAndSave(
        userId: user.id!,
        amount: _baseAmount!,
        gstPercent: _gstPercent!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GST calculation saved')),
        );
      }
    }
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculate GST',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _amountController,
                      label: 'Base Amount',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _gstPercentController,
                      label: 'GST Percentage',
                      prefixIcon: Icons.percent,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: _calculate,
                      text: 'Calculate',
                      icon: Icons.calculate,
                    ),
                  ],
                ),
              ),
            ),

            if (_totalAmount != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Breakdown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(
                        label: 'Base Amount',
                        value: Helpers.formatCurrency(_baseAmount!),
                      ),
                      const SizedBox(height: 8),
                      _ResultRow(
                        label: 'CGST ($_gstPercent%)',
                        value: Helpers.formatCurrency(_cgst!),
                      ),
                      const SizedBox(height: 8),
                      _ResultRow(
                        label: 'SGST ($_gstPercent%)',
                        value: Helpers.formatCurrency(_sgst!),
                      ),
                      const Divider(height: 24),
                      _ResultRow(
                        label: 'Total Amount',
                        value: Helpers.formatCurrency(_totalAmount!),
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: _saveCalculation,
                        text: 'Save Calculation',
                        icon: Icons.save,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'Common GST Rates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _GSTRateTile(
                    rate: '5%',
                    description: 'Coal, Domestic LPG, etc.',
                    onTap: () => _gstPercentController.text = '5',
                  ),
                  const Divider(height: 1),
                  _GSTRateTile(
                    rate: '12%',
                    description: 'Computers, Processed food, etc.',
                    onTap: () => _gstPercentController.text = '12',
                  ),
                  const Divider(height: 1),
                  _GSTRateTile(
                    rate: '18%',
                    description: 'Most goods and services',
                    onTap: () => _gstPercentController.text = '18',
                  ),
                  const Divider(height: 1),
                  _GSTRateTile(
                    rate: '28%',
                    description: 'Luxury items, automobiles, etc.',
                    onTap: () => _gstPercentController.text = '28',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GSTRateTile extends StatelessWidget {
  final String rate;
  final String description;
  final VoidCallback onTap;

  const _GSTRateTile({
    required this.rate,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(rate),
      ),
      title: Text(rate),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
