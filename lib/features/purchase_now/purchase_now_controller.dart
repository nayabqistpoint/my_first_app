import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:developer' as developer;
import '../../welcome/signup/item_package_ui.dart';

class PurchaseNowController {
  // پیکج یو آئی کی گلوبل کی (Key) جو ویجیٹ سے ڈیٹا اٹھانے کے لیے ہے
  final GlobalKey<ItemPackageUIState> packageKey = GlobalKey<ItemPackageUIState>();

  /// پرچیز ریکوئسٹ سبمٹ کرنے کا فائنل اور پرفیکٹ طریقہ
  Future<void> submitPurchaseRequest({
    required String customerMobileNumber, // کسٹمر کی اصل شناخت (موبائل نمبر/ID) جو سب کچھ جوڑتی ہے
    Map<String, dynamic>? packageDetails,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      if (customerMobileNumber.trim().isEmpty) {
        onError("خامی: کسٹمر کا موبائل نمبر غائب ہے!");
        return;
      }

      // پیکج کا اصل ڈیٹا حاصل کرنا
      var finalPackageData = packageDetails ?? packageKey.currentState?.getPackageData() ?? {};

      if (finalPackageData.isEmpty || finalPackageData['packageName'] == 'N/A' || finalPackageData['packageName'] == null) {
        onError("براہ کرم پہلے پیکج کی تفصیلات مکمل منتخب کریں!");
        return;
      }

      var customerBox = Hive.isBoxOpen('customerBox') 
          ? Hive.box('customerBox') 
          : await Hive.openBox('customerBox');

      // چیک کرنا کہ آیا یہ کسٹمر ہائیو باکس میں پہلے سے موجود ہے یا نہیں
      if (customerBox.containsKey(customerMobileNumber)) {
        // پرانا تمام ڈیٹا (نام، ایڈریس، ضامن وغیرہ) نکالنا تاکہ کوئی چیز ضائع نہ ہو
        var existingData = Map<String, dynamic>.from(customerBox.get(customerMobileNumber));

        // یہاں ہم نے بالکل درست طور پر 'purchase' کر دیا ہے تاکہ ایڈمن پینل کا چپ اسے فوراً اٹھا لے
        existingData['requestType'] = 'پرچیز';
        existingData['filterKey'] = 'purchase'; 
        existingData['purchaseStatus'] = 'pending';
        existingData['isPurchaseRequested'] = true;
        existingData['status'] = 'Pending';
        
        // پیکج کا نیا تمام ڈیٹا کسٹمر کے پرانے ریکارڈ میں بالکل درست طریقے سے مرج کرنا 
        existingData.addAll(finalPackageData); 
        existingData['purchaseDate'] = DateTime.now().toIso8601String();

        // اسی کسٹمر کے موبائل نمبر (ID) پر مکمل اپ ڈیٹ شدہ ڈیٹا واپس محفوظ کرنا
        await customerBox.put(customerMobileNumber, existingData);
        
        onSuccess();
      } else {
        developer.log('Customer mobile number not found in box: $customerMobileNumber', name: 'PurchaseNowController');
        onError("مطلوبہ کسٹمر سسٹم میں رجسٹرڈ نہیں ہے!");
      }
    } catch (e) {
      developer.log('Error submitting purchase request', error: e, name: 'PurchaseNowController');
      onError("خرابی پیش آئی: ${e.toString()}");
    }
  }
}