import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/core/constants/currency_formater.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionRow({
    super.key,
    required this.transaction,
  });

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[date.month - 1];
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month ${date.day}, ${date.hour}:$minute';
  }

  IconData _parseIcon(String? iconString) {
    final iconMap = {
      'utensils': FontAwesomeIcons.utensils,
      'car': FontAwesomeIcons.car,
      'bagShopping': FontAwesomeIcons.bagShopping,
      'gamepad': FontAwesomeIcons.gamepad,
      'briefcase': FontAwesomeIcons.briefcase,
      'heartPulse': FontAwesomeIcons.heartPulse,
      'graduationCap': FontAwesomeIcons.graduationCap,
      'ellipsis': FontAwesomeIcons.ellipsis,
    };

    return iconMap[iconString] ?? FontAwesomeIcons.question;
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey;
    }
    
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _showTransactionDetails(BuildContext context) {
    final category = Provider.of<CategoriesProvider>(context, listen: false)
        .getCategoryById(transaction.categoryId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _parseColor(category?.color).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      _parseIcon(category?.icon),
                      color: _parseColor(category?.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transaction.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Date', _formatDate(transaction.date)),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Amount',
                '${transaction.type == 'expense' ? '-' : '+'} ${CurrencyFormatter.getSymbol(Provider.of<SettingsProvider>(ctx, listen: false).selectedCurrency)}${transaction.amount.toStringAsFixed(2)}',
                color: transaction.type == 'expense' ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Type', transaction.type == 'expense' ? 'Expense' : 'Income'),
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transaction.note!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              
              // ✅ Кнопка видалення
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx); // Закриваємо модальне вікно
                    
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Transaction'),
                        content: const Text('Are you sure you want to delete this transaction?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await context.read<TransactionProvider>().deleteTransaction(transaction.id);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Transaction'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, CategoriesProvider>(
      builder: (context, settingsProvider, categoriesProvider, child) {
        final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);
        final category = categoriesProvider.getCategoryById(transaction.categoryId);
        
        final isExpense = transaction.type == 'expense';
        final amountString = '${isExpense ? '-' : '+'} $currencySymbol${transaction.amount.toStringAsFixed(2)}';
        final amountColor = isExpense ? Colors.red : Colors.green;

        final categoryName = category?.name ?? 'Unknown';

        final iconData = _parseIcon(category?.icon);
        final iconColor = _parseColor(category?.color);

        return GestureDetector(
          onTap: () => _showTransactionDetails(context),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      iconData,
                      color: iconColor.withValues(alpha: 0.8),
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}