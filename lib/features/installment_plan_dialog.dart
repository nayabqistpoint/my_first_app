import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/pay_now/pay_now_widget.dart';

/// 🎯 گلوبل فنکشن: پوری ایپ (اور RequestCardHelper) میں انسٹالمنٹ ڈائیلاگ اوپن کرنے کے لیے
void showInstallmentPlanDialog(BuildContext context, String customerPhone, {bool isAdmin = false}) {
  showDialog(
    context: context,
    builder: (context) => InstallmentPlanDialog(
      customerPhone: customerPhone,
      isAdmin: isAdmin,
    ),
  );
}

class InstallmentPlanDialog extends StatelessWidget {
  final String customerPhone;
  final bool isAdmin; // 👈 1. یہاں پیرامیٹر ڈیفائن کیا گیا ہے

  const InstallmentPlanDialog({
    super.key,
    required this.customerPhone,
    this.isAdmin = false, // 👈 2. یہاں ڈیفالٹ ویلیو رکھی گئی ہے
  });

  /// 🎯 سمارٹ فنکشن: صرف ماضی اور آج کی تاریخ تک کا شارٹ نکالنا
  static double calculateTotalShort(String customerPhone) {
    final Box packageBox = Hive.isBoxOpen('packageBox') ? Hive.box('packageBox') : Hive.box('packageBox');
    final dynamic rawData = packageBox.get(customerPhone.trim());
    if (rawData == null || rawData is! Map) return 0.0;

    Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
    if (data['isPurchaseRequested'] != true) return 0.0;

    String packageName = (data['packageName'] ?? '').toString().toUpperCase().trim();
    double monthlyInstallment = double.tryParse(data['monthlyInstallment'].toString()) ?? 0.0;
    double advanceAmount = double.tryParse(data['advanceAmount'].toString()) ?? 0.0;

    int totalMonths = 6;
    bool isAdvanceType = packageName.contains('A');
    RegExp regExp = RegExp(r'(\d+)');
    var match = regExp.firstMatch(packageName);
    if (match != null) totalMonths = int.tryParse(match.group(1)!) ?? 6;

    double totalOverdueShort = 0.0;
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 30));

    for (int i = 1; i <= totalMonths; i++) {
      double dueAmount = (isAdvanceType && i == 1) ? advanceAmount : monthlyInstallment;
      double paid = (i == 1 && advanceAmount > 0) ? advanceAmount : (i == 2 ? monthlyInstallment * 0.6 : 0.0);
      double short = (dueAmount - paid) > 0 ? (dueAmount - paid) : 0.0;

      DateTime dueDate = startDate.add(Duration(days: (i - 1) * 30));
      bool isOverdue = dueDate.isBefore(now) || (dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day);
      
      if (isOverdue) totalOverdueShort += short;
    }
    return totalOverdueShort;
  }

  String _getUrduMonth(int month) {
    const months = ['جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون', 'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'];
    return months[(month - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    final Box packageBox = Hive.box('packageBox');
    final dynamic rawData = packageBox.get(customerPhone.trim());
    Map<String, dynamic>? packageData = (rawData != null && rawData is Map) ? Map<String, dynamic>.from(rawData) : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDialogHeader(context),
            const Divider(height: 16, thickness: 1),
            if (packageData == null || packageData['isPurchaseRequested'] != true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("اس کسٹمر کا کوئی ایکٹو اقساط کا پلان نہیں ملا!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.center),
              )
            else
              _buildLiveInstallmentTable(context, packageData),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade800, foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(context),
                child: const Text("بند کریں", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
              child: Icon(Icons.calendar_month, color: Colors.indigo.shade800, size: 22),
            ),
            const SizedBox(width: 8),
            const Text("جدولِ اقساط و شارٹ ڈیو", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildLiveInstallmentTable(BuildContext context, Map<String, dynamic> data) {
    String mobileName = data['mobileName'] ?? 'موبائل';
    String packageName = (data['packageName'] ?? '').toString().toUpperCase().trim();
    double monthlyInstallment = double.tryParse(data['monthlyInstallment'].toString()) ?? 0.0;
    double advanceAmount = double.tryParse(data['advanceAmount'].toString()) ?? 0.0;
    double totalPrice = double.tryParse(data['totalPrice'].toString()) ?? 0.0;

    int totalMonths = 6;
    bool isAdvanceType = packageName.contains('A');
    RegExp regExp = RegExp(r'(\d+)');
    var match = regExp.firstMatch(packageName);
    if (match != null) totalMonths = int.tryParse(match.group(1)!) ?? 6;

    List<Map<String, dynamic>> rows = [];
    double totalOverdueShort = 0.0;
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 30));

    for (int i = 1; i <= totalMonths; i++) {
      String label = (isAdvanceType && i == 1) ? "ایڈوانس (قسط 1)" : "قسط $i";
      double dueAmount = (isAdvanceType && i == 1) ? advanceAmount : monthlyInstallment;
      double paid = (i == 1 && advanceAmount > 0) ? advanceAmount : (i == 2 ? monthlyInstallment * 0.6 : 0.0);
      double short = (dueAmount - paid) > 0 ? (dueAmount - paid) : 0.0;
      double progress = dueAmount > 0 ? (paid / dueAmount).clamp(0.0, 1.0) : 0.0;

      DateTime dueDate = startDate.add(Duration(days: (i - 1) * 30));
      bool isOverdue = dueDate.isBefore(now) || (dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day);
      if (isOverdue) totalOverdueShort += short;

      rows.add({
        'label': label,
        'day': dueDate.day.toString(),
        'monthText': _getUrduMonth(dueDate.month),
        'year': dueDate.year.toString(),
        'due': dueAmount.toStringAsFixed(0),
        'paid': paid.toStringAsFixed(0),
        'short': short.toStringAsFixed(0),
        'progress': progress,
        'isOverdue': isOverdue,
        'amountToPay': short > 0 ? short : dueAmount,
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.shade100)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ماڈل: $mobileName ($packageName)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
              Text("کل قیمت: Rs ${totalPrice.toStringAsFixed(0)}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  color: Colors.grey.shade100,
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('قسط و تاریخ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
                      Expanded(flex: 2, child: Text('واجب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
                      Expanded(flex: 2, child: Text('وصول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
                      Expanded(flex: 4, child: Text('پروگریس / شارٹ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ...rows.map((inst) => _buildRowItem(context, inst)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade400, width: 1.5), boxShadow: [BoxShadow(color: Colors.red.shade50, blurRadius: 4, offset: const Offset(0, 2))]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("تاریخ گزرنے پر واجب الادا شارٹ:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text("Rs ${totalOverdueShort.toStringAsFixed(0)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRowItem(BuildContext context, Map<String, dynamic> inst) {
    double progress = inst['progress'];
    bool isFullyPaid = progress >= 1.0;
    bool isOverdue = inst['isOverdue'];
    int percentage = (progress * 100).round();

    Widget rowContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inst['label'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(inst['day'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red.shade700 : Colors.grey.shade700)),
                      const SizedBox(width: 3),
                      Text(inst['monthText'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red.shade700 : Colors.grey.shade700)),
                      const SizedBox(width: 3),
                      Text(inst['year'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red.shade700 : Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text("Rs ${inst['due']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Rs ${inst['paid']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: double.parse(inst['paid']) > 0 ? Colors.green.shade800 : Colors.black54))),
          Expanded(
            flex: 4,
            child: Container(
              height: 26,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isFullyPaid ? Colors.green.shade600 : (isOverdue ? Colors.red.shade400 : Colors.grey.shade300), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(color: isFullyPaid ? Colors.green.shade600 : Colors.green.shade500),
                    ),
                    Center(
                      child: isFullyPaid
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 13, color: Colors.white),
                                SizedBox(width: 3),
                                Text("100% مکمل", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (progress > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text("$percentage% ادا", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                Text(
                                  isOverdue ? "-Rs ${inst['short']}" : "آئندہ قسط",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isOverdue ? (progress > 0.6 ? Colors.white : Colors.red.shade900) : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // 🎯 ایڈمن موڈ میں کلک ڈس ایبل کرنے کی شرط
    if (isAdmin) {
      return rowContent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayNowWidget(
                customerMobileNumber: customerPhone,
                initialAmount: double.tryParse(inst['amountToPay'].toString()),
              ),
            ),
          );
        },
        splashColor: Colors.indigo.shade50,
        child: rowContent,
      ),
    );
  }
}