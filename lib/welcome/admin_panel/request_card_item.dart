import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/card_action_buttons.dart';
import 'widgets/customer_info_widget.dart';
import 'widgets/guarantor_info_widget.dart';
import 'widgets/imei_controller_widget.dart';
import 'widgets/legal_docs_ui.dart';
import 'widgets/request_card_helper.dart';

class RequestCardItem extends StatefulWidget {
  final Map<String, dynamic>? requestData;
  final dynamic request;
  final dynamic controller;
  final bool isApprovedView;  // 🎯 منظور شدہ پیج کے لیے
  final bool isCompletedView; // 🎯 مکمل (Completed) ریڈ اونلی پیج کے لیے
  final VoidCallback? onStateChanged;

  const RequestCardItem({
    super.key,
    this.requestData,
    this.request,
    this.controller,
    this.isApprovedView = false,
    this.isCompletedView = false, // 👈 ڈیفالٹ میں false
    this.onStateChanged,
  });

  @override
  State<RequestCardItem> createState() => _RequestCardItemState();
}

class _RequestCardItemState extends State<RequestCardItem> {
  bool _isExpanded = false;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = widget.requestData ?? 
        (widget.request is Map<String, dynamic> ? widget.request : {});

    final String phone = (data['customerPhone'] ?? data['phone'] ?? '').toString().trim();

    // 🎯 IMEI کی موجودگی چیک کریں
    final String rawImei = (data['imei'] ?? 'N/A').toString().trim();
    final bool hasImei = rawImei.isNotEmpty && rawImei != 'N/A' && rawImei != 'null';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 رو 1: آئیکن + کسٹمر کا نام/ولدیت/قوم + فون + کیپسول + ایرو
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, color: Colors.grey, size: 38),
                  const SizedBox(width: 10),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RequestCardHelper.buildCustomerHeaderWidget(
                          data: data,
                          phone: phone,
                        ),
                        const SizedBox(height: 3),
                        
                        InkWell(
                          onTap: () => _makePhoneCall(phone),
                          child: Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  RequestCardHelper.buildTypeCapsuleWidget(
                    data: data,
                    phone: phone,
                  ),

                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.black54,
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 12),

              // 🎯 رو 2: موبائل ماڈل + پرائس باکس + IMEI
              RequestCardHelper.buildPackageAndImeiRow(
                context: context,
                data: data,
                phone: phone,
                priceController: _priceController,
              ),

              // 🎯 3. کولیپس ایبل کسٹمر اور ضامن کی معلومات
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                CustomerInfoWidget(customerData: {'customerPhone': phone, ...data}),
                const SizedBox(height: 10),
                GuarantorInfoWidget(guarantorData: {'customerPhone': phone, ...data}),
              ],

              // 🎯 4. مشروط ایکشن وزٹس (مکمل پیج پر ریڈ اونلی رہے گا)
              if (!widget.isCompletedView) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 10),

                if (widget.isApprovedView) ...[
                  // 🎯 اگر منظور شدہ سکرین ہے:
                  if (!hasImei)
                    // A. اگر IMEI نہیں ہے -> ImeiController دکھائیں
                    ImeiControllerWidget(
                      requestData: {'customerPhone': phone, ...data},
                      phone: phone,
                      onNavigateToPurchase: () {
                        // پرچیز سکرین پر فون نمبر پاس کر کے جانے کی لاجک
                      },
                    )
                  else
                    // B. اگر IMEI موجود ہے -> LegalDocsUI دکھائیں
                    LegalDocsUI(
                      requestData: {'customerPhone': phone, ...data},
                      phone: phone,
                      onStateChanged: widget.onStateChanged,
                    ),
                ] else
                  // 🎯 اگر پینڈنگ سکرین ہے -> واٹس ایپ ایکشن بٹنز
                  CardActionButtons(
                    requestData: {'customerPhone': phone, ...data},
                    request: widget.request,
                    controller: widget.controller,
                    hiveKey: phone,
                    isPurchase: false,
                    priceController: _priceController,
                    onStateChanged: widget.onStateChanged,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}