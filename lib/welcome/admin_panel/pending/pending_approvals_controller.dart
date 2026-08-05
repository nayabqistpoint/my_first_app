import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PendingApprovalsController extends ChangeNotifier {
  List<Map<String, dynamic>> _pendingTransactions = [];
  List<Map<String, dynamic>> get pendingTransactions => _pendingTransactions;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // 🔴 رئیل ٹائم اور بالکل درست کاؤنٹ گیٹر
  int get pendingCount => _pendingTransactions.length;

  PendingApprovalsController() {
    loadPendingTransactions();
  }

  // 📥 ہائیو باکس سے صرف پینڈنگ انٹریز لوڈ کرنا
  Future<void> loadPendingTransactions() async {
    _isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> tempPending = [];

    try {
      if (Hive.isBoxOpen('transactionBox')) {
        var box = Hive.box('transactionBox');

        for (var key in box.keys) {
          var txValue = box.get(key);
          if (txValue != null && txValue is Map) {
            String status = txValue['status']?.toString() ?? '';
            bool isApproved = txValue['isApproved'] ?? true;

            // صرف پینڈنگ انٹریز اٹھائیں
            if (status == 'pending' || status.toLowerCase() == 'pending' || isApproved == false) {
              Map<String, dynamic> txMap = Map<String, dynamic>.from(txValue);
              // ہر انٹری کو اس کی اپنی اصل ہائیو کی (hiveKey) کے ساتھ محفوظ کریں
              txMap['hiveKey'] = key;
              tempPending.add(txMap);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading pending transactions: $e");
    }

    _pendingTransactions = tempPending.reversed.toList();
    _isLoading = false;
    notifyListeners(); // یہ باہر اور اندر دونوں کے کاؤنٹ کو فورا سنک کر دے گا
  }

  // 🔍 'customerBox' سے موبائل نمبر کے ذریعے نام، کاسٹ اور تصویر (سیلفی) نکالنا
  Map<String, dynamic> getCustomerDetails(String phone) {
    String name = '';
    String caste = '';
    String selfie = '';

    try {
      String targetPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (targetPhone.isEmpty) return {'name': name, 'caste': caste, 'selfie': selfie};

      if (Hive.isBoxOpen('customerBox')) {
        var customerBox = Hive.box('customerBox');
        
        for (var key in customerBox.keys) {
          var customer = customerBox.get(key);
          if (customer != null && customer is Map) {
            String dbPhone = (customer['customerPhone'] ?? customer['phone'] ?? '').toString();
            String dbName = (customer['customerName'] ?? customer['name'] ?? '').toString();
            String dbCaste = (customer['customerCaste'] ?? customer['cast'] ?? '').toString();
            String dbSelfie = (customer['customerSelfie'] ?? customer['selfie'] ?? '').toString();

            String cleanedDbPhone = dbPhone.replaceAll(RegExp(r'[^0-9]'), '');

            if (cleanedDbPhone.isNotEmpty && (cleanedDbPhone == targetPhone || cleanedDbPhone.endsWith(targetPhone) || targetPhone.endsWith(cleanedDbPhone))) {
              if (dbName.trim().isNotEmpty) name = dbName.trim();
              if (dbCaste.trim().isNotEmpty) caste = dbCaste.trim();
              if (dbSelfie.trim().isNotEmpty) selfie = dbSelfie.trim();
              return {'name': name, 'caste': caste, 'selfie': selfie};
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching customer details: $e");
    }

    return {'name': name, 'caste': caste, 'selfie': selfie};
  }

  // ✅ صرف اس مخصوص انٹری کو منظور (Approve) کرنا جس پر کلک ہوا ہو
  Future<void> approveTransaction(dynamic hiveKey) async {
    try {
      if (Hive.isBoxOpen('transactionBox')) {
        var box = Hive.box('transactionBox');
        var txValue = box.get(hiveKey);

        if (txValue != null && txValue is Map) {
          Map<String, dynamic> updatedTx = Map<String, dynamic>.from(txValue);
          updatedTx['status'] = 'approved';
          updatedTx['isApproved'] = true;

          // صرف اسی خاص کی (hiveKey) پر اپڈیٹ کریں
          await box.put(hiveKey, updatedTx);
          
          // لسٹ سے صرف اسی ایک انٹری کو فوری نکالیں تاکہ پوری لسٹ دوبارہ لوڈ ہونے کا انتظار نہ کرنا پڑے
          _pendingTransactions.removeWhere((item) => item['hiveKey'] == hiveKey);
          notifyListeners(); // بیج اور لسٹ کو فورا ریفریش کریں
          
          // بیک گراؤنڈ میں ڈیٹا کو مکمل سنک بھی کر لیں
          await loadPendingTransactions();
          debugPrint("Transaction approved successfully!");
        }
      }
    } catch (e) {
      debugPrint("Error approving transaction: $e");
    }
  }

  // ❌ صرف اس مخصوص انٹری کو مسترد (Reject/Delete) کرنا جس پر کلک ہوا ہو
  Future<void> rejectTransaction(dynamic hiveKey) async {
    try {
      if (Hive.isBoxOpen('transactionBox')) {
        var box = Hive.box('transactionBox');
        
        // صرف اسی خاص کی (hiveKey) کو ڈیلیٹ کریں
        await box.delete(hiveKey);
        
        // لسٹ سے صرف اسی ایک انٹری کو فوری نکالیں
        _pendingTransactions.removeWhere((item) => item['hiveKey'] == hiveKey);
        notifyListeners(); // بیج اور لسٹ کو فورا ریفریش کریں

        // بیک گراؤنڈ میں ڈیٹا کو مکمل سنک بھی کر لیں
        await loadPendingTransactions();
        debugPrint("Transaction rejected/deleted successfully!");
      }
    } catch (e) {
      debugPrint("Error rejecting transaction: $e");
    }
  }
}