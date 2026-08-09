import 'package:flutter/material.dart';

class SectionsController extends ChangeNotifier {
  final PageController pageController = PageController();

  int currentPageIndex = 0;
  String selectedTopButton = ""; // "get", "give", "stock" یا ""
  
  // کسٹمر سارٹنگ اسٹیٹ: "NONE", "RED_FIRST", "GREEN_FIRST"
  String customerSortMode = "NONE";

  // کسٹمرز لسٹ سے آنے والا لائیو ٹوٹل
  double totalRedAmount = 0.0;
  double totalGreenAmount = 0.0;

  void updateTotals({required double redTotal, required double greenTotal}) {
    if (totalRedAmount != redTotal || totalGreenAmount != greenTotal) {
      totalRedAmount = redTotal;
      totalGreenAmount = greenTotal;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void changePage(int index) {
    currentPageIndex = index;
    _updateTopButtonState(index);

    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }

    notifyListeners();
  }

  void onPageSwiped(int index) {
    if (currentPageIndex != index) {
      currentPageIndex = index;
      _updateTopButtonState(index);
      notifyListeners();
    }
  }

  void _updateTopButtonState(int index) {
    if (index == 2) {
      selectedTopButton = "stock";
    } else if (index == 0) {
      if (selectedTopButton != "get" && selectedTopButton != "give") {
        selectedTopButton = "";
        customerSortMode = "NONE";
      }
    } else {
      selectedTopButton = "";
      customerSortMode = "NONE";
    }
  }

  void selectTopButton(String buttonId) {
    if (selectedTopButton == buttonId) {
      selectedTopButton = "";
      customerSortMode = "NONE";
      changePage(0);
    } else {
      selectedTopButton = buttonId;

      if (buttonId == "stock") {
        changePage(2);
      } else if (buttonId == "get") {
        customerSortMode = "RED_FIRST"; // پہلے Red، پھر Green، پھر 0
        changePage(0);
      } else if (buttonId == "give") {
        customerSortMode = "GREEN_FIRST"; // پہلے Green، پھر Red، پھر 0
        changePage(0);
      } else {
        notifyListeners();
      }
    }
  }
}

final sectionsController = SectionsController();