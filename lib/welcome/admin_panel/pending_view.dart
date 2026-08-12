import 'package:flutter/material.dart';
import 'admin_panel_controller.dart';
import 'request_card_item.dart';

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
    // براہِ راست صرف پینڈنگ ریکویسٹس کی لسٹ
    List<Map<String, dynamic>> pendingList = controller.requests.where((req) {
      return req['status'] == 'pending';
    }).toList();

    return pendingList.isEmpty
        ? const Center(
            child: Text(
              "کوئی پینڈنگ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: pendingList.length,
            itemBuilder: (context, index) {
              return RequestCardItem(
                request: pendingList[index],
                controller: controller,
                onStateChanged: onStateChanged,
              );
            },
          );
  }
}