import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelController extends ChangeNotifier {
  // پیج ویو کو کنٹرول کرنے کے لیے کنٹرولر
  final PageController pageController = PageController(initialPage: 1);
  int currentIndex = 1;

  // ہر ریکویسٹ کے اندر قیمت (Price) لکھنے کے لیے الگ کنٹرولرز کا میپ
  final Map<String, TextEditingController> priceControllers = {};

  // ہر ویو کے اندر ان-پیج فلٹرز کی حالت ('all', 'purchase', 'signup', 'both')
  final Map<String, String> pageFilters = {
    'approved': 'all',
    'pending': 'all',
    'completed': 'all',
  };

  // تمام ریکویسٹس کا ڈیٹا جو ہائیو (Hive) سے آئے گا
  List<Map<String, dynamic>> requests = [];

  AdminPanelController() {
    loadRequestsFromHive();
  }

  // ہائیو باکس سے ڈیٹا لوڈ کرنے اور مکمل میপিং کرنے کا فنکشن
  void loadRequestsFromHive() {
    try {
      var customerBox = Hive.box('customerBox');
      int indexCount = 0;
      
      requests = customerBox.values.map((e) {
        var map = Map<String, dynamic>.from(e);
        
        // 1. محفوظ ID بنانا تاکہ نل (Null) ہونے پر ایپ کریش نہ ہو
        map['id'] = map['id']?.toString() ?? 'req_${indexCount++}';

        // 2. بیسک اسٹیٹس
        map['status'] = map['status']?.toString().toLowerCase() ?? 'pending';
        
        // 3. کسٹمر انفارمیشن (تمام ممکنہ کیز کو کور کیا گیا ہے تاکہ ڈیٹا غائب نہ ہو)
        map['name'] = map['customerName']?.toString() ?? map['name']?.toString() ?? map['fullName']?.toString() ?? 'نام موجود نہیں';
        map['fatherName'] = map['customerFatherName']?.toString() ?? map['fatherName']?.toString() ?? map['father_name']?.toString() ?? '';
        map['caste'] = map['customerCaste']?.toString() ?? map['caste']?.toString() ?? '';
        map['phone'] = map['customerPhone']?.toString() ?? map['phone']?.toString() ?? map['phoneNumber']?.toString() ?? map['mobile']?.toString() ?? '';
        map['cnic'] = map['customerCnic']?.toString() ?? map['cnic']?.toString() ?? map['idCard']?.toString() ?? '';
        map['address'] = map['customerAddress']?.toString() ?? map['address']?.toString() ?? '';
        
        // 4. پیکج یا پرچیز سے جڑی فیلڈز
        bool hasPackage = map['packageName'] != null || map['mobileName'] != null || map['cashPrice'] != null;
        
        if (hasPackage) {
          map['requestType'] = 'سائن اپ + پرچیز';
          map['filterKey'] = 'both';
        } else {
          map['requestType'] = 'صرف سائن اپ';
          map['filterKey'] = 'signup';
        }

        // 5. پرچیز اور آئٹم کی تفصیلات
        map['mobileName'] = map['mobileName']?.toString() ?? 'کوئی ڈیوائس نہیں';
        map['cashPrice'] = map['cashPrice']?.toString() ?? '0';
        map['advance'] = map['advance']?.toString() ?? '0';
        map['installment'] = map['installment']?.toString() ?? '0';
        map['packageName'] = map['packageName']?.toString() ?? '';
        map['isManualMode'] = map['isManualMode'] ?? false;

        // 6. ضامن (Guarantor) کی تفصیلات کی درست میपिंग
        map['hasGuarantor'] = map['isGuarantorPresent'] ?? map['hasGuarantor'] ?? (map['guarantorName'] != null && map['guarantorName'].toString().isNotEmpty);
        
        map['guarantorName'] = map['guarantorName']?.toString() ?? map['customerGuarantorName']?.toString() ?? '';
        map['guarantorFatherName'] = map['guarantorFatherName']?.toString() ?? '';
        map['guarantorCaste'] = map['guarantorCaste']?.toString() ?? '';
        map['guarantorPhone'] = map['guarantorPhone']?.toString() ?? map['customerGuarantorPhone']?.toString() ?? '';
        map['guarantorCnic'] = map['guarantorCnic']?.toString() ?? map['customerGuarantorCnic']?.toString() ?? '';
        map['guarantorRelationship'] = map['guarantorRelationship']?.toString() ?? '';
        map['guarantorAddress'] = map['guarantorAddress']?.toString() ?? '';

        map['isExpanded'] = false;
        
        return map;
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint("Hive Load Error: $e");
    }
  }

  // ریکویسٹ کا سٹیٹس تبدیل کرنے کا فنکشن
  Future<void> updateRequestStatus(int index, String newStatus) async {
    var customerBox = Hive.box('customerBox');
    
    requests[index]['status'] = newStatus;
    await customerBox.putAt(index, requests[index]);
    
    notifyListeners();
  }

  // فون کال کرنے کا فنکشن
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  // واٹس ایپ میسج بھیجنے کا فنکشن
  Future<void> openWhatsApp(String phone, String message) async {
    String formattedPhone = phone.startsWith('0') ? '92${phone.substring(1)}' : phone;
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}');
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  // وسائل ختم (Dispose) کرنے کے لیے
  @override
  void dispose() {
    pageController.dispose();
    for (var controller in priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}