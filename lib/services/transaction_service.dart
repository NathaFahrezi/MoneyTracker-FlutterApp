import '../models/transaction_model.dart';

class TransactionService {
  static final List<TransactionModel> _transactions = [];

  static List<TransactionModel> getTransactions() => _transactions;

  static void addTransaction(TransactionModel tx) {
    _transactions.add(tx);
  }

  static void removeTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
  }
}
