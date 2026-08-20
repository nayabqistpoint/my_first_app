import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'legal_docs_controller.dart';
import 'agreement_helper.dart';
import 'guarantor_helper.dart';
import 'declaration_helper.dart';
import 'invoice_helper.dart';

class LegalDocsUI extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String phone;
  final VoidCallback? onStateChanged;

  const LegalDocsUI({
    super.key,
    required this.requestData,
    required this.phone,
    this.onStateChanged,
  });

  @override
  State<LegalDocsUI> createState() => _LegalDocsUIState();
}

class _LegalDocsUIState extends State<LegalDocsUI> {
  final LegalDocsController _controller = LegalDocsController();
  Uint8List? _stampBytes;
  String? _stampExtension;
  bool _isInvoiceGenerated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🎯 file_picker 12.0.0 کے مطابق ۱۰۰٪ ایرر فری فنکشن
  Future<void> _pickStamp() async {
    try {
      final List<PlatformFile> selectedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (selectedFiles.isNotEmpty) {
        final PlatformFile file = selectedFiles.first;
        final Uint8List bytes = await file.readAsBytes(); // Non-nullable fixed

        setState(() {
          _stampBytes = bytes;
          // extension کی جگہ نام سے فائل کی ایکسٹینشن حاصل کرنا
          _stampExtension = file.name.contains('.') 
              ? file.name.split('.').last 
              : 'jpg';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ای اسٹامپ تصویر اپ لوڈ ہو گئی!'), 
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تصویر منتخب کرنے میں مسئلہ آیا: $e'), 
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleInvoicePrint() async {
    setState(() {
      _isInvoiceGenerated = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فروخت رسید (انوائس) جنریٹ ہو رہی ہے...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    await InvoiceHelper.generateAndPrintPdf(
      requestData: widget.requestData,
      phone: widget.phone,
    );
  }

  Future<void> _handleHandover() async {
    bool ok = await _controller.completeHandover(widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'موبائل تحویل میں دے دیا گیا!' : 'خرابی: ہینڈ اوور نہیں ہو سکا!'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok && widget.onStateChanged != null) widget.onStateChanged!();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: Colors.blue.shade800, size: 18),
                      const SizedBox(width: 4),
                      Text('قانونی دستاویزات',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: _handleInvoicePrint,
                        child: Row(
                          children: [
                            Icon(
                              _isInvoiceGenerated ? Icons.check_circle : Icons.receipt_long,
                              size: 13,
                              color: _isInvoiceGenerated ? Colors.green : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _isInvoiceGenerated ? 'انوائس (اوکے)' : 'انوائس',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isInvoiceGenerated ? Colors.green.shade800 : Colors.blue.shade700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _pickStamp,
                        child: Row(
                          children: [
                            Icon(
                              _stampBytes != null ? Icons.check_circle : Icons.upload_file,
                              size: 13,
                              color: _stampBytes != null ? Colors.green : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _stampBytes != null ? 'اسٹامپ اپ لوڈڈ' : 'ای اسٹامپ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _stampBytes != null ? Colors.green.shade800 : Colors.blue.shade700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),
              const Text('1. ضروری دستاویزات جنریٹ کریں:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _btn(
                      label: 'معاہدہ اقساط',
                      color: Colors.indigo.shade700,
                      onPressed: () => AgreementHelper.generateAndPrintPdf(requestData: widget.requestData, phone: widget.phone),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _btn(
                      label: 'ضمانت نامہ',
                      color: Colors.teal.shade700,
                      onPressed: () => GuarantorHelper.generateAndPrintPdf(requestData: widget.requestData, phone: widget.phone),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _btn(
                      label: 'بیان حلفی',
                      color: Colors.deepOrange.shade700,
                      onPressed: () {
                        DeclarationHelper.generateAndPrintPdf(
                          requestData: widget.requestData,
                          phone: widget.phone,
                          stampBytes: _stampBytes,
                          fileExtension: _stampExtension,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              const Text('2. تحویل سے پہلے فزیکل وصولی کی تصدیق:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              _chk('شناختی کارڈ کاپیاں (لازمی)', _controller.isCnicReceived, (v) => setState(() => _controller.isCnicReceived = v ?? false)),
              _chk('کاغذات پر دستخط مکمل ہیں (لازمی)', _controller.isDocsSigned, (v) => setState(() => _controller.isDocsSigned = v ?? false)),
              _chk('ایڈوانس رقم موصول ہو گئی', _controller.isAdvanceReceived, (v) => setState(() => _controller.isAdvanceReceived = v ?? false)),
              _chk('موبائل کا اصل ڈبہ موصول ہو گیا', _controller.isBoxReceived, (v) => setState(() => _controller.isBoxReceived = v ?? false)),
              _chk('فزیکل اسٹامپ پیپر و پرنوٹ موصول ہو گئے', _controller.isStampReceived, (v) => setState(() => _controller.isStampReceived = v ?? false)),
              _chk('فزیکل بینک چیکس موصول ہو گئے', _controller.isChequesReceived, (v) => setState(() => _controller.isChequesReceived = v ?? false)),
              const Divider(height: 16),
              const Text('3. تحویل کی تصویر اور اضافی تفصیلات:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, size: 14),
                    label: const Text('تصویر', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _controller.remarksController,
                      decoration: const InputDecoration(
                        hintText: 'نوٹس درج کریں...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controller.isReadyForHandover ? _handleHandover : null,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('موبائل کسٹمر کے حوالے کریں اور اکاؤنٹ مکمل کریں',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _chk(String title, bool val, ValueChanged<bool?> onChanged) {
    return Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        activeColor: Colors.green.shade700,
        title: Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
        value: val,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}