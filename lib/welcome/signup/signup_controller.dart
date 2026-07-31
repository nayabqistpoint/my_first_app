import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // فائر بیس اتھنٹیکیشن کا پیکیج

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

      // کسٹمر کا موبائل نمبر حاصل کرنا (یقینی بنائیں کہ آپ کے customerData میں موبائل نمبر کی کلید 'phone' یا 'mobile' ہے)
      // یہاں ہم فرض کرتے ہیں کہ کلید 'phone' یا 'mobileNumber' نام سے ہے۔ اپنے فارم کے مطابق اسے تبدیل کر سکتے ہیں۔
      String phoneNumber = customerData['phone'] ?? customerData['mobile'] ?? '';

      var customerBox = Hive.box('customerBox');

      // 2. لوڈنگ شروع (بٹن پر گول دائرہ گھمانے کے لیے)
      _isLoading = true;
      notifyListeners();

      try {
        // اگر موبائل نمبر موجود ہے تو فائر بیس پر بھی اکاؤنٹ رجسٹر کریں
        if (phoneNumber.isNotEmpty) {
          // نمبر کو صاف کرنا (اگر سپیس یا ڈیش ہوں تو ہٹا دیں)
          String cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
          
          // آخری 4 ہندے بطور پاسورڈ نکالنا (اگر نمبر 4 ہندسوں سے چھوٹا ہو تو پورا نمبر لے لیں)
          String password = cleanPhone.length >= 4 
              ? cleanPhone.substring(cleanPhone.length - 4) 
              : cleanPhone;

          // فائر بیس کے لیے فرضی ای میل بنانا (موبائل نمبر @nayabqist.com)
          String fakeEmail = '$cleanPhone@nayabqist.com';

          // فائر بیس اتھنٹیکیشن میں یوزر بنانا
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: fakeEmail,
            password: password,
          );
        }
      } catch (e) {
        // اگر فائر بیس پر پہلے سے اکاؤنٹ موجود ہو یا کوئی اور مسئلہ ہو تو ایپ کریش نہ ہو، بس پرنٹ ہو جائے
        debugPrint('Firebase Registration Error: $e');
      }

      // ہلکا سا نقلی وقفہ تاکہ لوڈنگ فیل ہو سکے
      await Future.delayed(const Duration(milliseconds: 800));

      Map<String, dynamic> requestData = {
        ...customerData,
        ...guarantorData,
        ...packageData,
        'isTermsAccepted': _isTermsAccepted,
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      await customerBox.add(requestData);

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