import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/imei_details_dialog.dart';
import '../../../features/installment_plan_dialog.dart';

class RequestCardHelper {
  /// 🎯 1. کسٹمر ہیڈر (نام، ولدیت، قوم) - customerBox سے ڈائریکٹ میپنگ
  static Widget buildCustomerHeaderWidget({required Map<String, dynamic> data, required String phone}) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('customerBox').listenable(),
      builder: (context, box, _) {
        final cust = box.values.firstWhere(
          (e) => e is Map && (e['customerPhone']?.toString().trim() == phone.trim() || e['phone']?.toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final String name = (cust['customerName'] ?? cust['name'] ?? data['name'] ?? 'نام موجود نہیں').toString().trim();
        final String father = (cust['customerFatherName'] ?? cust['fatherName'] ?? data['fatherName'] ?? '').toString().trim();
        final String caste = (cust['customerCaste'] ?? cust['caste'] ?? data['caste'] ?? '').toString().trim();

        String extraDetails = "";
        if (father.isNotEmpty || caste.isNotEmpty) {
          final fText = father.isNotEmpty ? "ولد: $father" : "";
          final cText = caste.isNotEmpty ? "قوم: $caste" : "";
          
          if (fText.isNotEmpty && cText.isNotEmpty) {
            extraDetails = " ($fText - $cText)";
          } else if (fText.isNotEmpty) {
            extraDetails = " ($fText)";
          } else if (cText.isNotEmpty) {
            extraDetails = " ($cText)";
          }
        }

        return Text(
          "$name$extraDetails",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// 🎯 2. کیپسول وزٹ (صرف سائن اپ / سائن اپ + پرچیز) - packageBox سے لسنر
  static Widget buildTypeCapsuleWidget({required Map<String, dynamic> data, required String phone}) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final hasPackageRequest = box.values.any((e) {
          if (e is Map) {
            final custPhone = (e['customerPhone'] ?? e['phone'] ?? '').toString().trim();
            final isReq = e['isPurchaseRequested'] == true;
            return custPhone.isNotEmpty && custPhone == phone.trim() && isReq;
          }
          return false;
        });

        final String typeText = hasPackageRequest ? 'سائن اپ + پرچیز' : 'صرف سائن اپ';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade700, width: 1.2),
          ),
          child: Text(
            typeText,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// 🎯 3. قسطوں کا پلان (موبائل ماڈل + قیمت) - packageBox سے میپنگ
  static Widget buildPackageWidget(BuildContext context, Map<String, dynamic> data, String phone) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && (e['customerPhone']?.toString().trim() == phone.trim() || e['phone']?.toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final model = (pkg['mobileName'] ?? pkg['mobileModel'] ?? 'موبائل ماڈل').toString();
        final price = (pkg['totalPrice'] ?? pkg['estimatedPrice'] ?? '0').toString();

        return InkWell(
          onTap: () => showInstallmentPlanDialog(context, phone),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 15, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                "$model ($price)",
                style: const TextStyle(color: Colors.orange, fontSize: 12.5, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 4. IMEI نمبر - packageBox سے میپنگ
  static Widget buildImeiWidget(BuildContext context, Map<String, dynamic> data, String phone) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && (e['customerPhone']?.toString().trim() == phone.trim() || e['phone']?.toString().trim() == phone.trim()),
          orElse: () => data,
        );

        final rawImei = pkg['imei']?.toString().trim();
        final imei = (rawImei != null && rawImei.isNotEmpty && rawImei != 'null') ? rawImei : 'N/A';

        return InkWell(
          onTap: () => showImeiDetailsDialog(context, imei),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, size: 15, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                "IMEI: $imei",
                style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 5. مشترکہ رو (Row)
  static Widget buildPackageAndImeiRow({required BuildContext context, required Map<String, dynamic> data, required String phone}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildPackageWidget(context, data, phone),
        buildImeiWidget(context, data, phone),
      ],
    );
  }
}