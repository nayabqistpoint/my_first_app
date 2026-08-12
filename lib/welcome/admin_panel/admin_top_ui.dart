import 'package:flutter/material.dart';

class AdminTopUI extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final int pendingCount;
  final VoidCallback? onMenuPressed;

  const AdminTopUI({
    super.key,
    this.selectedIndex = 1,
    required this.onTabSelected,
    this.pendingCount = 0,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFE53935);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🎯 1. ایپ بار
          Container(
            color: Colors.red.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                        onPressed: onMenuPressed ?? () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "ایڈمن پینل",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Text('$pendingCount', style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const Text("نایاب قسط پوائنٹ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),

          // 🎯 2. تینوں کیپسولز (سب کی موٹائی 100% ایک برابر 36px)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 1. منظور شدہ (سائیڈ - چھوٹا)
                Expanded(
                  flex: 3,
                  child: _buildCapsule("منظور شدہ", 0, themeColor),
                ),
                const SizedBox(width: 6),
                // 2. پینڈنگ (درمیان - لمبا لیکن موٹائی برابری)
                Expanded(
                  flex: 4,
                  child: _buildCapsule("پینڈنگ", 1, themeColor),
                ),
                const SizedBox(width: 6),
                // 3. مکمل (سائیڈ - چھوٹا)
                Expanded(
                  flex: 3,
                  child: _buildCapsule("مکمل", 2, themeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 کیپسول وزٹ (تمام کے لیے ایک ہی یکساں موٹائی)
  Widget _buildCapsule(String title, int index, Color themeColor) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        height: 36, // 👈 تینوں کیپسولز کی اوپر نیچے کی موٹائی بالکل برابر فکس ہے
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: themeColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(105);
}