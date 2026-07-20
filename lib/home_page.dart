import 'package:flutter/gestures.dart'; // ماؤس اور ٹچ سپورٹ کے لیے ضروری ہے
import 'package:flutter/material.dart';
import 'dashboard_page.dart';

import 'home_page/sections/top.dart';
import 'home_page/sections/middle.dart';
import 'home_page/sections/bottom.dart';

import 'home_page/views/customers_list.dart';
import 'home_page/views/items.dart';
import 'home_page/views/transactions.dart';

// 1. یہ کسٹم بیہیویئر کمپیوٹر کے ماؤس (Mouse) اور موبائل کے ٹچ (Touch) دونوں سے سلائیڈنگ کو ممکن بنائے گا
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch, // موبائل کا انگلی سے سوائپ
        PointerDeviceKind.mouse, // کمپیوٹر کا ماؤس / کرسر سے ڈریگ
      };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentHomeTab = 0;

  // مڈل پیجز کے لیے کنٹرولر
  final PageController _homePageController = PageController(initialPage: 0);
  
  // ماسٹر کنٹرولر: ایپ ہمیشہ ہوم پیج (Index 1) پر کھلے گی تاکہ بائیں طرف ڈیش بورڈ (Index 0) موجود رہے
  final PageController _masterSwipeController = PageController(initialPage: 1);

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
    _masterSwipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // یہاں ہم نے کسٹم سکرول بیہیویئر لاگو کر دیا تاکہ پوری اسکرین پر ماؤس ڈریگ کام کرے
      body: ScrollConfiguration(
        behavior: AppScrollBehavior(),
        child: PageView(
          controller: _masterSwipeController,
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. بالکل بائیں (Left) طرف آپ کا ڈیش بورڈ پیج
            const DashboardPage(),

            // 2. دائیں (Right) طرف آپ کا مین ہوم پیج
            SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // ٹاپ فروزن ایریا
                    const TopSection(), 
                    
                    // مڈل سیکشن کے کیپسول بٹنز
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
                    
                    // مڈل کا متحرک ایریا (پارٹیز، ٹرانزیکشن، اسٹاک)
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