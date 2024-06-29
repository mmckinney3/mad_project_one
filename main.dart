import 'package:flutter/material.dart';
import 'screens/expenses.dart';
import 'screens/budget.dart';
import 'models/expense.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Expense> _expenses = [];
  double _totalBudget = 1000.0; // Initial total budget

  void updateBudget(double newBudget) {
    setState(() {
      _totalBudget = newBudget;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ExpensesScreen(expenses: _expenses, totalBudget: _totalBudget),
      BudgetScreen(expenses: _expenses, totalBudget: _totalBudget, onBudgetChanged: updateBudget),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker', // Set the title to 'Expense Tracker'
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make text bold
            fontSize: 16.0, // Optional: Adjust font size
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20), // Use arrow icon for navigation
          onPressed: () {
            setState(() {
              _currentIndex = _currentIndex == 0 ? 1 : 0; // Toggle between screens
            });
          },
        ),
        
        backgroundColor: Colors.green[800], // Set background color to green
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: Colors.green[800], // Color of selected item
        unselectedItemColor: Colors.black, // Color of unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Insights',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
