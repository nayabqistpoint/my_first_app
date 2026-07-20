import 'package:flutter/material.dart';
// صرف پرافٹ لاس والی فائل کا امپورٹ
import 'dashboard/widgets/profit_loss.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // تصویر کے مطابق اوپر والا ریڈ ہیڈر
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935), // خوبصورت سرخ رنگ
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false, // عارضی بیک بٹن کو روکنے کے لیے
      ),
      backgroundColor: const Color(0xfff8f9fa), // ہلکا گرے بیک گراؤنڈ
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              
              // ہم صرف اس ایک فائل کا ڈیزائن دیکھ رہے ہیں
              ProfitLossWidget(),
              
            ],
          ),
        ),
      ),
    );
  }
}