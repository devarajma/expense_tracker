import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/gst_calculation_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class GSTService {
  final _db = DatabaseHelper.instance;

  // Calculate and save GST
  Future<int> calculateAndSave({
    required int userId,
    required double amount,
    required double gstPercent,
  }) async {
    final calculation = GSTCalculationModel.calculate(
      userId: userId,
      amount: amount,
      gstPercent: gstPercent,
    );
    return await _db.insert(AppStrings.tableGST, calculation.toMap());
  }

  // Get all calculations for user
  Future<List<GSTCalculationModel>> getAllCalculations(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableGST,
      'userId = ?',
      [userId],
    );
    return results.map((e) => GSTCalculationModel.fromMap(e)).toList();
  }

  // Get calculations by date range
  Future<List<GSTCalculationModel>> getCalculationsByDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allCalculations = await getAllCalculations(userId);
    return allCalculations.where((calc) {
      return calc.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          calc.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Delete calculation
  Future<bool> deleteCalculation(int id) async {
    final result = await _db.delete(AppStrings.tableGST, id);
    return result > 0;
  }

  // Get summary report
  Future<Map<String, double>> getSummaryReport({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final calculations = await getCalculationsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalAmount = 0;
    double totalCGST = 0;
    double totalSGST = 0;
    double totalGST = 0;
    double grandTotal = 0;

    for (final calc in calculations) {
      totalAmount += calc.amount;
      totalCGST += calc.cgst;
      totalSGST += calc.sgst;
      totalGST += (calc.cgst + calc.sgst);
      grandTotal += calc.total;
    }

    return {
      'totalAmount': totalAmount,
      'totalCGST': totalCGST,
      'totalSGST': totalSGST,
      'totalGST': totalGST,
      'grandTotal': grandTotal,
    };
  }
}
