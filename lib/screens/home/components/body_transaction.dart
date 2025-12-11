import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/screens/home/components/category_icon_widget.dart';
import 'package:expense_tracker/screens/home/components/transaction_row_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BodyTransactions extends StatefulWidget {
  const BodyTransactions({super.key});
  
  @override
  State<BodyTransactions> createState() => _BodyTransactionsState();
}

class _BodyTransactionsState extends State<BodyTransactions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
      context.read<CategoriesProvider>().fetchCategories();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<TransactionProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDate(picked);
    }
  }

  void _showCategoryFilterSheet(BuildContext context) {
    final categories = context.read<CategoriesProvider>().categories;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionChip(
                    label: const Text("All Categories"),
                    avatar: const Icon(Icons.clear_all),
                    onPressed: () {
                      context.read<TransactionProvider>().setCategory(null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...categories.map((cat) => ActionChip(
                    label: Text(cat.name),
                    avatar: const Icon(Icons.category, size: 16),
                    onPressed: () {
                      context.read<TransactionProvider>().setCategory(cat.id);
                      Navigator.pop(ctx);
                    },
                  )),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Row(
                  children: [
                    _buildFilterChip(provider, 'All', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(provider, 'Income', 'income'),
                    const SizedBox(width: 8),
                    _buildFilterChip(provider, 'Expense', 'expense'),
                  ],
                ),
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: Consumer2<TransactionProvider, CategoriesProvider>(
            builder: (context, transactionProvider, categoriesProvider, child) {
              final dateButtonText = transactionProvider.selectedDate != null
                  ? "${transactionProvider.selectedDate!.day}/${transactionProvider.selectedDate!.month}/${transactionProvider.selectedDate!.year}"
                  : 'Date';

              String categoryButtonText = 'Filter by Category';
              if (transactionProvider.selectedCategory != null) {
                final category = categoriesProvider.getCategoryById(transactionProvider.selectedCategory!);
                if (category != null) {
                  categoryButtonText = category.name;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(transactionProvider.selectedCategory != null ? Icons.filter_alt : Icons.filter_list),
                      label: Text(categoryButtonText),
                      style: transactionProvider.selectedCategory != null
                        ? OutlinedButton.styleFrom(backgroundColor: Colors.blue.shade50, side: const BorderSide(color: Colors.blue))
                        : null,
                      onPressed: () => _showCategoryFilterSheet(context),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      icon: Icon(transactionProvider.selectedDate != null ? Icons.event_available : Icons.calendar_today, size: 18),
                      label: Text(dateButtonText),
                      style: transactionProvider.selectedDate != null
                        ? OutlinedButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            side: const BorderSide(color: Colors.blue),
                            foregroundColor: Colors.blue,
                          )
                        : null,
                      onPressed: () {
                        if (transactionProvider.selectedDate != null) {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Change Date'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _selectDate(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.clear, color: Colors.red),
                                  title: const Text('Clear Date Filter', style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    transactionProvider.setDate(null);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ],
                            )
                          );
                        } else {
                          _selectDate(context);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: Consumer<CategoriesProvider>(
            builder: (context, categoriesProvider, child) {
              if (categoriesProvider.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categories = categoriesProvider.categories;
              
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 12.0,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final transactionProvider = context.watch<TransactionProvider>();
                    final isSelected = transactionProvider.selectedCategory == category.id;

                    return CategoryIconWidget(
                      category: category,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<TransactionProvider>().setCategory(category.id);
                      },
                    );
                  },
                  childCount: categories.length,
                ),
              );
            },
          ),
        ),

        Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final transactions = List<TransactionModel>.from(provider.transactions);
            transactions.sort((a, b) => b.date.compareTo(a.date));

            if (transactions.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "No transactions found",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TransactionRow(transaction: transactions[index]),
                  );
                },
                childCount: transactions.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(TransactionProvider provider, String label, String filterKey) {
    final isSelected = provider.currentFilter == filterKey;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          provider.setFilter(filterKey);
        }
      },
      shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      backgroundColor: Colors.white,
    );
  }
}