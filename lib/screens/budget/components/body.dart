import 'package:expense_tracker/core/constants/currency_formater.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().fetchBudgets();
      context.read<CategoriesProvider>().fetchCategories();
    });
  }

  // ✅ Показати діалог додавання/редагування бюджету
  void _showBudgetDialog({Budget? existingBudget}) {
    final categoriesProvider = context.read<CategoriesProvider>();
    final categories = categoriesProvider.categories;
    
    String? selectedCategoryId = existingBudget?.categoryId;
    final limitController = TextEditingController(
      text: existingBudget?.limit.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(existingBudget == null ? 'Add Budget' : 'Edit Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Limit Input
                  TextFormField(
                    controller: limitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Monthly Limit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCategoryId == null || limitController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final limit = double.tryParse(limitController.text) ?? 0;
                    if (limit <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Limit must be greater than 0')),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";

                    if (existingBudget == null) {
                      // ✅ Додати новий бюджет
                      final newBudget = Budget(
                        id: '',
                        categoryId: selectedCategoryId!,
                        month: month,
                        limit: limit,
                        spent: 0,
                        createdAt: DateTime.now(),
                      );
                      await context.read<BudgetProvider>().addBudget(newBudget);
                    } else {
                      // ✅ Оновити існуючий бюджет
                      final updatedBudget = Budget(
                        id: existingBudget.id,
                        categoryId: selectedCategoryId!,
                        month: month,
                        limit: limit,
                        spent: existingBudget.spent,
                        createdAt: existingBudget.createdAt,
                      );
                      await context.read<BudgetProvider>().updateBudget(updatedBudget);
                    }

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existingBudget == null 
                            ? 'Budget added successfully' 
                            : 'Budget updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(existingBudget == null ? 'Add' : 'Update', 
                    style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Показати діалог видалення
  void _showDeleteDialog(Budget budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<BudgetProvider>().deleteBudget(budget.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildHeader(context),
          
          Expanded(
            child: Consumer3<BudgetProvider, CategoriesProvider, SettingsProvider>(
              builder: (context, budgetProvider, categoriesProvider, settingsProvider, child) {
                if (budgetProvider.isLoading || categoriesProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final budgets = budgetProvider.budgets;
                final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainBudgetCard(budgetProvider, currencySymbol),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Budget by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => _showBudgetDialog(),
                              icon: const Icon(Icons.add_circle, color: Color(0xFF5C6BC0)),
                            ),
                          ],
                        ),
                        
                        if (budgets.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No budgets set yet", style: TextStyle(color: Colors.grey))),
                          )
                        else
                          ...budgets.map((budget) => _buildBudgetRow(
                            budget, currencySymbol, categoriesProvider
                          )).toList(),
                        
                        const SizedBox(height: 24),
                        
                        const Text("Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        if (budgets.any((b) => b.isExceeded))
                          _buildInsightCard(
                            icon: Icons.warning_amber_rounded,
                            title: "Budget Exceeded",
                            subtitle: "You've exceeded your budget in ${budgets.where((b) => b.isExceeded).length} categories",
                            bgColor: Colors.red.shade50,
                            iconColor: Colors.red,
                          ),
                          
                        const SizedBox(height: 12),
                        
                        if (budgets.isNotEmpty && budgets.any((b) => !b.isExceeded && b.percentage < 0.5))
                          _buildInsightCard(
                            icon: Icons.trending_up,
                            title: "On Track",
                            subtitle: "You're doing great! Keep monitoring your spending.",
                            bgColor: Colors.blue.shade50,
                            iconColor: Colors.blue,
                          ),

                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat("Categories", "${budgets.length}", Colors.purple),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickStat("Exceeded", "${budgets.where((b) => b.isExceeded).length}", Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                  (route) => false,
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "Budget",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBudgetCard(BudgetProvider provider, String currencySymbol) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly Budget", style: TextStyle(color: Colors.white70)),
              Text("Remaining", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$currencySymbol${provider.totalLimit.toStringAsFixed(0)}", 
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              Text("$currencySymbol${provider.totalRemaining.toStringAsFixed(0)}", 
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spent: $currencySymbol${provider.totalSpent.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white70)),
              Text("${(provider.totalPercentage * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.totalPercentage,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(Budget budget, String currencySymbol, CategoriesProvider categoriesProvider) {
    final percent = (budget.spent / budget.limit * 100).toStringAsFixed(0);
    final isExceeded = budget.isExceeded;
    
    final category = categoriesProvider.getCategoryById(budget.categoryId);
    final categoryName = category?.name ?? 'Unknown';
    
    Color categoryColor = Colors.grey;
    if (category?.color != null) {
      try {
        final hexColor = category!.color!.replaceAll('#', '');
        categoryColor = Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        categoryColor = Colors.grey;
      }
    }

    IconData categoryIcon = Icons.category;
    if (category?.icon != null) {
      final iconMap = {
        'utensils': Icons.restaurant,
        'car': Icons.directions_car,
        'bagShopping': Icons.shopping_bag,
        'gamepad': Icons.sports_esports,
        'briefcase': Icons.work,
        'heartPulse': Icons.favorite,
        'graduationCap': Icons.school,
        'ellipsis': Icons.more_horiz,
      };
      categoryIcon = iconMap[category!.icon] ?? Icons.category;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 20),
              ),
              const SizedBox(width: 16),
              // Title & Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("$currencySymbol${budget.spent.toStringAsFixed(0)} of $currencySymbol${budget.limit.toStringAsFixed(0)}", 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
              // Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$percent%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    isExceeded ? "$currencySymbol${(budget.spent - budget.limit).toStringAsFixed(0)} over" 
                               : "$currencySymbol${budget.remaining.toStringAsFixed(0)} left",
                    style: TextStyle(
                      color: isExceeded ? Colors.red : categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showBudgetDialog(existingBudget: budget);
                  } else if (value == 'delete') {
                    _showDeleteDialog(budget);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(
                    children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')],
                  )),
                  const PopupMenuItem(value: 'delete', child: Row(
                    children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: budget.percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isExceeded ? Colors.red : categoryColor),
            ),
          ),
          if (isExceeded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text("Budget exceeded", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon, 
    required String title, 
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}