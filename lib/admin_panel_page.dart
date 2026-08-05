import 'package:flutter/material.dart';
import 'welcome/admin_panel/admin_panel_controller.dart';
import 'welcome/admin_panel/capsule_filter.dart';
import 'welcome/admin_panel/approved_view.dart';
import 'welcome/admin_panel/pending_view.dart';
import 'welcome/admin_panel/completed_view.dart'; 
import 'welcome/admin_panel/pending/pending_approvals_drawer.dart'; 

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final AdminPanelController _controller = AdminPanelController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshState);
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshState);
    _controller.dispose();
    super.dispose();
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pendingCount = _controller.pendingRequestsCount;

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
          leadingWidth: 120, // 📏 جگہ کو مزید کھلا کر دیا تاکہ لکھائی کی طرف آنے کی جگہ بنے
          leading: Builder(
            builder: (context) => Transform.translate(
              // 🚀 یہاں مینس (Minus) سائن کی وجہ سے دونوں چیزیں اب سیدھی ٹائتل (لکھائی) کی طرف بڑھیں گی
              offset: const Offset(-12, 0),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 🍔 سب سے پہلے تھری لائنز مینو بٹن
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (pendingCount > 0) const SizedBox(width: 8),
                    // 🔢 اور اس کے بعد ریڈ بیج
                    if (pendingCount > 0)
                      Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        drawer: const PendingApprovalsDrawer(),
        body: Column(
          children: [
            CapsuleFilterWidget(
              controller: _controller,
              onStateChanged: _refreshState,
            ),
            const Divider(height: 1, color: Colors.grey),
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
    );
  }
}