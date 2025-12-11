import 'package:expense_tracker/core/constants/currency_formater.dart';
import 'package:expense_tracker/core/widgets/themes/app_colors.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/home/components/transaction_row_icon.dart';
import 'package:expense_tracker/screens/home/transaction_screen.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Guest';
    final settingsProvider = context.watch<SettingsProvider>();
    final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);

    Size size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFDDDDDD),
                  width: 1.0,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    "Good Morning, $userName!",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Text(
                    "${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              final transactions = transactionProvider.transactions;
              
              final totalIncome = transactions
                  .where((t) => t.type == 'income')
                  .fold(0.0, (sum, t) => sum + t.amount);
              
              final totalExpense = transactions
                  .where((t) => t.type == 'expense')
                  .fold(0.0, (sum, t) => sum + t.amount);
              
              final totalBalance = totalIncome - totalExpense;

              // Calculate stats
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final weekStart = today.subtract(Duration(days: now.weekday - 1));
              final monthStart = DateTime(now.year, now.month, 1);

              final todayExpense = transactions
                  .where((t) => t.type == 'expense' && 
                        t.date.year == today.year &&
                        t.date.month == today.month &&
                        t.date.day == today.day)
                  .fold(0.0, (sum, t) => sum + t.amount);

              final weekExpense = transactions
                  .where((t) => t.type == 'expense' && t.date.isAfter(weekStart))
                  .fold(0.0, (sum, t) => sum + t.amount);

              final monthExpense = transactions
                  .where((t) => t.type == 'expense' && t.date.isAfter(monthStart))
                  .fold(0.0, (sum, t) => sum + t.amount);

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [bluePrimaryColor, violetPrimaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Balance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$currencySymbol${totalBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Income", style: TextStyle(color: Colors.white70, fontSize: 16)),
                                const SizedBox(height: 5),
                                Text("$currencySymbol${totalIncome.toStringAsFixed(2)}", 
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Expenses", style: TextStyle(color: Colors.white70, fontSize: 16)),
                                const SizedBox(height: 5),
                                Text('$currencySymbol${totalExpense.toStringAsFixed(2)}', 
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusChip(Icons.calendar_view_day, Colors.green, '$currencySymbol${todayExpense.toStringAsFixed(2)}'),
                        _buildStatusChip(Icons.calendar_view_week, Colors.blue, '$currencySymbol${weekExpense.toStringAsFixed(2)}'),
                        _buildStatusChip(Icons.calendar_today, Colors.orange, '$currencySymbol${monthExpense.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final displayTransactions = provider.transactions.take(3).toList();

                if (displayTransactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: ListView.builder(
                    itemCount: displayTransactions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7.0),
                        child: TransactionRow(transaction: displayTransactions[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, Color color, String label) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      backgroundColor: Colors.white,
      shape: const StadiumBorder(
        side: BorderSide(color: Color(0xFFEEEEEE)),
      ),
    );
  }
}