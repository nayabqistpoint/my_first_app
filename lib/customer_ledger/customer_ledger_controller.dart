import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/installment_calculater_page.dart';

class CustomerLedgerController extends ChangeNotifier {
  final dynamic customer;
  final Map<String, dynamic> customerData;
  final String? directName;
  final String? directCast;
  final bool isAdmin;

  CustomerLedgerController({
    this.customer,
    this.customerData = const {},
    this.directName,
    this.directCast,
    this.isAdmin = true,
  });

  /// 🎯 کسٹمر کا موبائل نمبر (یونیک آئی ڈی - تمام غیر ضروری علامات صاف کر کے)
  String get customerPhone {
    String phone = '';
    if (customer != null) {
      try {
        phone = (customer.phone ?? (customer is Map ? customer['customerPhone'] : '')).toString();
      } catch (_) {}
    }
    if (phone.isEmpty && customerData.isNotEmpty) {
      phone = (customerData['customerPhone'] ?? customerData['phone'] ?? customerData['mobile'] ?? customerData['phoneNumber'] ?? '').toString();
    }
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String get customerId => customerPhone;

  /// 🎯 customerBox یا پاس شدہ ڈیٹا سے نام نکالنا
  String get customerName {
    if (directName != null && directName!.trim().isNotEmpty) return directName!;

    final map = _getCustomerFromBox();
    if (map != null) {
      final name = (map['name'] ?? map['customerName'] ?? map['fullName'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    }

    if (customerData.isNotEmpty) {
      final n = (customerData['customerName'] ?? customerData['name'] ?? customerData['fullName'] ?? '').toString().trim();
      if (n.isNotEmpty) return n;
    }

    if (customer != null && customer is Map) {
      return (customer['customerName'] ?? customer['name'] ?? '').toString().trim();
    }

    return '';
  }

  /// 🎯 customerBox یا پاس شدہ ڈیٹا سے قوم / ذات نکالنا
  String get customerCast {
    if (directCast != null && directCast!.trim().isNotEmpty) return directCast!;

    final map = _getCustomerFromBox();
    if (map != null) {
      final cast = (map['cast'] ?? map['caste'] ?? map['customerCaste'] ?? '').toString().trim();
      if (cast.isNotEmpty) return cast;
    }

    if (customerData.isNotEmpty) {
      final c = (customerData['customerCaste'] ?? customerData['cast'] ?? customerData['caste'] ?? '').toString().trim();
      if (c.isNotEmpty) return c;
    }

    return '';
  }

  /// 🔒 customerBox سے فون نمبر میچ کر کے ریکارڈر لانے کا مشترکہ ہیلپر (ڈپلیکیشن سے پاک)
  Map<String, dynamic>? _getCustomerFromBox() {
    final phone = customerPhone;
    if (phone.isEmpty || !Hive.isBoxOpen('customerBox')) return null;

    final box = Hive.box('customerBox');
    for (final val in box.values.whereType<Map>()) {
      final p = (val['phone'] ?? val['mobile'] ?? val['customerPhone'] ?? val['customerId'] ?? '')
          .toString()
          .replaceAll(RegExp(r'[^0-9]'), '');
      if (p == phone) return Map<String, dynamic>.from(val);
    }
    return null;
  }

  void loadCustomerTransactions() => notifyListeners();

  void openInstallmentCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InstallmentCalculaterPage()),
    );
  }
}