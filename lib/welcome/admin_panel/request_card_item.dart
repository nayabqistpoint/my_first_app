import 'package:flutter/material.dart';
import 'admin_panel_controller.dart';
import 'widgets/card_action_buttons.dart';

class RequestCardItem extends StatelessWidget {
  final Map<String, dynamic> request;
  final AdminPanelController controller;
  final VoidCallback onStateChanged;

  const RequestCardItem({
    super.key,
    required this.request,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    String reqId = request['id']?.toString() ?? 'temp_id_${request.hashCode}';

    if (!controller.priceControllers.containsKey(reqId)) {
      controller.priceControllers[reqId] = TextEditingController(
        text: request['cashPrice']?.toString() ?? '',
      );
    }
    final priceController = controller.priceControllers[reqId]!;
    bool isExpanded = request['isExpanded'] ?? false;

    bool hasMobilePackage = request['mobileName'] != null && 
        request['mobileName'].toString() != 'کوئی ڈیوائس نہیں' && 
        request['mobileName'].toString().isNotEmpty &&
        request['mobileName'].toString() != 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              request['isExpanded'] = !isExpanded;
              onStateChanged();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Color(0xFFE53935)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(request['name'] ?? 'نام نا معلوم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE53935), width: 1),
                              ),
                              child: Text(
                                request['requestType'] ?? 'صرف سائن اپ', 
                                style: const TextStyle(fontSize: 10, color: Color(0xFFE53935), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasMobilePackage 
                            ? "فون: ${request['phone']} | ماڈل: ${request['mobileName']}" 
                            : "فون: ${request['phone']} | (صرف سائن اپ - کوئی پیکج نہیں)",
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600]),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("■ کسٹمر کی معلومات", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${request['name']} (والد: ${request['fatherName']}) | قوم: ${request['caste']}", 
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => controller.makePhoneCall(request['phone']),
                                child: Text("فون نمبر: ${request['phone']} 📞 (کال کریں)", style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 3),
                              Text("شناختی کارڈ: ${request['cnic']}", style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 3),
                              Text("پتہ: ${request['address']}", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (hasMobilePackage) ...[
                    const SizedBox(height: 12),
                    const Text("■ منتخب کردہ موبائل اور قسط پیکج", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("موبائل ماڈل: ${request['mobileName'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Text("خریداری کا موڈ: ${request['isBuyStockMode'] == true ? 'بائے اسٹاک' : 'مینول'}", style: const TextStyle(fontSize: 12)),
                          
                          if (request['isBuyStockMode'] != true) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "مارکیٹ تصدیق شدہ نقد قیمت درج کریں",
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),
                          Text("پیکج: ${request['packageName'] ?? 'N/A'} | ماہانہ قسط: ${request['monthlyInstallment'] ?? '0'} روپے", style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 3),
                          Text("نقد قیمت: ${request['cashPrice'] ?? '0'} روپے", style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 3),
                          Text("ایڈوانس: ${request['advanceAmount'] ?? '0'} روپے", style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 3),
                          Text("کل ادھار قیمت: ${request['totalPrice'] ?? '0'} روپے", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                  if (request['hasGuarantor'] == true) ...[
                    const SizedBox(height: 12),
                    const Text("■ ضامن کی معلومات", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.person_outline, size: 25, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${request['guarantorName']} (والد: ${request['guarantorFatherName']}) | قوم: ${request['guarantorCaste']} | رشتہ: ${request['guarantorRelationship']}", 
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => controller.makePhoneCall(request['guarantorPhone']),
                                  child: Text("فون: ${request['guarantorPhone']} 📞", style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 3),
                                Text("شناختی کارڈ: ${request['guarantorCnic']}", style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 3),
                                Text("پتہ: ${request['guarantorAddress']}", style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  // --- چاروں فائنل ایکشن بٹنز ---
                  CardActionButtons(
                    controller: controller,
                    hiveKey: reqId,
                    isPurchase: hasMobilePackage,
                    request: request,
                  ),

                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}