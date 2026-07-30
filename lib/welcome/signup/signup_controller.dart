import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

      var customerBox = Hive.box('customerBox');

      // نوٹ: شناختی کارڈ (CNIC) کی ڈুপ্লিکیٹ ریسٹرکشن کو فی الحال ہولڈ/ختم کر دیا گیا ہے 
      // تاکہ ایک کسٹمر ایک سے زیادہ ڈیوائسز یا اقساط کے لیے آسانی سے سائن اپ کر سکے۔

      // 2. لوڈنگ شروع (بٹن پر گول دائرہ گھمانے کے لیے)
      _isLoading = true;
      notifyListeners();

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