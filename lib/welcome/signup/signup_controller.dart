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

  void updateTerms(bool accepted) {
    _isTermsAccepted = accepted;
    notifyListeners(); // UI کو خود بخود اپڈیٹ کرے گا بغیر مین پیج کے setState کے
  }

  Future<bool> submitRegistration(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پہلے شرائط کو پڑھ کر ٹک کریں')),
      );
      return false;
    }

    if (formKey.currentState!.validate()) {
      var customerData = customerKey.currentState?.getCustomerData() ?? {};
      var guarantorData = guarantorKey.currentState?.getGuarantorData() ?? {};
      var packageData = packageKey.currentState?.getPackageData() ?? {};

      var customerBox = Hive.box('customerBox');

      Map<String, dynamic> requestData = {
        ...customerData,
        ...guarantorData,
        ...packageData,
        'isTermsAccepted': _isTermsAccepted,
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      await customerBox.add(requestData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رجسٹریشن کامیابی سے محفوظ ہو گئی ہے')),
        );
      }
      return true;
    }
    return false;
  }
}