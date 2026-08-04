import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelController extends ChangeNotifier {
  final PageController pageController = PageController(initialPage: 1);
  int currentIndex = 1;

  final Map<String, TextEditingController> priceControllers = {};

  final Map<String, String> pageFilters = {
    'approved': 'all',
    'pending': 'all',
    'completed': 'all',
  };

  bool isNewestFirst = true;
  DateTime? selectedFilterDate;
  List<Map<String, dynamic>> _allRequests = [];

  AdminPanelController() {
    loadRequestsFromHive();
  }

  List<Map<String, dynamic>> get requests {
    var filtered = _allRequests.where((req) {
      if (selectedFilterDate == null) return true;
      String timeStr = req['timestamp']?.toString() ?? '';
      DateTime? reqDate = DateTime.tryParse(timeStr);
      if (reqDate == null) return false;
      
      return reqDate.year == selectedFilterDate!.year &&
             reqDate.month == selectedFilterDate!.month &&
             reqDate.day == selectedFilterDate!.day;
    }).toList();

    filtered.sort((a, b) {
      String timeA = a['timestamp']?.toString() ?? '';
      String timeB = b['timestamp']?.toString() ?? '';
      
      DateTime? dateA = DateTime.tryParse(timeA);
      DateTime? dateB = DateTime.tryParse(timeB);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      if (isNewestFirst) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  void toggleSortOrder(bool newestFirst) {
    isNewestFirst = newestFirst;
    notifyListeners();
  }

  void filterByDate(DateTime? date) {
    selectedFilterDate = date;
    notifyListeners();
  }

  void clearDateFilter() {
    selectedFilterDate = null;
    notifyListeners();
  }

  void loadRequestsFromHive() {
    try {
      var customerBox = Hive.box('customerBox');
      int indexCount = 0;
      
      _allRequests = customerBox.values.map((e) {
        var map = Map<String, dynamic>.from(e);
        
        map['id'] = map['id']?.toString() ?? 'req_${indexCount++}';
        map['status'] = map['status']?.toString().toLowerCase() ?? 'pending';
        
        map['name'] = map['customerName']?.toString() ?? map['name']?.toString() ?? map['fullName']?.toString() ?? 'نام موجود نہیں';
        map['fatherName'] = map['customerFatherName']?.toString() ?? map['fatherName']?.toString() ?? map['father_name']?.toString() ?? '';
        map['caste'] = map['customerCaste']?.toString() ?? map['caste']?.toString() ?? '';
        map['phone'] = map['customerPhone']?.toString() ?? map['phone']?.toString() ?? map['phoneNumber']?.toString() ?? map['mobile']?.toString() ?? '';
        map['cnic'] = map['customerCnic']?.toString() ?? map['cnic']?.toString() ?? map['idCard']?.toString() ?? '';
        map['address'] = map['customerAddress']?.toString() ?? map['address']?.toString() ?? '';
        
        map['username'] = map['phone'];
        
        String cnicStr = map['cnic'];
        String defaultPassword = '1234';
        if (cnicStr.length >= 4) {
          defaultPassword = cnicStr.substring(cnicStr.length - 4);
        }
        map['password'] = map['password']?.toString() ?? defaultPassword;

        // یہاں ہم چیک کرتے ہیں کہ آیا ہائیو کے اندر پہلے سے کوئی مخصوص filterKey موجود ہے یا نہیں
        if (map['filterKey'] != null) {
          // اگر یہ 'purchase_only' ہے تو اسے 'صرف پرچیز' رکھیں، ورنہ ہائیو والا پرانا ٹائپ برقرار رکھیں
          if (map['filterKey'] == 'purchase_only') {
            map['requestType'] = 'صرف پرچیز';
          } else {
            map['requestType'] = map['requestType']?.toString() ?? 'سائن اپ + پرچیز';
          }
        } else {
          // پرانا آٹومیٹک چیک (اگر فلٹر کی موجود نہ ہو)
          bool hasPackage = map['packageName'] != null || map['mobileName'] != null || map['cashPrice'] != null;
          
          if (hasPackage) {
            map['requestType'] = 'سائن اپ + پرچیز';
            map['filterKey'] = 'both';
          } else {
            map['requestType'] = 'صرف سائن اپ';
            map['filterKey'] = 'signup';
          }
        }

        map['mobileName'] = map['mobileName']?.toString() ?? 'کوئی ڈیوائس نہیں';
        map['cashPrice'] = map['cashPrice']?.toString() ?? '0';
        map['advanceAmount'] = map['advanceAmount']?.toString() ?? map['advance']?.toString() ?? '0';
        map['monthlyInstallment'] = map['monthlyInstallment']?.toString() ?? map['installment']?.toString() ?? '0';
        map['packageName'] = map['packageName']?.toString() ?? '';
        map['isBuyStockMode'] = map['isBuyStockMode'] ?? !(map['isManualMode'] ?? false);
        map['totalPrice'] = map['totalPrice']?.toString() ?? '0';

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

  Future<void> updateRequestStatus(int index, String newStatus) async {
    var customerBox = Hive.box('customerBox');
    
    int originalIndex = _allRequests.indexWhere((r) => r['id'] == requests[index]['id']);
    if (originalIndex != -1) {
      _allRequests[originalIndex]['status'] = newStatus;
      await customerBox.putAt(originalIndex, _allRequests[originalIndex]);
    }
    
    notifyListeners();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> openWhatsApp(String phone, String message) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('92') && cleanPhone.length == 10) {
      cleanPhone = '92$cleanPhone';
    }

    final Uri whatsappUri = Uri.parse(
      'https://api.whatsapp.com/send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}'
    );
    
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("WhatsApp Launch Error: $e");
    }
  }

  // مکمل اور تفصیلی منظوری کا میسج
  Future<void> sendApprovalWhatsApp(Map<String, dynamic> req) async {
    String phone = req['phone'] ?? '';
    String username = req['username'] ?? phone;
    String password = req['password'] ?? '1234';

    String message = 
      "\u200Fالسلام علیکم محترم و معزز کسٹمر صاحب!\n\n"
      "آپ کو مطلع کیا جاتا ہے کہ آپ کی درخواست منظور کر لی گئی ہے اور آپ کا یوزر نیم اور پاسورڈ اسائن کر دیا گیا ہے۔\n\n"
      "🔹 آپ کا موبائل نمبر ہی آپ کا یوزر نیم ہے: $username\n"
      "🔹 آپ کا پاسورڈ (شناختی کارڈ کے آخری 4 ہندسے): $password\n\n"
      "مزید خریداری اور نئی درخواست دینے کے لیے آپ اپنے سائن اپ پیج سے اپلائی کر سکتے ہیں۔\n\n"
      "برائے مہربانی قانونی دستاویزات کی مکمل تکمیل اور موبائل کی وصولی کے لیے اپنے اصل شناختی کارڈ کے ہمراہ ہماری دکان پر تشریف لائیں۔ شکریہ!";

    await openWhatsApp(phone, message);
  }

  // مکمل اور تفصیلی ریجیکشن / اعتراض کا میسج
  Future<void> sendRejectionWhatsApp(Map<String, dynamic> req) async {
    String phone = req['phone'] ?? '';

    String message = 
      "\u200Fالسلام علیکم محترم و معزز کسٹمر صاحب!\n\n"
      "آپ کی درخواست کے حوالے سے معذرت خواہ ہیں؛ آپ کی درج کردہ قیمت اور مارکیٹ کے ریٹ میں فرق آ رہا ہے۔\n\n"
      "برائے مہربانی درست مارکیٹ ریٹ کے حساب سے دوبارہ درخواست (اپلائی) کریں تاکہ آپ کی کارروائی کو آگے بڑھایا جا سکے؛ شکریہ!";

    await openWhatsApp(phone, message);
  }

  @override
  void dispose() {
    pageController.dispose();
    for (var controller in priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}