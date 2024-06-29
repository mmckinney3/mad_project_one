import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double totalBudget;

  const ExpensesScreen({Key? key, required this.expenses, required this.totalBudget}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "Food";
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';

  List<String> _selectedCategories = []; // To hold selected categories for filtering

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.expenses.add(Expense(
          name: _nameController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          description: _descriptionController.text,
        ));
      });

      _nameController.clear();
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = "Food";
      });
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      widget.expenses.removeAt(index);
    });
  }

  void _clearAllExpenses() {
    setState(() {
      widget.expenses.clear();
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Expense'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: "Amount"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Category"),
                          DropdownButton<String>(
                            value: _selectedCategory,
                            items: ["Food", "Groceries", "Gas", "Entertainment", "Other"]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: "Description (Optional)"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _nameController.clear();
                    _amountController.clear();
                    _descriptionController.clear();
                    setState(() {
                      _selectedCategory = "Food";
                    });
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveExpense,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
                   ), // Change text color here
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateTotalSpent() {
    return widget.expenses.fold(0, (sum, item) => sum + item.amount);
  }

  List<Expense> _getFilteredExpenses() {
    // No filtering in this version, returning all expenses
    return widget.expenses;
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = _calculateTotalSpent();
    double budgetLeft = widget.totalBudget - totalSpent;
    budgetLeft = budgetLeft < 0 ? 0 : budgetLeft;
    double spentPercentage = (totalSpent / widget.totalBudget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.green[800],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Spending',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Left to spend\n',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: '\$${budgetLeft.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' out of \$${widget.totalBudget.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: spentPercentage,
                  color: spentPercentage > 1.0 ? Colors.orange[400] : Colors.lightGreenAccent[400],
                  minHeight: 10, // Set this to your desired thickness
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Expenses',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddExpenseDialog,
                    tooltip: 'Add New',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0), // Adjust vertical content padding
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: _getFilteredExpenses().length,
              itemBuilder: (context, index) {
                final expense = _getFilteredExpenses()[index];
                return ListTile(
                  title: Text(expense.name),
                  subtitle: Text('${expense.category} - \$${expense.amount.toStringAsFixed(2)} \n${expense.description}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteExpense(index),
                  ),
                );
              },
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: _clearAllExpenses,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // Change text color here
            ),
            child: const Text('Clear'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
