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

  int get pendingRequestsCount {
    return _allRequests.where((r) => (r['status']?.toString().toLowerCase() ?? 'pending') == 'pending').length;
  }

  List<Map<String, dynamic>> get requests {
    var filtered = _allRequests.where((req) {
      String status = req['status']?.toString().toLowerCase() ?? 'pending';
      if (status != 'pending') return false;

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

  List<Map<String, dynamic>> get approvedRequests {
    return _allRequests.where((req) {
      String status = req['status']?.toString().toLowerCase() ?? '';
      return status == 'approved';
    }).toList();
  }

  List<Map<String, dynamic>> get completedRequests {
    return _allRequests.where((req) {
      String status = req['status']?.toString().toLowerCase() ?? '';
      return status == 'completed';
    }).toList();
  }

  // 🔄 فلٹر اور سوٹنگ کے فنکشنز (جن کے ایرر آ رہے تھے)
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

  // 📞 کال کا فنکشن
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Phone Call Error: $e");
    }
  }

  void loadRequestsFromHive() {
    try {
      var customerBox = Hive.box('customerBox');
      _allRequests = [];

      for (var key in customerBox.keys) {
        var rawData = customerBox.get(key);
        if (rawData != null) {
          var map = Map<String, dynamic>.from(rawData);
          
          map['hiveKey'] = key;
          map['status'] = map['status']?.toString().toLowerCase() ?? 'pending';
          
          map['name'] = map['customerName']?.toString() ?? map['name']?.toString() ?? 'نام موجود نہیں';
          map['phone'] = map['customerPhone']?.toString() ?? map['phone']?.toString() ?? '';
          map['username'] = map['phone'];
          
          String phoneStr = map['phone'];
          String defaultPassword = '1234';
          if (phoneStr.length >= 4) {
            defaultPassword = phoneStr.substring(phoneStr.length - 4);
          }
          map['password'] = map['password']?.toString() ?? defaultPassword;

          _allRequests.add(map);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Hive Load Error: $e");
    }
  }

  Future<void> callForVerification(Map<String, dynamic> req) async {
    String phone = req['phone'] ?? '';
    String name = req['name'] ?? 'کسٹمر';
    String msg = "السلام علیکم محترم $name صاحب! آپ کی درخواست کے سلسلے میں آپ سے گزارش ہے کہ فزیکل تصدیق اور اصل دستاویزات کے ہمراہ ہماری دکان پر تشریف لائیں۔ شکریہ!";
    await openWhatsApp(phone, msg);
  }

  Future<void> approveTransaction(dynamic hiveKey) async {
    try {
      var customerBox = Hive.box('customerBox');
      var record = customerBox.get(hiveKey);
      if (record != null) {
        var updatedMap = Map<String, dynamic>.from(record);
        updatedMap['status'] = 'approved';
        updatedMap['isApproved'] = true;
        await customerBox.put(hiveKey, updatedMap);
      }

      int index = _allRequests.indexWhere((r) => r['hiveKey'] == hiveKey);
      if (index != -1) {
        String phone = _allRequests[index]['phone'] ?? '';
        String name = _allRequests[index]['name'] ?? 'کسٹمر';
        String msg = "السلام علیکم محترم $name صاحب!\n\nآپ کی درخواست منظور کر لی گئی ہے۔ شکریہ!";
        await openWhatsApp(phone, msg);
      }
      loadRequestsFromHive();
    } catch (e) {
      debugPrint("Approve Error: $e");
    }
  }

  Future<void> assignUsernameAndComplete(dynamic hiveKey) async {
    try {
      var customerBox = Hive.box('customerBox');
      var record = customerBox.get(hiveKey);
      if (record != null) {
        var updatedMap = Map<String, dynamic>.from(record);
        updatedMap['status'] = 'completed';
        await customerBox.put(hiveKey, updatedMap);
      }

      int index = _allRequests.indexWhere((r) => r['hiveKey'] == hiveKey);
      if (index != -1) {
        await sendApprovalWhatsApp(_allRequests[index]);
      }
      loadRequestsFromHive();
    } catch (e) {
      debugPrint("Complete Error: $e");
    }
  }

  Future<void> rejectTransaction(dynamic hiveKey) async {
    try {
      var customerBox = Hive.box('customerBox');
      var record = customerBox.get(hiveKey);
      if (record != null) {
        var updatedMap = Map<String, dynamic>.from(record);
        updatedMap['status'] = 'rejected';
        await customerBox.put(hiveKey, updatedMap);
      }

      int index = _allRequests.indexWhere((r) => r['hiveKey'] == hiveKey);
      if (index != -1) {
        await sendRejectionWhatsApp(_allRequests[index]);
      }
      loadRequestsFromHive();
    } catch (e) {
      debugPrint("Reject Error: $e");
    }
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

  Future<void> sendApprovalWhatsApp(Map<String, dynamic> req) async {
    String phone = req['phone'] ?? '';
    String username = req['username'] ?? phone;
    String password = req['password'] ?? '1234';

    String message = 
      "\u200Fالسلام علیکم!\n\n"
      "آپ کا یوزر نیم اور پاسورڈ اسائن کر دیا گیا:\n\n"
      "🔹 یوزر نیم: $username\n"
      "🔹 پاسورڈ: $password\n\n"
      "دکان پر تشریف لائیں۔ شکریہ!";

    await openWhatsApp(phone, message);
  }

  Future<void> sendRejectionWhatsApp(Map<String, dynamic> req) async {
    String phone = req['phone'] ?? '';
    String message = "\u200Fالسلام علیکم! آپ کی درخواست فی الحال منظور نہیں ہو سکی۔ شکریہ!";
    await openWhatsApp(phone, message);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}