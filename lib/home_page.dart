import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/dashboard_page.dart';
import 'package:my_first_app/admin_panel_page.dart';

// سیکشنز اور ویوز کی امپورٹس
import 'package:my_first_app/home_page/sections/top.dart';
import 'package:my_first_app/home_page/sections/middle.dart';
import 'package:my_first_app/home_page/sections/bottom.dart';
import 'package:my_first_app/home_page/sections/sections_controller.dart';

import 'package:my_first_app/home_page/views/customers_list.dart';
import 'package:my_first_app/home_page/views/items.dart';
import 'package:my_first_app/home_page/views/transactions.dart';

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
  late final List<Widget> _homeViews;
  late final PageController _masterSwipeController;

  @override
  void initState() {
    super.initState();
    // ماسٹر سوائپ کنٹرولر کو یہاں ایک ہی بار انیشلائز کیا ہے
    _masterSwipeController = PageController(initialPage: 1);

    _homeViews = [
      Container(
        color: Colors.white,
        child: const CustomersListView(), // Index 0 (Parties)
      ),
      const TransactionsPage(),             // Index 1 (Transactions)
      const ItemsPage(),                    // Index 2 (Stock)
    ];
  }

  @override
  void dispose() {
    _masterSwipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: AppScrollBehavior(),
        child: PageView(
          controller: _masterSwipeController,
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. فنانشل بورڈ (Dashboard)
            const DashboardPage(),

            // 2. ہوم پیج
            SafeArea(
              child: Container(
                color: Colors.white,
                child: ListenableBuilder(
                  listenable: sectionsController,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // ٹاپ سیکشن (ٹاپ بٹنز)
                        const TopSection(),

                        // مڈل سیکشن (کیپسول بٹنز)
                        const MiddleSection(),

                        // متحرک ویوز (Customers, Transactions, Items)
                        Expanded(
                          child: PageView(
                            controller: sectionsController.pageController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              sectionsController.onPageSwiped(index);
                            },
                            children: _homeViews,
                          ),
                        ),

                        // باٹم سیکشن
                        const BottomSection(),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 3. ایڈمن پینل
            const AdminPanelPage(),
          ],
        ),
      ),
    );
  }
}