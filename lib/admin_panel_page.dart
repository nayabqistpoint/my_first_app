import 'package:flutter/material.dart';
import 'package:my_first_app/welcome/admin_panel/admin_panel_controller.dart';
import 'package:my_first_app/welcome/admin_panel/approved_view.dart';
import 'package:my_first_app/welcome/admin_panel/pending_view.dart';
import 'package:my_first_app/welcome/admin_panel/completed_view.dart'; 
import 'package:my_first_app/welcome/admin_panel/pending/pending_approvals_drawer.dart'; 
import 'package:my_first_app/welcome/admin_panel/pending/pending_approvals_controller.dart';
import 'package:my_first_app/welcome/admin_panel/admin_top_ui.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final AdminPanelController _controller = AdminPanelController();
  final PendingApprovalsController _drawerController = PendingApprovalsController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshState);
    _drawerController.addListener(_refreshState);
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshState);
    _drawerController.removeListener(_refreshState);
    _controller.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pendingDrawerCount = _drawerController.pendingCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        drawer: const PendingApprovalsDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // 🎯 ٹاپ ہیڈر (ایڈمن پینل، نایاب قسط پوائنٹ اور ڈراور بٹن)
              Builder(
                builder: (context) {
                  return AdminTopUI(
                    selectedIndex: _controller.currentIndex,
                    onTabSelected: (index) {
                      _controller.pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onMenuPressed: () => Scaffold.of(context).openDrawer(),
                    pendingCount: pendingDrawerCount,
                  );
                },
              ),

              // 🎯 پیج ویو (تمام ویوز کا سائز کنٹرول کرنے کے لیے)
              Expanded(
                child: PageView(
                  controller: _controller.pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _controller.currentIndex = index;
                    });
                  },
                  children: [
                    ApprovedView(
                      controller: _controller,
                      onStateChanged: _refreshState,
                    ),
                    PendingView(
                      controller: _controller,
                      onStateChanged: _refreshState,
                    ),
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
      ),
    );
  }
}