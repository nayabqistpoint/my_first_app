import 'package:flutter/material.dart';

class SectionsController extends ChangeNotifier {
  final PageController pageController = PageController();

  // 0 = Parties / Customers (مرکزی پیج)
  // 1 = Transactions
  // 2 = Stock
  int currentPageIndex = 0;
  String selectedTopButton = "";

  void changePage(int index) {
    currentPageIndex = index;
    _updateTopButtonState(index);

    if (pageController.hasClients) {
      // jumpToPage استعمال کیا ہے تاکہ بغیر کسی اینیمیشن یا لگ کے پیج فوراً 1 ملی سیکنڈ میں کھلے
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
      }
    } else {
      selectedTopButton = "";
    }
  }

  void selectTopButton(String buttonId) {
    if (selectedTopButton == buttonId) {
      selectedTopButton = "";
      changePage(0); // ان-سلیکٹ ہونے پر براہ راست Parties (0) پر جمپ لگے گی
    } else {
      selectedTopButton = buttonId;

      if (buttonId == "stock") {
        changePage(2);
      } else if (buttonId == "get" || buttonId == "give") {
        changePage(0);
      } else {
        notifyListeners();
      }
    }
  }
}

final sectionsController = SectionsController();