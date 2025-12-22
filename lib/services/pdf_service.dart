import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/utils/helpers.dart';

class PDFService {
  // Generate income report
  Future<File> generateIncomeReport({
    required List<IncomeModel> incomes,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final total = incomes.fold(0.0, (sum, income) => sum + income.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Income Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text:
                '${Helpers.formatDate(startDate)} - ${Helpers.formatDate(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Notes'],
            data: incomes.map((income) {
              return [
                Helpers.formatDate(income.date),
                income.category,
                Helpers.formatCurrency(income.amount),
                income.notes,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Income: ${Helpers.formatCurrency(total)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return await _savePDF(pdf, 'income_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // Generate expense report
  Future<File> generateExpenseReport({
    required List<ExpenseModel> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Expense Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text:
                '${Helpers.formatDate(startDate)} - ${Helpers.formatDate(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Notes'],
            data: expenses.map((expense) {
              return [
                Helpers.formatDate(expense.date),
                expense.category,
                Helpers.formatCurrency(expense.amount),
                expense.notes,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Expenses: ${Helpers.formatCurrency(total)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return await _savePDF(pdf, 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // Generate profit report
  Future<File> generateProfitReport({
    required List<IncomeModel> incomes,
    required List<ExpenseModel> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final totalIncome = incomes.fold(0.0, (sum, income) => sum + income.amount);
    final totalExpense = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final profit = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Profit & Loss Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text:
                '${Helpers.formatDate(startDate)} - ${Helpers.formatDate(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Income:', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(
                      Helpers.formatCurrency(totalIncome),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Expenses:', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(
                      Helpers.formatCurrency(totalExpense),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      profit >= 0 ? 'Net Profit:' : 'Net Loss:',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      Helpers.formatCurrency(profit.abs()),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: profit >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return await _savePDF(pdf, 'profit_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // Save PDF to local storage
  Future<File> _savePDF(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }
}
