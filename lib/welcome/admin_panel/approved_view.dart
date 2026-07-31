import 'package:flutter/material.dart';
import 'admin_panel_controller.dart';
import 'capsule_filter.dart';
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
    // صرف 'approved' سٹیٹس والی ریکویسٹس کو فلٹر کریں
    String currentSubFilter = controller.pageFilters['approved'] ?? 'all';

    List<Map<String, dynamic>> filteredList = controller.requests.where((req) {
      if (req['status'] != 'approved') return false;
      if (currentSubFilter == 'all') return true;
      return req['filterKey'] == currentSubFilter;
    }).toList();

    return Column(
      children: [
        // ان-پیج سب-فلٹرز
        InPageSubFiltersWidget(
          pageStatus: 'approved',
          controller: controller,
          onStateChanged: onStateChanged,
        ),
        const Divider(height: 1, color: Colors.grey),

        // کارڈز کی لسٹ
        Expanded(
          child: filteredList.isEmpty
              ? const Center(
                  child: Text(
                    "کوئی منظور شدہ ریکویسٹ موجود نہیں ہے",
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