import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/transactions_page.dart';
import '../pages/add_transaction_page.dart';
import '../pages/categories_page.dart';
// import '../pages/profile_page.dart';
// import '../pages/edit_profile_page.dart';

class AppRoutes {
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const addTransaction = '/add';
  static const categories = '/categories';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';

  static final routes = <String, WidgetBuilder>{
    dashboard: (context) => const DashboardPage(),
    transactions: (context) => const TransactionsPage(),
    addTransaction: (context) => const AddTransactionPage(),
    categories: (context) => const CategoriesPage(),
    // profile: (context) => const ProfilePage(),
    // editProfile: (context) => const EditProfilePage(),
  };
}
