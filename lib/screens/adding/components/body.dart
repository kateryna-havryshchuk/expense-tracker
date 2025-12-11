import 'package:expense_tracker/core/constants/currency_formater.dart';
import 'package:expense_tracker/core/widgets/themes/app_colors.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/screens/home/components/category_icon_widget.dart';
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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController(); // ✅ Замість title
  final TextEditingController _noteController = TextEditingController();
  
  String _selectedType = 'expense'; // 'income' or 'expense'
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter amount and select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_subtitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a subtitle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final double amount = double.parse(_amountController.text);

      final newTransaction = TransactionModel(
        id: '', // Firestore згенерує ID автоматично
        subtitle: _subtitleController.text.trim(),
        note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
        amount: amount,
        type: _selectedType,
        categoryId: _selectedCategory!.id,
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      await context.read<TransactionProvider>().addTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedType == 'expense' ? 'Expense' : 'Income'} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildAmountInput(),
                    
                    const SizedBox(height: 20),
                    const Text("Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildTypeToggle(),
                    
                    const SizedBox(height: 20),
                    const Text("Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCategoryGrid(),

                    const SizedBox(height: 20),
                    const Text("Subtitle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildSubtitleInput(),

                    const SizedBox(height: 20),
                    const Text("Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildDateSelector(),

                    const SizedBox(height: 20),
                    const Text("Description (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildDescriptionInput(),
                    
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100, 
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [bluePrimaryColor, violetPrimaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Row(
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
          const Expanded(
            child: Text(
              "Add Transaction",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    final settingsProvider = context.watch<SettingsProvider>();
    final currencySymbol = CurrencyFormatter.getSymbol(settingsProvider.selectedCurrency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text("$currencySymbol ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "0.00",
                border: InputBorder.none,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'expense'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'expense' ? Colors.red.shade400 : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_circle_outline, 
                      color: _selectedType == 'expense' ? Colors.white : Colors.black54, size: 18),
                    const SizedBox(width: 8),
                    Text("Expense", 
                      style: TextStyle(
                        color: _selectedType == 'expense' ? Colors.white : Colors.black54, 
                        fontWeight: FontWeight.bold
                      )),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'income'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'income' ? Colors.green.shade400 : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, 
                      color: _selectedType == 'income' ? Colors.white : Colors.black54, size: 18),
                    const SizedBox(width: 8),
                    Text("Income", 
                      style: TextStyle(
                        color: _selectedType == 'income' ? Colors.white : Colors.black54, 
                        fontWeight: FontWeight.bold
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
      );
  }

  Widget _buildSubtitleInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _subtitleController,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: "e.g., Grocery Shopping",
          border: InputBorder.none,
        ),
      )
    );
  }

  Widget _buildCategoryGrid() {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        if (categoriesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = categoriesProvider.categories;

        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "No categories available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return SizedBox(
          height: 210,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory?.id == category.id;

              return CategoryIconWidget(
                category: category,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    // Автоматично заповнюємо title, якщо він порожній
                    if (_subtitleController.text.isEmpty) {
                      _subtitleController.text = category.name;
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Add a note...",
          border: InputBorder.none,
        ),
      )
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C6BC0),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: const Color(0xFF5C6BC0).withValues(alpha: 0.4),
        ),
        child: Text(
          _selectedType == 'expense' ? "Add Expense" : "Add Income",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}