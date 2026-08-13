import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'admin_panel_controller.dart';
import 'request_card_item.dart';

class CompletedView extends StatelessWidget {
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const CompletedView({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 packageBox کو لائیو لسن کریں اور صرف 'completed' سٹیٹس والے کارڈز ڈسپلے کریں
    return ValueListenableBuilder<Box?>(
      valueListenable: Hive.isBoxOpen('packageBox')
          ? Hive.box('packageBox').listenable()
          : ValueNotifier<Box?>(null),
      builder: (context, Box? box, _) {
        List<Map<String, dynamic>> completedList = [];

        if (box != null && box.isOpen) {
          for (var item in box.values) {
            if (item is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(item);
              final String status = (data['status'] ?? '').toString().trim().toLowerCase();

              // 🎯 صرف وہی کارڈز دکھائیں جن کا سٹیٹس completed ہو چکا ہے
              if (status == 'completed') {
                completedList.add(data);
              }
            }
          }
        } else {
          // اگر ہائیو ابھی اوپن نہیں ہے تو بیک اپ کے طور پر کنٹرولر سے فلٹر کریں
          completedList = controller.completedRequests.where((item) {
            final String status = (item['status'] ?? '').toString().trim().toLowerCase();
            return status == 'completed';
          }).toList();
        }

        if (completedList.isEmpty) {
          return const Center(
            child: Text(
              "کوئی مکمل شدہ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: completedList.length,
          itemBuilder: (context, index) {
            return RequestCardItem(
              requestData: completedList[index],
              request: completedList[index],
              controller: controller,
              isApprovedView: false,
              isCompletedView: true, // 🎯 مکمل (Read-Only) ویو
              onStateChanged: onStateChanged,
            );
          },
        );
      },
    );
  }
}