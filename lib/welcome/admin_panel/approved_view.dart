import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'admin_panel_controller.dart';
import 'request_card_item.dart';

class ApprovedView extends StatelessWidget {
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const ApprovedView({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box?>(
      valueListenable: Hive.isBoxOpen('packageBox')
          ? Hive.box('packageBox').listenable()
          : ValueNotifier<Box?>(null),
      builder: (context, Box? box, _) {
        List<Map<String, dynamic>> approvedList = [];

        if (box != null && box.isOpen) {
          for (var item in box.values) {
            if (item is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(item);
              final String status = (data['status'] ?? '').toString().trim().toLowerCase();

              // 🎯 صرف 'approved' والے کارڈ دکھائیں (کیپٹل/اسمال دونوں ہینڈل ہیں)
              if (status == 'approved') {
                approvedList.add(data);
              }
            }
          }
        } else {
          // اگر ہائیو باکس اوپن نہ ہو تو کنٹرولر سے فلٹر کریں
          approvedList = controller.approvedRequests.where((item) {
            final String status = (item['status'] ?? '').toString().trim().toLowerCase();
            return status == 'approved';
          }).toList();
        }

        if (approvedList.isEmpty) {
          return const Center(
            child: Text(
              "کوئی منظور شدہ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: approvedList.length,
          itemBuilder: (context, index) {
            return RequestCardItem(
              requestData: approvedList[index],
              request: approvedList[index],
              controller: controller,
              isApprovedView: true,
              onStateChanged: onStateChanged,
            );
          },
        );
      },
    );
  }
}