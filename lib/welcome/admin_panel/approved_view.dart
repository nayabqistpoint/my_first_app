import 'package:flutter/material.dart';
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
    // براہ راست منظور شدہ ریکویسٹس کی لسٹ
    List<Map<String, dynamic>> approvedList = controller.approvedRequests;

    return approvedList.isEmpty
        ? const Center(
            child: Text(
              "کوئی منظور شدہ ریکویسٹ موجود نہیں ہے",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: approvedList.length,
            itemBuilder: (context, index) {
              return RequestCardItem(
                request: approvedList[index],
                controller: controller,
                onStateChanged: onStateChanged,
              );
            },
          );
  }
}