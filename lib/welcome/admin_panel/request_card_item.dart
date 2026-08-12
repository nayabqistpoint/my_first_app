import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/card_action_buttons.dart';
import 'widgets/customer_info_widget.dart';
import 'widgets/guarantor_info_widget.dart';
import 'widgets/request_card_helper.dart';

class RequestCardItem extends StatefulWidget {
  final Map<String, dynamic>? requestData;
  final dynamic request;
  final dynamic controller;
  final VoidCallback? onStateChanged;

  const RequestCardItem({
    super.key,
    this.requestData,
    this.request,
    this.controller,
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
              // رو 1: آئیکن + کسٹمر کا نام/ولدیت/قوم + فون + کیپسول + ایرو
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

              // رو 2: ابھرا ہوا ایڈیٹیبل قیمت کا باکس اور IMEI
              RequestCardHelper.buildPackageAndImeiRow(
                context: context,
                data: data,
                phone: phone,
                priceController: _priceController,
              ),

              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                CustomerInfoWidget(customerData: {'customerPhone': phone, ...data}),
                const SizedBox(height: 10),
                GuarantorInfoWidget(guarantorData: {'customerPhone': phone, ...data}),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 10),

              // 🎯 4. کارڈ ایکشن بٹنز (درست امپورٹ کے ساتھ)
              CardActionButtons(
                requestData: {'customerPhone': phone, ...data},
                controller: widget.controller,
                priceController: _priceController,
                onStateChanged: widget.onStateChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}