import 'package:flutter/material.dart';
import 'home_page/sections/top.dart';
import 'home_page/sections/middle.dart';
import 'home_page/sections/bottom.dart';

// صرف کسٹمرز لسٹ والی فائل امپورٹ کی ہے
import 'home_page/views/customers_list.dart'; 

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
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: const [
                  CustomersListView(), // صرف یہی ایک ویو ہے ابھی
                  Center(child: Text("دیگر پیجز بعد میں شامل ہوں گے")), 
                  Center(child: Text("دیگر پیجز بعد میں شامل ہوں گے")),
                ],
              ),
            ),
            const BottomSection(),
          ],
        ),
      ),
    );
  }
}