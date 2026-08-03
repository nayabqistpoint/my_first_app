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

  // لوڈنگ اسٹیٹ کے لیے ویری ایبل
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
      // 1. چھوٹے وجٹس سے ڈیٹا نکالنا
      var customerData = customerKey.currentState?.getCustomerData() ?? {};
      var guarantorData = guarantorKey.currentState?.getGuarantorData() ?? {};
      var packageData = packageKey.currentState?.getPackageData() ?? {};

      // کسٹمر کا موبائل نمبر درست طریقے سے حاصل کرنا
      String phoneNumber = customerData['customerPhone'] ?? 
                           customerData['phone'] ?? 
                           customerData['mobile'] ?? 
                           customerData['phoneNumber'] ?? 
                           customerData['cell'] ?? '';

      // اگر موبائل نمبر خالی ہو تو یہیں روک دیں
      if (phoneNumber.isEmpty) {
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

      var customerBox = Hive.box('customerBox');

      // 2. لوڈنگ شروع (بٹن پر گول دائرہ گھمانے کے لیے)
      _isLoading = true;
      notifyListeners();

      // نمبر کو بالکل صاف کرنا (صرف ہندسے رکھنا) تاکہ یہ یونیک کی (Unique Key) بن سکے
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      try {
        // سختی سے صرف آخری 4 ہندسے بطور پاسورڈ نکالنا
        String password = cleanPhone.length >= 4 
            ? cleanPhone.substring(cleanPhone.length - 4) 
            : cleanPhone;

        // فائر بیس کے لیے فرضی ای میل بنانا
        String fakeEmail = '$cleanPhone@nayabqist.com';

        // فائر بیس اتھنٹیکیشن میں یوزر بنانا
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: fakeEmail,
          password: password,
        );
      } catch (e) {
        debugPrint('Firebase Registration Error: $e');
      }

      // ہلکا سا نقلی وقفہ
      await Future.delayed(const Duration(milliseconds: 800));

      Map<String, dynamic> requestData = {
        ...customerData,
        ...guarantorData,
        ...packageData,
        'customerPhone': cleanPhone, // موبائل نمبر کو پکا محفوظ کرنا
        'isTermsAccepted': _isTermsAccepted,
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      // **اہم ترین تبدیلی**: .add() کی بجائے .put(cleanPhone, ...) استعمال کیا ہے
      // تاکہ ہائیو باکس کے اندر کسٹمر کی اصل شناخت (Key) اس کا موبائل نمبر بن جائے!
      await customerBox.put(cleanPhone, requestData);

      // 3. لوڈنگ ختم
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رجسٹریشن کامیابی سے محفوظ ہو گئی ہے'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    }
    return false;
  }
}