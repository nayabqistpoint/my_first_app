import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/welcome/admin_panel/admin_panel_controller.dart';
import 'package:my_first_app/welcome/admin_panel/request_card_item.dart';

class PendingView extends StatelessWidget {
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const PendingView({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 packageBox کو لائیو لسن کریں تاکہ نئی/اوور رائٹ شدہ پینڈنگ درخواست فوراً ظاہر ہو
    return ValueListenableBuilder<Box?>(
      valueListenable: Hive.isBoxOpen('packageBox')
          ? Hive.box('packageBox').listenable()
          : ValueNotifier<Box?>(null),
      builder: (context, Box? box, _) {
        List<Map<String, dynamic>> pendingList = [];

        if (box != null && box.isOpen) {
          for (var item in box.values) {
            if (item is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(item);
              final String status = (data['status'] ?? 'Pending').toString().trim().toLowerCase();

              // 🎯 صرف وہی اینٹریز اٹھائیں جو 'pending' ہیں (کیپٹل/اسمال دونوں ہینڈل ہیں)
              if (status == 'pending') {
                pendingList.add(data);
              }
            }
          }
        } else {
          // بیک اپ کے طور پر کنٹرولر سے فلٹر کریں
          pendingList = controller.requests.where((req) {
            final String status = (req['status'] ?? 'pending').toString().trim().toLowerCase();
            return status == 'pending';
          }).toList();
        }

        if (pendingList.isEmpty) {
          return const Center(
            child: Text(
              "کوئی پینڈنگ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            return RequestCardItem(
              requestData: pendingList[index],
              request: pendingList[index],
              controller: controller,
              isApprovedView: false,
              isCompletedView: false,
              onStateChanged: onStateChanged,
            );
          },
        );
      },
    );
  }
}