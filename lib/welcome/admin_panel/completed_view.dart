import 'package:flutter/material.dart';
import 'admin_panel_controller.dart';
import 'capsule_filter.dart';
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
    // صرف 'completed' سٹیٹس والی ریکویسٹس کو فلٹر کریں (requests کی جگہ completedRequests کر دیا ہے)
    String currentSubFilter = controller.pageFilters['completed'] ?? 'all';

    List<Map<String, dynamic>> filteredList = controller.completedRequests.where((req) {
      if (currentSubFilter == 'all') return true;
      return req['filterKey'] == currentSubFilter;
    }).toList();

    return Column(
      children: [
        // ان-پیج سب-فلٹرز
        InPageSubFiltersWidget(
          pageStatus: 'completed',
          controller: controller,
          onStateChanged: onStateChanged,
        ),
        const Divider(height: 1, color: Colors.grey),

        // کارڈز کی لسٹ
        Expanded(
          child: filteredList.isEmpty
              ? const Center(
                  child: Text(
                    "کوئی مکمل شدہ ریکویسٹ موجود نہیں ہے",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return RequestCardItem(
                      request: filteredList[index],
                      controller: controller,
                      onStateChanged: onStateChanged,
                    );
                  },
                ),
        ),
      ],
    );
  }
}