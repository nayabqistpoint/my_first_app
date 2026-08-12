import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/imei_details_dialog.dart';
import '../../../features/installment_plan_dialog.dart';

class RequestCardHelper {
  // 🎯 1. کسٹمر ہیڈر (نام، ولدیت، قوم)
  static Widget buildCustomerHeaderWidget({required Map<String, dynamic> data, required String phone}) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('customerBox').listenable(),
      builder: (context, box, _) {
        final cust = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final name = (cust['customerName'] ?? cust['name'] ?? data['name'] ?? 'نام موجود نہیں').toString().trim();
        final father = (cust['customerFatherName'] ?? cust['fatherName'] ?? data['fatherName'] ?? '').toString().trim();
        final caste = (cust['customerCaste'] ?? cust['caste'] ?? data['caste'] ?? '').toString().trim();

        List<String> extra = [];
        if (father.isNotEmpty) extra.add("ولد: $father");
        if (caste.isNotEmpty) extra.add("قوم: $caste");

        return Text(
          "$name${extra.isNotEmpty ? ' (${extra.join(' - ')})' : ''}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  // 🎯 2. ڈائنامک کیپسول (صرف سائن اپ / سائن اپ + پرچیز)
  static Widget buildTypeCapsuleWidget({required Map<String, dynamic> data, required String phone}) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final isPurchase = box.values.any((e) =>
            e is Map &&
            (e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone.trim() &&
            e['isPurchaseRequested'] == true);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade700, width: 1.2),
          ),
          child: Text(
            isPurchase ? 'سائن اپ + پرچیز' : 'صرف سائن اپ',
            style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // 🎯 3. موبائل ماڈل (فیروزی کلر)
  static Widget buildPackageWidget(BuildContext context, Map<String, dynamic> data, String phone) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final model = (pkg['mobileName'] ?? pkg['mobileModel'] ?? 'موبائل ماڈل').toString();

        return InkWell(
          onTap: () => showInstallmentPlanDialog(context, phone),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_android, size: 18, color: Colors.teal.shade800),
              const SizedBox(width: 4),
              Text(
                model,
                style: TextStyle(color: Colors.teal.shade800, fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎯 4. سینٹرڈ ایڈیٹیبل پرائس باکس (بڑا فونٹ)
  static Widget buildEditablePriceBox(BuildContext context, Map<String, dynamic> data, String phone, TextEditingController? priceController) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final currentPrice = (pkg['totalPrice'] ?? pkg['estimatedPrice'] ?? '0').toString();
        if (priceController != null && priceController.text.isEmpty) {
          priceController.text = currentPrice;
        }

        return Container(
          height: 36,
          width: 95,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red.shade500, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
          ),
          child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(color: Colors.red.shade800, fontSize: 15, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
          ),
        );
      },
    );
  }

  // 🎯 5. IMEI نمبر
  static Widget buildImeiWidget(BuildContext context, Map<String, dynamic> data, String phone) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final rawImei = pkg['imei']?.toString().trim();
        final imei = (rawImei != null && rawImei.isNotEmpty && rawImei != 'null') ? rawImei : 'N/A';

        return InkWell(
          onTap: () => showImeiDetailsDialog(context, imei),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, size: 18, color: Colors.blue),
              const SizedBox(width: 4),
              Text("IMEI: $imei", style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            ],
          ),
        );
      },
    );
  }

  // 🎯 6. تینوں اجزاء کی متوازن رو (Row)
  static Widget buildPackageAndImeiRow({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String phone,
    TextEditingController? priceController,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildPackageWidget(context, data, phone),
        buildEditablePriceBox(context, data, phone, priceController),
        buildImeiWidget(context, data, phone),
      ],
    );
  }
}