import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardController extends ChangeNotifier {
  static const String _bankBoxName = 'bankBox';

  // ۱۔ کیش (اب کی کا نام صرف 'Cash' ہے)
  double cashInHand = 0.0;

  // ۲۔ بینکس کی لسٹ (نام -> بیلنس)
  final Map<String, double> bankBalances = {};

  DashboardController() {
    _loadDataFromHive();
  }

  // ہائیو (bankBox) سے ڈیٹا لوڈ کرنے اور کیز کو صاف رکھنے کا فنکشن
  void _loadDataFromHive() {
    try {
      if (Hive.isBoxOpen(_bankBoxName)) {
        final box = Hive.box(_bankBoxName);

        bankBalances.clear();

        // ۱۔ پرانی 'cashInHand' اور پرانی 'Cash' کیز کو آپس میں ضم (Merge) کرنا
        double totalCash = 0.0;

        if (box.containsKey('cashInHand')) {
          var rawOldCash = box.get('cashInHand');
          totalCash += (rawOldCash is num)
              ? rawOldCash.toDouble()
              : (double.tryParse(rawOldCash.toString()) ?? 0.0);
          box.delete('cashInHand'); // پرانی کی ڈیلیٹ
        }

        if (box.containsKey('Cash')) {
          var rawCash = box.get('Cash');
          totalCash += (rawCash is num)
              ? rawCash.toDouble()
              : (double.tryParse(rawCash.toString()) ?? 0.0);
        }

        cashInHand = totalCash;
        box.put('Cash', cashInHand); // ایک ہی مرکزی کی 'Cash' میں محفوظ

        // ۲۔ باقی تمام بینک کیز کو صاف کرنا
        List<String> keysToDelete = [];
        Map<String, double> cleanEntriesToSave = {};

        for (var key in box.keys) {
          String keyStr = key.toString();

          if (keyStr != 'cashInHand' && keyStr != 'Cash') {
            var rawVal = box.get(key);
            double val = (rawVal is num)
                ? rawVal.toDouble()
                : (double.tryParse(rawVal.toString()) ?? 0.0);

            if (keyStr.startsWith('bank_')) {
              keysToDelete.add(keyStr);
              String cleanName = keyStr.replaceFirst('bank_', '');
              cleanEntriesToSave[cleanName] = val;
            } else {
              bankBalances[keyStr] = val;
            }
          }
        }

        // پرانی 'bank_' والی کیز کو ڈیلیٹ کرنا
        for (var oldKey in keysToDelete) {
          box.delete(oldKey);
        }

        // صاف کیز کو ہائیو میں سیو کرنا
        cleanEntriesToSave.forEach((cleanKey, balance) {
          box.put(cleanKey, balance);
          bankBalances[cleanKey] = balance;
        });
      }
    } catch (e) {
      debugPrint("Hive Bank Load Error: $e");
    }
  }

  void _saveCashToHive() {
    if (Hive.isBoxOpen(_bankBoxName)) {
      Hive.box(_bankBoxName).put('Cash', cashInHand);
    }
  }

  void _saveBankToHive(String bankName, double balance) {
    if (Hive.isBoxOpen(_bankBoxName)) {
      Hive.box(_bankBoxName).put(bankName, balance);
    }
  }

  void _deleteBankFromHive(String bankName) {
    if (Hive.isBoxOpen(_bankBoxName)) {
      Hive.box(_bankBoxName).delete(bankName);
    }
  }

  double get totalBankBalance {
    double total = 0.0;
    bankBalances.forEach((key, value) {
      total += value;
    });
    return total;
  }

  double netProfit = 0.0;
  final Map<String, double> profitLossDetails = {
    'Total Discounts': 0.0,
    'Transactions Profit': 0.0,
  };

  double totalInvestment = 0.0;
  double get otherIncome => totalInvestment;
  set otherIncome(double value) {
    totalInvestment = value;
    notifyListeners();
  }

  final Map<String, double> expenseCategories = {};
  double get totalExpenses {
    double total = 0.0;
    expenseCategories.forEach((key, value) {
      total += value;
    });
    return total;
  }

  // کیش اپ ڈیٹ
  void updateCash(double amount) {
    cashInHand += amount;
    _saveCashToHive();
    notifyListeners();
  }

  // بینک بیلنس اپ ڈیٹ یا ڈیڈکٹ کرنا (ڈائریکٹ بینک کے اصل نام پر)
  void adjustBankBalance(String bankName, double amount) {
    if (bankName == 'Cash' || bankName == 'cashInHand') {
      updateCash(amount);
      return;
    }

    if (bankBalances.containsKey(bankName)) {
      bankBalances[bankName] = (bankBalances[bankName] ?? 0.0) + amount;
    } else {
      bankBalances[bankName] = amount;
    }
    _saveBankToHive(bankName, bankBalances[bankName]!);
    notifyListeners();
  }

  void updateBankBalance(String bankName, double newBalance) {
    if (bankName == 'Cash' || bankName == 'cashInHand') {
      cashInHand = newBalance;
      _saveCashToHive();
    } else {
      bankBalances[bankName] = newBalance;
      _saveBankToHive(bankName, newBalance);
    }
    notifyListeners();
  }

  void renameBank(String oldName, String newName) {
    if (bankBalances.containsKey(oldName)) {
      final double currentBalance = bankBalances[oldName] ?? 0.0;
      bankBalances.remove(oldName);
      _deleteBankFromHive(oldName);

      bankBalances[newName] = currentBalance;
      _saveBankToHive(newName, currentBalance);
      notifyListeners();
    }
  }

  void removeBank(String bankName) {
    if (bankBalances.containsKey(bankName)) {
      bankBalances.remove(bankName);
      _deleteBankFromHive(bankName);
      notifyListeners();
    }
  }

  void addProfit(double profitAmount) {
    netProfit += profitAmount;
    notifyListeners();
  }

  void updateTotalInvestment(double amount) {
    totalInvestment = amount;
    notifyListeners();
  }

  void addExpenseCategory(String name, double initialAmount) {
    expenseCategories[name] = initialAmount;
    notifyListeners();
  }

  void adjustExpenseAmount(String name, double amount) {
    if (expenseCategories.containsKey(name)) {
      expenseCategories[name] = (expenseCategories[name] ?? 0.0) + amount;
      notifyListeners();
    }
  }
}

final dashboardController = DashboardController();