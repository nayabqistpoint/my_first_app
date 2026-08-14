import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'balance_helper.dart';

class CustomerController extends ChangeNotifier {
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  String _searchQuery = "";

  List<Map<String, dynamic>> get customers => _filteredCustomers;

  /// کسٹمر باکس سے ڈیٹا محفوظ طریقے سے لوڈ کرنا
  void loadAndSortCustomers() {
    try {
      // 🎯 اگر باکس اوپن نہ ہو تو Safe Check (کریش سے بچاؤ)
      if (!Hive.isBoxOpen('customerBox')) return;

      Box customerBox = Hive.box('customerBox');
      Box? transactionBox = Hive.isBoxOpen('transactionBox') 
          ? Hive.box('transactionBox') 
          : null;

      List<Map<String, dynamic>> tempList = [];

      for (var key in customerBox.keys) {
        var customerData = customerBox.get(key);

        if (customerData != null) {
          Map<String, dynamic> cMap = {};
          if (customerData is Map) {
            cMap = Map<String, dynamic>.from(customerData);
          }

          String name = (cMap['customerName'] ?? cMap['name'] ?? 'نامعلوم').toString();
          String phone = (cMap['customerPhone'] ?? key ?? '').toString();

          double balance = BalanceHelper.calculateCustomerBalance(transactionBox, phone);

          cMap['name'] = name;
          cMap['phone'] = phone;
          cMap['description'] = cMap['customerAddress'] ?? 'مینول پارٹی';
          cMap['calculatedBalance'] = balance;

          tempList.add(cMap);
        }
      }

      // سارٹنگ: غیر صفر بیلنس اوپر، زیرو بیلنس نیچے
      tempList.sort((a, b) {
        double balA = (a['calculatedBalance'] as double).abs();
        double balB = (b['calculatedBalance'] as double).abs();

        if (balA > 0 && balB == 0) return -1;
        if (balA == 0 && balB > 0) return 1;
        return 0;
      });

      _allCustomers = tempList;
      _applySearch();
    } catch (e) {
      debugPrint("Error loading customers: $e");
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_allCustomers);
    } else {
      _filteredCustomers = _allCustomers.where((c) {
        String name = (c['name'] ?? '').toString().toLowerCase();
        String phone = (c['phone'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }
}