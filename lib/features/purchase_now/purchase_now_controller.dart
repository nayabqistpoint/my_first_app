import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:developer' as developer;
import '../../welcome/signup/item_package_ui.dart';

class PurchaseNowController {
  // پیکج یو آئی کی گلوبل کی (Key)
  final GlobalKey<ItemPackageUIState> packageKey = GlobalKey<ItemPackageUIState>();

  /// پرچیز ریکوئسٹ سبمٹ کرنے کا فائنل طریقہ
  Future<void> submitPurchaseRequest({
    required String customerMobileNumber,
    Map<String, dynamic>? packageDetails,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // 1. نمبر میں سے صرف ہندسے نکالنا
      String cleanPhone = customerMobileNumber.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.isEmpty) {
        onError("خامی: کسٹمر کا موبائل نمبر غائب ہے!");
        return;
      }

      // 2. پیکج کا اصل ڈیٹا حاصل کرنا
      Map<String, dynamic> packageData = {};

      if (packageDetails != null && packageDetails.isNotEmpty) {
        packageData = Map<String, dynamic>.from(packageDetails);
      } else if (packageKey.currentState != null) {
        final state = packageKey.currentState!;
        state.setPurchaseRequested(true);
        
        final extractedData = state.getPackageData();
        if (extractedData.isNotEmpty) {
          packageData = Map<String, dynamic>.from(extractedData);
        }
      }

      if (packageData.isEmpty || packageData['isPurchaseRequested'] != true) {
        onError("براہ کرم پہلے قسط کیلکولیٹر سے پیکج کا انتخاب کریں!");
        return;
      }

      // 3. packageBox کو کھولنا
      Box packageBox;
      if (Hive.isBoxOpen('packageBox')) {
        packageBox = Hive.box('packageBox');
      } else {
        packageBox = await Hive.openBox('packageBox');
      }

      final String currentTimestamp = DateTime.now().toString();

      // 4. 🎯 [طے شدہ قانون] پچھلا اسٹیٹس چیک کرنے کی لاجک (1 Customer = 1 Active Device)
      if (packageBox.containsKey(cleanPhone)) {
        final existingRecord = packageBox.get(cleanPhone);
        
        if (existingRecord is Map) {
          String existingStatus = (existingRecord['status'] ?? 'Pending').toString().trim().toLowerCase();

          // 🛑 A. اگر اسٹیٹس Completed ہو چکا ہے تو نئی ریکویسٹ کو روک دیں
          if (existingStatus == 'completed') {
            onError("محترم صارف! اس موبائل نمبر پر آپ کا ایک فعال قسطوں کا اکاؤنٹ پہلے سے موجود ہے۔ براہ کرم دوسرا موبائل نمبر استعمال کریں!");
            return;
          }
          
          // 🔄 B. اگر Pending یا Approved ہے، تو وہ نیچے خود بخود اوور رائٹ ہو کر 'Pending' بن جائے گا۔
        }
      }

      // 5. بالکل صاف ستھرا پے لوڈ
      final Map<String, dynamic> finalPackageMap = {
        'customerPhone': cleanPhone, // کسٹمر سے جوڑنے والی کڑی
        ...packageData,
        'status': 'Pending', // 👈 نئی یا اوور رائٹ درخواست ہمیشہ پینڈنگ ہوگی
        'timestamp': currentTimestamp,
      };

      // 6. 🎯 فون نمبر کی Key پر ڈائریکٹ اوور رائٹ کریں (کوئی اضافی archiveKey نہیں بنے گی)
      await packageBox.put(cleanPhone, finalPackageMap);

      developer.log('Success: Saved clean request to packageBox under Key: $cleanPhone', name: 'PurchaseNowController');
      
      onSuccess();
    } catch (e) {
      developer.log('Error submitting purchase request', error: e, name: 'PurchaseNowController');
      onError("خرابی پیش آئی: ${e.toString()}");
    }
  }
}