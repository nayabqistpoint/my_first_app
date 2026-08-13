import 'package:flutter/material.dart';
import '../../welcome/signup/item_package_ui.dart';
import 'purchase_now_controller.dart';

class PurchaseNow extends StatefulWidget {
  final String customerMobileNumber;

  const PurchaseNow({
    super.key,
    required this.customerMobileNumber,
  });

  @override
  State<PurchaseNow> createState() => _PurchaseNowState();
}

class _PurchaseNowState extends State<PurchaseNow> {
  final PurchaseNowController _controller = PurchaseNowController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // پیج کھلتے ہی سوئچ کو خودکار طور پر ON کر دیا جائے گا تاکہ ڈیٹا مس نہ ہو
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.packageKey.currentState?.setPurchaseRequested(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "خریداری کی درخواست",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      // پیکج یو آئی کو کنٹرولر کی کی کے ساتھ جوڑنا
      body: SingleChildScrollView(
        child: ItemPackageUI(key: _controller.packageKey),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (widget.customerMobileNumber.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("خامی: کسٹمر کا موبائل نمبر غائب ہے!"),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      // کنٹرولر کے ذریعے کسٹمر کے موبائل نمبر کو بطور کلید استعمال کرتے ہوئے ڈیٹا سیو کرنا
                      await _controller.submitPurchaseRequest(
                        customerMobileNumber: widget.customerMobileNumber,
                        onSuccess: () {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop(true);
                          }
                        },
                        onError: (errorMsg) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMsg)),
                            );
                          }
                        },
                      );
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "سبمٹ کریں",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}