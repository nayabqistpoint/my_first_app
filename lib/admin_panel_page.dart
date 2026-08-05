import 'package:flutter/material.dart';
import 'welcome/admin_panel/admin_panel_controller.dart';
import 'welcome/admin_panel/capsule_filter.dart';
import 'welcome/admin_panel/approved_view.dart';
import 'welcome/admin_panel/pending_view.dart';
import 'welcome/admin_panel/completed_view.dart'; // مکمل شدہ ویو کا آخری امپورٹ
import 'welcome/admin_panel/pending/pending_approvals_drawer.dart'; // پینڈنگ ڈراور کا امپورٹ

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  // مین کنٹرولر کا انسٹینس
  final AdminPanelController _controller = AdminPanelController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // یو آئی کو ریفریش کرنے کے لیے ہیلپر فنکشن
  void _refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFFE53935),
          title: const Text(
            "ایڈمن پینل - موصولہ درخواستیں", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          // ایپ بار کی بائیں جانب ڈبل لائنز والا مینو آئیکن جو ڈراور کھولے گا
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        // پینڈنگ اپروول ڈراور کو یہاں لنک کر دیا گیا ہے
        drawer: const PendingApprovalsDrawer(),
        body: Column(
          children: [
            // اوپر والے کیپسول ٹیبز
            CapsuleFilterWidget(
              controller: _controller,
              onStateChanged: _refreshState,
            ),
            const Divider(height: 1, color: Colors.grey),

            // ویوز کا سیکشن (PageView)
            Expanded(
              child: PageView(
                controller: _controller.pageController,
                onPageChanged: (index) {
                  setState(() {
                    _controller.currentIndex = index;
                  });
                },
                children: [
                  // 0: منظور شدہ ویو
                  ApprovedView(
                    controller: _controller,
                    onStateChanged: _refreshState,
                  ),
                  
                  // 1: پینڈنگ ویو
                  PendingView(
                    controller: _controller,
                    onStateChanged: _refreshState,
                  ),

                  // 2: مکمل شدہ ویو (اب یہ بھی لائیو کنیکٹ ہو چکا ہے)
                  CompletedView(
                    controller: _controller,
                    onStateChanged: _refreshState,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}