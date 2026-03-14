class ApiConstants {
  static const String baseUrl = 'https://appskilltest.zybotech.in';
  
  // Auth
  static const String sendOtp = '/auth/send-otp/';
  static const String createAccount = '/auth/create-account/';

  // Categories
  static const String getCategories = '/categories/';
  static const String addCategory = '/categories/add/';
  static const String deleteCategory = '/categories/delete/';

  // Transactions
  static const String getTransactions = '/transactions/';
  static const String addTransaction = '/transactions/add/';
  static const String deleteTransaction = '/transactions/delete/';
}
