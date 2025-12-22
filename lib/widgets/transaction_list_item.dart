import 'package:flutter/material.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:expense_tracker/utils/constants.dart';

class TransactionListItem extends StatelessWidget {
  final dynamic transaction; // IncomeModel or ExpenseModel
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction is IncomeModel;
    final amount = isIncome
        ? (transaction as IncomeModel).amount
        : (transaction as ExpenseModel).amount;
    final category = isIncome
        ? (transaction as IncomeModel).category
        : (transaction as ExpenseModel).category;
    final notes = isIncome
        ? (transaction as IncomeModel).notes
        : (transaction as ExpenseModel).notes;
    final date = isIncome
        ? (transaction as IncomeModel).date
        : (transaction as ExpenseModel).date;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isIncome
                ? AppColors.income.withValues(alpha: 0.1)
                : AppColors.expense.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notes.isNotEmpty)
              Text(
                notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              Helpers.formatDate(date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${Helpers.formatCurrency(amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: AppColors.error,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
        isThreeLine: notes.isNotEmpty,
      ),
    );
  }
}
