import 'package:flutter/material.dart';
import 'sections_controller.dart';

class MiddleSection extends StatelessWidget {
  const MiddleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sectionsController,
      builder: (context, child) {
        int selectedIndex = sectionsController.currentPageIndex;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. پارٹیز (انڈیکس 0)
              _buildButton(0, "پارٹیز", isSideButton: true, selectedIndex: selectedIndex),
              
              const SizedBox(width: 5),
              
              // 2. ٹرانزیکشن (انڈیکس 1)
              _buildButton(1, "ٹرانزیکشن", isSideButton: false, selectedIndex: selectedIndex),
              
              const SizedBox(width: 5), 
              
              // 3. اسٹاک (انڈیکس 2)
              _buildButton(2, "اسٹاک", isSideButton: true, selectedIndex: selectedIndex),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(int index, String title, {required bool isSideButton, required int selectedIndex}) {
    bool isSelected = (selectedIndex == index);
    
    return GestureDetector(
      onTap: () {
        sectionsController.changePage(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSideButton ? 28 : 50,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.deepPurple.shade500 : Colors.black87,
            width: isSelected ? 1 : 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}