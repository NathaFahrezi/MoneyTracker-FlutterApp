import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _reminderController = TextEditingController();
  List<String> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders = prefs.getStringList('reminders') ?? [];
    });
  }

  Future<void> _addReminder(String reminder) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders.add(reminder);
    });
    await prefs.setStringList('reminders', _reminders);
  }

  Future<void> _deleteReminder(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders.removeAt(index);
    });
    await prefs.setStringList('reminders', _reminders);
  }

  double _calculateTotalIncome(List<TransactionModel> txs) {
    return txs.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpense(List<TransactionModel> txs) {
    return txs.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  }

  List<DateTime> _getLast6Months(DateTime referenceDate) {
    return List.generate(6, (i) {
      final date = DateTime(referenceDate.year, referenceDate.month - (5 - i));
      return DateTime(date.year, date.month);
    });
  }

  List<BarChartGroupData> _buildBarChartData(List<TransactionModel> txs, List<DateTime> months) {
    final Map<String, double> expensePerMonth = {
      for (var date in months) DateFormat('yyyy-MM').format(date): 0.0
    };

    for (var tx in txs) {
      if (!tx.isIncome) {
        final txKey = DateFormat('yyyy-MM').format(tx.date);
        if (expensePerMonth.containsKey(txKey)) {
          expensePerMonth[txKey] = expensePerMonth[txKey]! + tx.amount;
        }
      }
    }

    int index = 0;
    return expensePerMonth.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.green.shade600,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionService.getTransactions();
    final income = _calculateTotalIncome(transactions);
    final expense = _calculateTotalExpense(transactions);
    final balance = income - expense;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    DateTime referenceDate;
    if (transactions.isNotEmpty) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
      referenceDate = transactions.first.date;
    } else {
      referenceDate = DateTime.now();
    }

    final months = _getLast6Months(referenceDate);
    final barGroups = _buildBarChartData(transactions, months);
    final maxY = barGroups.map((e) => e.barRods[0].toY).fold(0.0, (a, b) => a > b ? a : b) * 1.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.green[100],
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.green),
                  title: const Text('Total Pemasukan'),
                  trailing: Text(currencyFormat.format(income)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.red[100],
                child: ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.red),
                  title: const Text('Total Pengeluaran'),
                  trailing: Text(currencyFormat.format(expense)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.blue[100],
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                  title: const Text('Saldo'),
                  trailing: Text(currencyFormat.format(balance)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Grafik Pengeluaran 6 Bulan Terakhir',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY == 0.0 ? 1000000 : maxY,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < months.length) {
                                return Text(DateFormat.MMM().format(months[index]));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Catatan Pengingat', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reminderController,
                      decoration: const InputDecoration(
                        hintText: 'Tambah pengingat...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_reminderController.text.trim().isNotEmpty) {
                        _addReminder(_reminderController.text.trim());
                        _reminderController.clear();
                      }
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._reminders.asMap().entries.map((entry) {
                final index = entry.key;
                final reminder = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(reminder),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReminder(index),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
