import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'customer_info.dart';
import 'guarantor_info.dart';
import 'item_package_ui.dart';

class SignUpController extends ChangeNotifier {
  final GlobalKey<CustomerInfoWidgetState> customerKey = GlobalKey<CustomerInfoWidgetState>();
  final GlobalKey<GuarantorInfoWidgetState> guarantorKey = GlobalKey<GuarantorInfoWidgetState>();
  final GlobalKey<ItemPackageUIState> packageKey = GlobalKey<ItemPackageUIState>();

  bool _isTermsAccepted = false;
  bool get isTermsAccepted => _isTermsAccepted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateTerms(bool accepted) {
    _isTermsAccepted = accepted;
    notifyListeners();
  }

  Future<bool> submitRegistration(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پہلے شرائط کو پڑھ کر ٹک کریں')),
      );
      return false;
    }

    if (formKey.currentState!.validate()) {
      // 1. تینوں وجٹس سے ڈیٹا حاصل کرنا
      final Map<String, dynamic> customerData = customerKey.currentState?.getCustomerData() ?? {};
      final Map<String, dynamic> guarantorData = guarantorKey.currentState?.getGuarantorData() ?? {};
      final Map<String, dynamic> packageData = packageKey.currentState?.getPackageData() ?? {};

      // کسٹمر کا موبائل نمبر درست طریقے سے حاصل کرنا
      String rawPhone = customerData['customerPhone'] ?? '';

      if (rawPhone.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('براہ کرم کسٹمر کا موبائل نمبر درج کریں'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // موبائل نمبر سے صرف ہندسے نکالنا
      String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

      _isLoading = true;
      notifyListeners();

      try {
        // فائر بیس اتھنٹیکیشن
        String password = cleanPhone.length >= 4 
            ? cleanPhone.substring(cleanPhone.length - 4) 
            : cleanPhone;
        String fakeEmail = '$cleanPhone@nayabqist.com';

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: fakeEmail,
          password: password,
        );
      } catch (e) {
        debugPrint('Firebase Registration Error: $e');
      }

      final String currentTimestamp = DateTime.now().toString();

      // -------------------------------------------------------------
      // 2. ہائیو باکسز میں لنکیج اور سیونگ لاجک
      // -------------------------------------------------------------

      // (الف) کسٹمر باکس (customerBox)
      final Box customerBox = Hive.box('customerBox');
      final Map<String, dynamic> finalCustomerMap = {
        ...customerData,
        'customerPhone': cleanPhone,
        'isTermsAccepted': _isTermsAccepted,
        'status': 'Pending',
        'timestamp': currentTimestamp,
      };
      await customerBox.put(cleanPhone, finalCustomerMap);

      // (ب) ضامن باکس (guarantorBox)
      final Box guarantorBox = Hive.box('guarantorBox');
      if (guarantorData['isGuarantorPresent'] == true) {
        final Map<String, dynamic> finalGuarantorMap = {
          'customerPhone': cleanPhone,
          ...guarantorData,
          'timestamp': currentTimestamp,
        };
        await guarantorBox.put(cleanPhone, finalGuarantorMap);
      } else {
        await guarantorBox.delete(cleanPhone);
      }

      // (ج) پیکج باکس (packageBox)
      final Box packageBox = Hive.box('packageBox');
      if (packageData['isPurchaseRequested'] == true) {

        // 🎯 [طے شدہ قانون]: پچھلا سٹیٹس چیک کرنا (1 Customer = 1 Active Device)
        if (packageBox.containsKey(cleanPhone)) {
          final existingRecord = packageBox.get(cleanPhone);
          if (existingRecord is Map) {
            String existingStatus = (existingRecord['status'] ?? 'Pending').toString().trim().toLowerCase();

            // 🛑 1. اگر ڈیوائس کا ہینڈ اوور مکمل (Completed) ہو چکا ہے تو روک دیں
            if (existingStatus == 'completed') {
              _isLoading = false;
              notifyListeners();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('محترم صارف! اس موبائل نمبر پر آپ کا ایک فعال قسطوں کا اکاؤنٹ پہلے سے موجود ہے۔ براہ کرم دوسرا موبائل نمبر استعمال کریں!'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              return false;
            }
          }
        }

        // 🔄 2. اگر Pending یا Approved موڈ میں ہے تو پرانی اینٹری اوور رائٹ ہو کر نیا 'Pending' بن جائے گی
        final Map<String, dynamic> finalPackageMap = {
          'customerPhone': cleanPhone,
          ...packageData,
          'status': 'Pending',
          'timestamp': currentTimestamp,
        };
        await packageBox.put(cleanPhone, finalPackageMap);
      } else {
        await packageBox.delete(cleanPhone);
      }

      await Future.delayed(const Duration(milliseconds: 300));

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمام معلومات متعلقہ باکسز میں کامیابی سے محفوظ ہو گئی ہیں'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    }
    return false;
  }
}