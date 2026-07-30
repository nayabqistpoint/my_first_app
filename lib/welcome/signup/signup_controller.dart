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

      // 2. کسٹمر کا شناختی کارڈ (CNIC) چیک کرنا کہ کہیں پہلے سے تو موجود نہیں
      String currentCnic = customerData['cnic'] ?? '';
      if (currentCnic.isNotEmpty) {
        bool cnicExists = customerBox.values.any((item) {
          if (item is Map) {
            return item['cnic'] == currentCnic;
          }
          return false;
        });

        if (cnicExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('یہ کسٹمر (شناختی کارڈ نمبر) پہلے سے رجسٹرڈ ہے!'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }

      // 3. لوڈنگ شروع (بٹن پر گول دائرہ گھمانے کے لیے)
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

      // 4. لوڈنگ ختم
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