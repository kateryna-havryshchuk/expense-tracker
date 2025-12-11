import 'package:expense_tracker/core/constants/currency_formater.dart';
import 'package:expense_tracker/core/widgets/themes/app_colors.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/screens/main_navigation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<Body> {
  String _selectedPeriod = 'Week';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
      context.read<CategoriesProvider>().fetchCategories();
    });
  }

  List<dynamic> _getFilteredTransactions(TransactionProvider provider) {
    final now = DateTime.now();
    final transactions = provider.transactions;

    if (_selectedDate != null) {
      return transactions.where((t) =>
        t.date.year == _selectedDate!.year &&
        t.date.month == _selectedDate!.month &&
        t.date.day == _selectedDate!.day
      ).toList();
    }

    switch (_selectedPeriod) {
      case 'Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return transactions.where((t) => 
          t.date.isAfter(weekStartMidnight) || 
          t.date.isAtSameMomentAs(weekStartMidnight)
        ).toList();
      
      case 'Month':
        final monthStart = DateTime(now.year, now.month, 1);
        return transactions.where((t) => 
          t.date.isAfter(monthStart) || 
          t.date.isAtSameMomentAs(monthStart)
        ).toList();
      
      case 'Year':
        final yearStart = DateTime(now.year, 1, 1);
        return transactions.where((t) => 
          t.date.isAfter(yearStart) || 
          t.date.isAtSameMomentAs(yearStart)
        ).toList();
      
      default:
        return transactions;
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildHeader(),
          
          Expanded(
            child: Consumer2<TransactionProvider, SettingsProvider>(
              builder: (context, transactionProvider, settingsProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredTransactions = _getFilteredTransactions(transactionProvider);
                final totalIncome = filteredTransactions
                    .where((t) => t.type == 'income')
                    .fold(0.0, (sum, item) => sum + item.amount);
                
                final totalExpense = filteredTransactions
                    .where((t) => t.type == 'expense')
                    .fold(0.0, (sum, item) => sum + item.amount);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTotalCards(totalIncome, totalExpense, settingsProvider),
                        const SizedBox(height: 24),
                        _buildPieChartSection(filteredTransactions, settingsProvider),
                        const SizedBox(height: 24),
                        _buildBarChartSection(filteredTransactions, settingsProvider),
                        const SizedBox(height: 24),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [bluePrimaryColor, violetPrimaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                        (route) => false,
                      );
                    },
                  ),
                  const Text(
                    "Statistics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _selectedDate != null ? Icons.event_available : Icons.calendar_today,
                      color: Colors.white,
                    ),
                    onPressed: _selectedDate != null
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Change Date'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _pickDate();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.clear, color: Colors.red),
                                  title: const Text('Clear Date', style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    setState(() => _selectedDate = null);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      : _pickDate,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['Week', 'Month', 'Year'].map((period) {
                  final isSelected = _selectedPeriod == period && _selectedDate == null;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = period;
                          _selectedDate = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          period,
                          style: TextStyle(
                            color: isSelected ? bluePrimaryColor : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCards(double totalIncome, double totalExpense, SettingsProvider settingsProvider) {
    final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);
    
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            label: "Income",
            amount: totalIncome,
            amountFormatted: "$currencySymbol${totalIncome.toStringAsFixed(0)}",
            icon: Icons.arrow_downward,
            color: Colors.green,
            bgColor: Colors.green.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            label: "Expenses",
            amount: totalExpense,
            amountFormatted: "$currencySymbol${totalExpense.toStringAsFixed(0)}",
            icon: Icons.arrow_upward,
            color: Colors.red,
            bgColor: Colors.red.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required double amount,
    required String amountFormatted,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: bgColor,
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amountFormatted,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(List<dynamic> transactions, SettingsProvider settingsProvider) {
    final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);
    final categoriesProvider = context.watch<CategoriesProvider>();
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("No expenses to show", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    Map<String, double> expensesByCategory = {};
    for (var t in expenses) {
      final category = categoriesProvider.getCategoryById(t.categoryId);
      final categoryName = category?.name ?? 'Unknown';
      
      expensesByCategory[categoryName] = (expensesByCategory[categoryName] ?? 0) + t.amount;
    }

    final totalExpense = expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    
    final colors = [
      Colors.red.shade400, Colors.blue.shade400, Colors.green.shade400,
      Colors.orange.shade400, Colors.purple.shade400, Colors.teal.shade400,
      Colors.pink.shade400, Colors.amber.shade400,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Spending by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    sections: expensesByCategory.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final color = colors[index % colors.length];
                      final percentage = (data.value / totalExpense * 100);
                      
                      return PieChartSectionData(
                        value: data.value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        color: color,
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
                Center(
                  child: Text(
                    "$currencySymbol${totalExpense.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: expensesByCategory.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final color = colors[index % colors.length];
              final percentage = (data.value / totalExpense * 100).toStringAsFixed(0);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: color,
                    ),
                    const SizedBox(width: 10),
                    Text(data.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text("$percentage%", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text("-$currencySymbol${data.value.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection(List<dynamic> transactions, SettingsProvider settingsProvider) {
    final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    
    List<double> weeklySpending = List.filled(7, 0.0);
    final now = DateTime.now();
    
    for (var t in expenses) {
      final difference = now.difference(t.date).inDays;
      if (difference < 7 && difference >= 0) {
        int index = t.date.weekday - 1;
        weeklySpending[index] += t.amount;
      }
    }

    final maxDailySpending = weeklySpending.isNotEmpty 
        ? weeklySpending.reduce((curr, next) => curr > next ? curr : next)
        : 0.0;
    
    final averageDailySpending = weeklySpending.isNotEmpty
        ? weeklySpending.reduce((a, b) => a + b) / 7
        : 0.0;
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Weekly Spending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("Details")),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '$currencySymbol${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: weeklySpending.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: Colors.blue.shade400,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text("Max Daily", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text("$currencySymbol${maxDailySpending.toStringAsFixed(0)}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text("Avg Daily", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text("$currencySymbol${averageDailySpending.toStringAsFixed(0)}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}