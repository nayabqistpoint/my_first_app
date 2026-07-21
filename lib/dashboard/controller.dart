import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  // 1. کیش ان ہینڈ (شروع میں زیرو)
  double cashInHand = 0.0;

  // 2. بینکس کی لسٹ (شروع میں بالکل خالی - صارف خود ایڈ کرے گا)
  final Map<String, double> bankBalances = {};

  // کل بینک بیلنس نکالنے کا فارمولا
  double get totalBankBalance {
    double total = 0.0;
    bankBalances.forEach((key, value) {
      total += value;
    });
    return total;
  }

  // 3. نیٹ پرافٹ (شروع میں زیرو)
  double netProfit = 0.0;

  // پرافٹ اور ڈسکاؤنٹس کی تفصیلات (شروع میں زیرو)
  final Map<String, double> profitLossDetails = {
    'Total Discounts': 0.0,
    'Transactions Profit': 0.0,
  };

  // 4. ٹوٹل انویسٹمنٹ / ادر انکم (شروع میں زیرو)
  double totalInvestment = 0.0;
  
  double get otherIncome => totalInvestment; 
  set otherIncome(double value) {
    totalInvestment = value;
    notifyListeners();
  }

  // 5. ایکسپنسز کی کیٹیگریز (شروع میں بالکل خالی - صارف خود اپنی کیٹیگریز بنائے گا)
  final Map<String, double> expenseCategories = {};

  // کل ایکسپنسز خود بخود کیلکولیٹ کرنے کا گیٹر
  double get totalExpenses {
    double total = 0.0;
    expenseCategories.forEach((key, value) {
      total += value;
    });
    return total;
  }

  // --- لاجک / فنکشنز ---

  // کیش بڑھانے یا گھٹانے کا فنکشن
  void updateCash(double amount) {
    cashInHand += amount;
    notifyListeners();
  }

  // نیا بینک لسٹ میں جوڑنے یا پرانے کا بیلنس اپ ڈیٹ کرنے کا فنکشن
  void updateBankBalance(String bankName, double newBalance) {
    bankBalances[bankName] = newBalance;
    notifyListeners();
  }

  // کسی بھی مخصوص بینک میں رقم جمع یا مائنس کرنے یا نیا بینک بنانے کے لیے
  void adjustBankBalance(String bankName, double amount) {
    if (bankBalances.containsKey(bankName)) {
      bankBalances[bankName] = (bankBalances[bankName] ?? 0.0) + amount;
    } else {
      bankBalances[bankName] = amount;
    }
    notifyListeners();
  }

  // پرافٹ جوڑنے یا اپ ڈیٹ کرنے کا فنکشن
  void addProfit(double profitAmount) {
    netProfit += profitAmount;
    notifyListeners();
  }

  // ٹوٹل انویسٹمنٹ اپ ڈیٹ کرنے کا فنکشن
  void updateTotalInvestment(double amount) {
    totalInvestment = amount;
    notifyListeners();
  }

  // نئی ایکسپنس کیٹیگری ایڈ کرنے کا فنکشن
  void addExpenseCategory(String name, double initialAmount) {
    expenseCategories[name] = initialAmount;
    notifyListeners();
  }

  // کسی مخصوص ایکسپنس کی رقم کو کم یا زیادہ کرنے کا فنکشن
  void adjustExpenseAmount(String name, double amount) {
    if (expenseCategories.containsKey(name)) {
      expenseCategories[name] = (expenseCategories[name] ?? 0.0) + amount;
      notifyListeners();
    }
  }
}

// پوری ایپ میں ایک ہی کنٹرولر کو شیئر کرنے کے لیے گلوبل ابجیکٹ
final dashboardController = DashboardController();