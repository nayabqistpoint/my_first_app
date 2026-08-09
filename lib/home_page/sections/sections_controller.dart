import 'package:flutter/material.dart';

class SectionsController extends ChangeNotifier {
  final PageController pageController = PageController();

  // 0 = Parties / Customers (ہمارا مرکزی ڈیفالٹ پیج)
  // 1 = Transactions
  // 2 = Stock
  int currentPageIndex = 0;
  String selectedTopButton = "";

  void changePage(int index) {
    currentPageIndex = index;
    _updateTopButtonState(index);

    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
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

  // پیج کی مناسبت سے ٹاپ بٹن کی حالت اپڈیٹ کرنے کا فنکشن
  void _updateTopButtonState(int index) {
    if (index == 2) {
      selectedTopButton = "stock";
    } else if (index == 0) {
      // اگر پارٹیز پیج پر ہوں اور کوئی بٹن سلیکٹ نہ ہو تو ڈیفالٹ خالی یا Get رکھ سکتے ہیں
      if (selectedTopButton != "get" && selectedTopButton != "give") {
        selectedTopButton = "";
      }
    } else {
      selectedTopButton = "";
    }
  }

  // ٹاپ بار بٹنز کی ٹاگل لاجک (ایک بار کلک سے سلیکٹ، دوسری بار سے ان-سلیکٹ)
  void selectTopButton(String buttonId) {
    // اگر وہی بٹن دوبارہ کلک ہو تو ان-سلیکٹ (باہر نکل) آئے گا 
    // اور ڈائریکٹ ہمارے مرکزی پیج: Customers / Parties (انڈیکس 0) پر واپس چلا جائے گا
    if (selectedTopButton == buttonId) {
      selectedTopButton = "";
      changePage(0); // 0 = Customers / Parties View
    } else {
      selectedTopButton = buttonId;

      if (buttonId == "stock") {
        changePage(2); // 2 = Stock Page
      } else if (buttonId == "get" || buttonId == "give") {
        changePage(0); // 0 = Customers / Parties Page
      } else {
        notifyListeners();
      }
    }
  }
}

final sectionsController = SectionsController();