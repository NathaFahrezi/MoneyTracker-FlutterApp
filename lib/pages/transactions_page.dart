import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori')),
        );
        return;
      }

      final newTx = TransactionModel(
        id: DateTime.now().toIso8601String(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        isIncome: _isIncome,
      );

      setState(() {
        TransactionService.addTransaction(newTx);
        _titleController.clear();
        _amountController.clear();
        _selectedCategoryId = null;
        _isIncome = false;
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryService.getCategories();

    final transactions = TransactionService.getTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Judul Transaksi'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Jumlah wajib diisi';
                      final n = double.tryParse(val);
                      if (n == null || n <= 0) return 'Jumlah tidak valid';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Pilih Kategori'),
                    items: categories
                        .map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Kategori wajib dipilih' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
                      ),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Pilih Tanggal'),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Apakah ini pemasukan?'),
                    value: _isIncome,
                    onChanged: (val) {
                      setState(() {
                        _isIncome = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Tambah Transaksi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final category = categories.firstWhere(
                          (c) => c.id == tx.categoryId,
                          orElse: () => CategoryService.getCategories().first,
                        );
                        return Card(
                          child: ListTile(
                            leading: Icon(tx.isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward),
                            title: Text(tx.title),
                            subtitle: Text(
                                '${category.name} - ${DateFormat('dd MMM yyyy').format(tx.date)}'),
                            trailing: Text(
                              (tx.isIncome ? '+' : '-') + 'Rp ${tx.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: tx.isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
