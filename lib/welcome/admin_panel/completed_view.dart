import 'package:flutter/material.dart';
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
    // براہِ راست مکمل شدہ ریکویسٹس کی لسٹ
    List<Map<String, dynamic>> completedList = controller.completedRequests;

    return completedList.isEmpty
        ? const Center(
            child: Text(
              "کوئی مکمل شدہ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: completedList.length,
            itemBuilder: (context, index) {
              return RequestCardItem(
                request: completedList[index],
                controller: controller,
                onStateChanged: onStateChanged,
              );
            },
          );
  }
}