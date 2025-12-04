import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/services/pdf_service.dart';
import 'package:expense_tracker/services/income_service.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:printing/printing.dart';
import 'dart:io';

final pdfServiceProvider = Provider((ref) => PDFService());

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'income';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isGenerating = true);

    try {
      final pdfService = ref.read(pdfServiceProvider);
      final incomeService = IncomeService();
      final expenseService = ExpenseService();

      File? pdfFile;

      if (_selectedReportType == 'income') {
        final incomes = await incomeService.getIncomeByDateRange(
          userId: user.id!,
          startDate: _startDate,
          endDate: _endDate,
        );
        pdfFile = await pdfService.generateIncomeReport(
          incomes: incomes,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else if (_selectedReportType == 'expense') {
        final expenses = await expenseService.getExpensesByDateRange(
          userId: user.id!,
          startDate: _startDate,
          endDate: _endDate,
        );
        pdfFile = await pdfService.generateExpenseReport(
          expenses: expenses,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else if (_selectedReportType == 'profit') {
        final incomes = await incomeService.getIncomeByDateRange(
          userId: user.id!,
          startDate: _startDate,
          endDate: _endDate,
        );
        final expenses = await expenseService.getExpensesByDateRange(
          userId: user.id!,
          startDate: _startDate,
          endDate: _endDate,
        );
        pdfFile = await pdfService.generateProfitReport(
          incomes: incomes,
          expenses: expenses,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted && pdfFile != null) {
        // Show PDF preview
        await Printing.layoutPdf(
          onLayout: (_) => pdfFile!.readAsBytes(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to ${pdfFile.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Padding(
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
                      'Generate Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text('Report Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReportType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income Report'),
                        ),
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense Report'),
                        ),
                        DropdownMenuItem(
                          value: 'profit',
                          child: Text('Profit & Loss Report'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedReportType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Date Range'),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        '${Helpers.formatDate(_startDate)} - ${Helpers.formatDate(_endDate)}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDateRange,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _isGenerating ? null : _generateReport,
                      text: 'Generate PDF',
                      icon: Icons.picture_as_pdf,
                      isLoading: _isGenerating,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Report Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _InfoItem(
                        icon: Icons.picture_as_pdf,
                        text: 'Reports are generated as PDF files',
                      ),
                      const _InfoItem(
                        icon: Icons.cloud_download,
                        text: 'PDFs are saved to your device',
                      ),
                      const _InfoItem(
                        icon: Icons.share,
                        text: 'You can print or share the reports',
                      ),
                      const _InfoItem(
                        icon: Icons.table_chart,
                        text: 'Reports include detailed transaction tables',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
