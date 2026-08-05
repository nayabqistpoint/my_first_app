import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // کال اور واٹس ایپ لانچ کرنے کے لیے
import 'pending_approvals_controller.dart';

class PendingApprovalsDrawer extends StatefulWidget {
  const PendingApprovalsDrawer({super.key});

  @override
  State<PendingApprovalsDrawer> createState() => _PendingApprovalsDrawerState();
}

class _PendingApprovalsDrawerState extends State<PendingApprovalsDrawer> {
  late final PendingApprovalsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PendingApprovalsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 📞 فون کال کرنے کا فنکشن
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  // 💚 واٹس ایپ اوپن کرنے کا فنکشن
  Future<void> _openWhatsApp(String phoneNumber) async {
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '92${formattedPhone.substring(1)}';
    }
    final Uri whatsappUri = Uri.parse("https://wa.me/$formattedPhone");
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Drawer(
          width: MediaQuery.of(context).size.width * 0.88,
          child: Column(
            children: [
              // 🎨 ڈراور کا ہیڈر
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: const Color(0xFFE53935),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "پینڈنگ قسطیں / ریکوئسٹس",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 🔴 سرخ بیج
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_controller.pendingCount}",
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 📋 پینڈنگ انٹریز کی لسٹ
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.pendingTransactions.isEmpty
                        ? const Center(
                            child: Text(
                              "کوئی پینڈنگ انٹری موجود نہیں",
                              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _controller.pendingTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _controller.pendingTransactions[index];
                              final hiveKey = tx['hiveKey'];
                              final String phone = tx['customerPhone']?.toString() ?? '';
                              final double amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
                              final String date = tx['date']?.toString() ?? '';
                              final String description = tx['description']?.toString() ?? 'کوئی تفصیل نہیں';

                              // 🔍 کسٹمر باکس سے مکمل تفصیلات حاصل کرنا
                              final details = _controller.getCustomerDetails(phone);
                              String rawName = details['name'] ?? '';
                              if (rawName.isEmpty) {
                                rawName = tx['customerName']?.toString() ?? 'نامعلوم کسٹمر';
                              }
                              final String caste = details['caste'] ?? '';
                              final String selfiePath = details['selfie'] ?? '';

                              // 🏷️ نام اور کاسٹ بریکٹ میں
                              final String displayName = caste.isNotEmpty ? "$rawName ($caste)" : rawName;

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ExpansionTile(
                                  // 🔽 بند حالت میں (واضح اور ہائی لائٹڈ لکھائی)
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "Rs ${amount.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "فون: $phone | تاریخ: $date",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // 🔽 ایکسپینڈ ہونے پر کسٹمر کی مکمل تفصیلات، کال/واٹس ایپ اور پاسپورٹ سائز (چورس) تصویر
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 📷 کسٹمر کی چورس (پاسپورٹ سائز) تصویر اور نام کا سیکشن
                                          Row(
                                            children: [
                                              Container(
                                                width: 55,
                                                height: 65,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: Colors.grey.shade400, width: 1),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: selfiePath.isNotEmpty
                                                      ? Image.network(
                                                          selfiePath,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Colors.grey),
                                                        )
                                                      : const Icon(Icons.person, size: 30, color: Colors.grey),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      displayName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "تاریخ درخواست: $date",
                                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 20, thickness: 1),

                                          // 📞 فون نمبر اور ڈائلر/واٹس ایپ ہائپر لنکس
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.phone, size: 18, color: Colors.blue),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      phone,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // کال اور واٹس ایپ کے آئیکنز
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () => _makePhoneCall(phone),
                                                    icon: const Icon(Icons.call, color: Colors.green, size: 24),
                                                    tooltip: 'کال کریں',
                                                  ),
                                                  const SizedBox(width: 4),
                                                  IconButton(
                                                    onPressed: () => _openWhatsApp(phone),
                                                    icon: const Icon(Icons.chat, color: Colors.teal, size: 24), // واٹس ایپ آئیکن
                                                    tooltip: 'واٹس ایپ پر رابطہ کریں',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // 📝 تفصیل
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.description, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  "تفصیل: $description",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // ❌ رد کریں اور ✅ منظور کریں بٹنز
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _controller.rejectTransaction(hiveKey),
                                                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                                label: const Text("رد کریں", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: Colors.red),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton.icon(
                                                onPressed: () => _controller.approveTransaction(hiveKey),
                                                icon: const Icon(Icons.check, color: Colors.white, size: 16),
                                                label: const Text("منظور کریں", style: TextStyle(fontWeight: FontWeight.bold)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}