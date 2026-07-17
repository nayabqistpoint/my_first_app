import 'package:flutter/material.dart';

class SearchAndFilterSection extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter; // 'آل'، 'آئٹم'، 'سپلائر'
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const SearchAndFilterSection({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController(text: searchQuery);
    // کرسر کو ٹیکسٹ کے بالکل آخر میں رکھنے کے لیے
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ۱۔ سرچ بار (Search Bar)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'موبائل ماڈل، سپلائر یا IMEI سرچ کریں...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),

        // ۲۔ فلٹر چپس (Filter Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('آل', 'سب اسٹاک'),
              const SizedBox(width: 8),
              _buildFilterChip('آئٹم', 'آئٹم وائز'),
              const SizedBox(width: 8),
              _buildFilterChip('سپلائر', 'سپلائر وائز'),
            ],
          ),
        ),
      ],
    );
  }

  // چپس بنانے کا ایک خوبصورت اور مختصر فنکشن
  Widget _buildFilterChip(String filterKey, String label) {
    final bool isSelected = selectedFilter == filterKey;

    return GestureDetector(
      onTap: () => onFilterChanged(filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}