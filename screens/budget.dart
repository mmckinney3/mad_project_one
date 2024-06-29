import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class BudgetScreen extends StatelessWidget {
  final List<Expense> expenses;
  final double totalBudget;
  final Function(double) onBudgetChanged; // Callback to update budget

  const BudgetScreen({
    Key? key,
    required this.expenses,
    required this.totalBudget,
    required this.onBudgetChanged,
  }) : super(key: key);

  Map<String, double> calculateCategoryExpenses() {
    Map<String, double> categoryExpenses = {};
    for (var expense in expenses) {
      if (!categoryExpenses.containsKey(expense.category)) {
        categoryExpenses[expense.category] = 0;
      }
      categoryExpenses[expense.category] = categoryExpenses[expense.category]! + expense.amount;
    }
    return categoryExpenses;
  }

  Map<String, Color> getCategoryColors() {
    return {
      "Food": Colors.pink,
      "Groceries": Colors.blueAccent,
      "Gas": Colors.orange,
      "Entertainment": Colors.purple,
      "Other": Colors.green,
    };
  }

  void _showEditBudgetDialog(BuildContext context) {
    TextEditingController _budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Budget'),
          content: TextField(
            controller: _budgetController,
            decoration: const InputDecoration(labelText: 'Enter new budget'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                   ), // Change text color here
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double newBudget = double.parse(_budgetController.text);
                onBudgetChanged(newBudget); // Update budget in HomePage
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
                   ), // Change text color here
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = calculateCategoryExpenses();
    final categoryColors = getCategoryColors();
    final totalSpent = categoryExpenses.values.fold(0.0, (sum, item) => sum + item);
    final budgetLeft = totalBudget - totalSpent;
    final budgetUsagePercentage = totalSpent / totalBudget;

    // Check if there are no expenses to determine whether to show the grayed-out pie chart
    final bool hasExpenses = categoryExpenses.isNotEmpty;

    return Scaffold(
      body: Column(
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
                    'Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Budget: ',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
                        ),
                        Text(
                          '\$${totalBudget.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () => _showEditBudgetDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: budgetUsagePercentage,
                    color: budgetUsagePercentage > 1.0 ? Colors.orange[400] : Colors.lightGreenAccent[400],
                    minHeight: 10, // Set this to your desired thickness
                  ),
                ),
              ],
            ),
          ),
          Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insights',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryColors.entries.map((entry) {
                        final category = entry.key;
                        final color = entry.value;
                        final amountSpent = categoryExpenses[category] ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(category),
                                    Text('\$${amountSpent.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Custom PieChart widget that shows hollow grayed-out circle if no expenses
                    CustomPieChart(
                      hasExpenses: hasExpenses,
                      categoryExpenses: categoryExpenses,
                      categoryColors: categoryColors,
                      totalSpent: totalSpent,
                      totalBudget: totalBudget,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPieChart extends StatelessWidget {
  final bool hasExpenses;
  final Map<String, double> categoryExpenses;
  final Map<String, Color> categoryColors;
  final double totalSpent;
  final double totalBudget;

  const CustomPieChart({
    Key? key,
    required this.hasExpenses,
    required this.categoryExpenses,
    required this.categoryColors,
    required this.totalSpent,
    required this.totalBudget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool exceedsBudget = totalSpent > totalBudget;

    return SizedBox(
      height: 250, // Adjusted height for smaller pie chart
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grayed-out hollow circle when there are no expenses
          if (!hasExpenses)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3), // Gray color with opacity
              ),
              child: Center(
                child: Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          // Actual PieChart
          PieChart(
            PieChartData(
              sections: categoryExpenses.entries.map((entry) {
                final category = entry.key;
                final amountSpent = entry.value;
                final color = categoryColors[category] ?? Colors.grey; // Use grey if category color not found

                // Calculate percentage
                final percentage = (amountSpent / totalSpent) * 100.0;

                return PieChartSectionData(
                  color: color,
                  value: percentage,
                  title: '${percentage.toStringAsFixed(1)}%', // Display percentage
                  radius: 50, // Smaller radius for smaller pie chart
                  titleStyle: const TextStyle(
                    fontSize: 12, // Adjusted font size for percentage
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          // Text widget to display the total amount spent in the center
          if (hasExpenses)
            Positioned(
              child: Text(
                '\$${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24, // Font size for total spent amount
                  fontWeight: FontWeight.bold,
                  color: exceedsBudget ? Colors.red : Colors.black, // Change color to red if exceeds budget
                ),
              ),
            ),
        ],
      ),
    );
  }
}
