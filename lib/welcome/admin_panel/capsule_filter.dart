import 'package:flutter/material.dart';
import 'admin_panel_controller.dart';

class CapsuleFilterWidget extends StatelessWidget {
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const CapsuleFilterWidget({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🔗 یہاں بھی اب کنٹرولر سے ہی کاؤنٹ لیا جائے گا
    final int pendingCount = controller.pendingRequestsCount;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(child: Center(child: _buildCapsuleTab(0, 'منظور شدہ', 0))),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Center(child: _buildCapsuleTab(1, 'پینڈنگ ریکویسٹس', pendingCount)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Center(child: _buildCapsuleTab(2, 'مکمل شدہ', 0))),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildCapsuleTab(int index, String title, int count) {
    bool isSelected = controller.currentIndex == index;
    return GestureDetector(
      onTap: () {
        controller.currentIndex = index;
        controller.pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        onStateChanged();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935).withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE53935), 
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InPageSubFiltersWidget extends StatelessWidget {
  final String pageStatus;
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const InPageSubFiltersWidget({
    super.key,
    required this.pageStatus,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildSubFilterChip('all', 'تمام')),
          const SizedBox(width: 4),
          Expanded(child: _buildSubFilterChip('purchase', 'پرچیز')),
          const SizedBox(width: 4),
          Expanded(child: _buildSubFilterChip('signup', 'سائن اپ')),
          const SizedBox(width: 4),
          Expanded(child: _buildSubFilterChip('both', 'دونوں')),
          const SizedBox(width: 6),

          Container(
            height: 32,
            decoration: BoxDecoration(
              color: controller.selectedFilterDate != null 
                  ? const Color(0xFFE53935) 
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.filter_list, 
                size: 18, 
                color: controller.selectedFilterDate != null ? Colors.white : Colors.grey[800],
              ),
              onSelected: (value) async {
                if (value == 'newest') {
                  controller.toggleSortOrder(true);
                  onStateChanged(); 
                } else if (value == 'oldest') {
                  controller.toggleSortOrder(false);
                  onStateChanged(); 
                } else if (value == 'by_date') {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedFilterDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color(0xFFE53935),
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFE53935),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    controller.filterByDate(pickedDate);
                    onStateChanged();
                  }
                } else if (value == 'clear_date') {
                  controller.clearDateFilter();
                  onStateChanged();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'newest',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 16, color: controller.isNewestFirst ? const Color(0xFFE53935) : Colors.grey),
                      const SizedBox(width: 8),
                      const Text('نئی سے پرانی (Newest First)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'oldest',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: !controller.isNewestFirst ? const Color(0xFFE53935) : Colors.grey),
                      const SizedBox(width: 8),
                      const Text('پرانی سے نئی (Oldest First)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'by_date',
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('تاریخ کے حساب سے فلٹر کریں', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                if (controller.selectedFilterDate != null)
                  PopupMenuItem<String>(
                    value: 'clear_date',
                    child: Row(
                      children: [
                        const Icon(Icons.clear, size: 16, color: Color(0xFFE53935)),
                        const SizedBox(width: 8),
                        const Text('تاریخ کا فلٹر ہٹائیں', style: TextStyle(fontSize: 12, color: Color(0xFFE53935))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFilterChip(String filterKey, String label) {
    bool isSelected = controller.pageFilters[pageStatus] == filterKey;
    return GestureDetector(
      onTap: () {
        controller.pageFilters[pageStatus] = filterKey;
        onStateChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}