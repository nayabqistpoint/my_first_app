import 'package:flutter/material.dart';
import 'sections_controller.dart';

class MiddleSection extends StatelessWidget {
  const MiddleSection({super.key});

  static const List<String> _tabs = ["پارٹیز", "ٹرانزیکشن", "اسٹاک"];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sectionsController,
      builder: (context, _) {
        final selectedIndex = sectionsController.currentPageIndex;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => sectionsController.changePage(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple.shade400 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple.shade500 : Colors.black54,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}