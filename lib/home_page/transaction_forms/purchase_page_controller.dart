class PurchaseController {
  // 1. इनवॉइस नंबर
  final String invoiceNo = 'INV-1001';

  // 2. असली और आज की तारीख (Current Date)
  String get currentDate {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  // 3. असली समय (Current Time)
  String get currentTime {
    final now = DateTime.now();
    int hour = now.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";
  }
}