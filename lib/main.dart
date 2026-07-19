import 'package:flutter/gestures.dart'; // ماؤس ڈریگنگ سپورٹ کے لیے
import 'package:flutter/material.dart';
import 'home_page/sections/top.dart';
import 'home_page/sections/middle.dart';
import 'home_page/sections/bottom.dart';
import 'home_page/views/customers_list.dart'; 
import 'home_page/views/transactions.dart'; 
import 'home_page/views/items.dart'; 

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomePage(),
));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TopSection(),
            MiddleSection(
              selectedIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.animateToPage(
                  index, 
                  duration: const Duration(milliseconds: 250), 
                  curve: Curves.easeInOut
                );
              },
            ),
            Expanded(
              // یہاں ہم نے اسکرول بیہیویر بدلا ہے تاکہ ماؤس کرسر سے بھی سلائیڈ ہو سکے
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch, // موبائل ٹچ سپورٹ
                    PointerDeviceKind.mouse, // ماؤس کرسر ڈریگ سپورٹ (یہ اصل حل ہے)
                  },
                ),
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(), 
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index; 
                    });
                  },
                  children: const [
                    CustomersListView(), 
                    TransactionsPage(),  
                    ItemsPage(),         
                  ],
                ),
              ),
            ),
            const BottomSection(),
          ],
        ),
      ),
    );
  }
}