import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';

// آپ کے پروجیکٹ کے بالکل سیدھے اور محفوظ امپورٹ راستے
import 'home_page/sections/top.dart';
import 'home_page/sections/middle.dart';
import 'home_page/sections/bottom.dart';

import 'home_page/views/customers_list.dart';
import 'home_page/views/items.dart';
import 'home_page/views/transactions.dart';

// ماؤس اور ٹچ دونوں سے سلائیڈنگ کو ممکن بنانے کے لیے کسٹم بیہیویئر
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // مڈل سیکشن کے کیپسول بٹنز کے لیے انڈیکس اسٹیٹ
  int _currentHomeTab = 0;

  // مڈل پیجز کی سوائپنگ کے لیے اندرونی پیج کنٹرولر
  final PageController _homePageController = PageController(initialPage: 0);

  // صفحات کی لسٹ (پارٹیز پیج سفید بیک گراؤنڈ کے ساتھ بحال ہے)
  late final List<Widget> _homeViews;

  @override
  void initState() {
    super.initState();
    _homeViews = [
      Container(
        color: Colors.white,
        child: const CustomersListView(),
      ),
      const TransactionsPage(),
      const ItemsPage(),
    ];
  }

  @override
  void dispose() {
    _homePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // masterSwipeController: ایپ ہمیشہ ہوم پیج (Index 1) پر کھلے گی تاکہ بائیں طرف ڈیش بورڈ رہے
    final PageController masterSwipeController = PageController(initialPage: 1);

    return Scaffold(
      body: ScrollConfiguration(
        behavior: AppScrollBehavior(),
        child: PageView(
          controller: masterSwipeController,
          physics: const BouncingScrollPhysics(), // ڈیش بورڈ کے لیے مین سوائپ
          children: [
            // 1. بالکل بائیں طرف آپ کا فنانشل بورڈ (ڈیش بورڈ) پیج
            const DashboardPage(),

            // 2. دائیں طرف آپ کا مین ہوم پیج اپنے تمام سیکشنز کے ساتھ
            SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // ٹاپ فروزن ایریا
                    const TopSection(), 
                    
                    // مڈل سیکشن (بٹنز اور سلائیڈنگ کنیکٹڈ ہیں)
                    MiddleSection(
                      selectedIndex: _currentHomeTab,
                      onTabSelected: (index) {
                        setState(() {
                          _currentHomeTab = index;
                        });
                        _homePageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    
                    // متحرک ایریا (پارٹیز، ٹرانزیکشن، اسٹاک کی سوائپنگ)
                    Expanded(
                      child: PageView(
                        controller: _homePageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentHomeTab = index;
                          });
                        },
                        children: _homeViews,
                      ),
                    ),
                    
                    // باٹم فروزن ایریا
                    const BottomSection(), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}