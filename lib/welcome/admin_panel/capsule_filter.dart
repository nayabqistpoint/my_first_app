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
    return Column(
      children: [
        // اوپر والے تینوں فکسڈ کیپسول ٹیبز
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(child: Center(child: _buildCapsuleTab(0, 'منظور شدہ'))),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Center(child: _buildCapsuleTab(1, 'پینڈنگ ریکویسٹس')),
              ),
              const SizedBox(width: 8),
              Expanded(child: Center(child: _buildCapsuleTab(2, 'مکمل شدہ'))),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildCapsuleTab(int index, String title) {
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
    );
  }
}

// ہر پیج کے اندر نظر آنے والا سب-فلٹر بار
class InPageSubFiltersWidget extends StatelessWidget {
  final String pageStatus; // 'approved', 'pending', 'completed'
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
          const SizedBox(width: 6),
          Expanded(child: _buildSubFilterChip('purchase', 'صرف پرچیز')),
          const SizedBox(width: 6),
          Expanded(child: _buildSubFilterChip('signup', 'صرف سائن اپ')),
          const SizedBox(width: 6),
          Expanded(child: _buildSubFilterChip('both', 'دونوں مکس')),
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
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