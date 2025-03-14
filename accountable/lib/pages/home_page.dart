import 'package:accountable/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  final String detailsPath;

  const HomePage({Key? key, required this.detailsPath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                // Navigate to previous date
              },
            ),
            Text(
              'Dec 24',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // Navigate to next date
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '16,938.81',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              _buildDayExpense(
                day: 'Tue 17',
                totalExpense: '90,299',
                expenses: [
                  _buildExpenseItem(
                    icon: Icons.directions_bus,
                    title: 'Transport',
                    subtitle: 'Grab',
                    amount: '100',
                    context: context,
                  ),
                  _buildExpenseItem(
                    icon: Icons.directions_bus,
                    title: 'Transport',
                    subtitle: 'Bolt',
                    amount: '100',
                    context: context,
                  ),
                  _buildExpenseItem(
                    icon: Icons.restaurant,
                    title: 'Food',
                    subtitle: 'Robinhood',
                    amount: '99',
                    context: context,
                  ),
                  _buildExpenseItem(
                    icon: Icons.school,
                    title: 'Education',
                    subtitle:
                        'King Mongkut\'s Institute of Technology Ladkrabang',
                    amount: '90,000',
                    context: context,
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDayExpense(
                day: 'Mon 16',
                totalExpense: '320',
                expenses: [
                  _buildExpenseItem(
                    icon: Icons.category,
                    title: 'Other',
                    subtitle: '...',
                    amount: '320',
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
    );
  }

  Widget _buildDayExpense({
    required String day,
    required String totalExpense,
    required List<Widget> expenses,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                  Text(
                    'Expense $totalExpense',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          ...expenses,
        ],
      ),
    );
  }

  Widget _buildExpenseItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
              icon: Icon(icon),
              onPressed: () => context.go(detailsPath),
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
