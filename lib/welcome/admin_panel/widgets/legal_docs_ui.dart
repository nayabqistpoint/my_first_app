import 'package:flutter/material.dart';
import 'legal_docs_controller.dart';
import 'agreement_helper.dart'; // 🎯 معاہدہ ہیلپر فائل امپورٹ ہو گئی

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleHandover() async {
    bool success = await _controller.completeHandover(widget.phone);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('موبائل کامیابی سے تحویل میں دے دیا گیا ہے!'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.onStateChanged != null) widget.onStateChanged!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خرابی: ہینڈ اوور مکمل نہیں ہو سکا!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
            // 🎯 عنوان
            Row(
              children: [
                Icon(Icons.gavel_rounded, color: Colors.blue.shade800, size: 22),
                const SizedBox(width: 8),
                Text(
                  'قانونی دستاویزات اور تحویل کا عمل',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 🎯 1. پرنٹنگ بٹنز (معاہدہ اقساط کنیکٹ ہو گیا)
            const Text('1. ضروری دستاویزات جنریٹ کریں:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildPdfButton(
                    icon: Icons.description,
                    label: 'معاہدہ اقساط',
                    color: Colors.indigo.shade700,
                    onPressed: () {
                      // 🎯 کلک کرنے پر پی ڈی ایف جنریٹ ہو گا
                      AgreementHelper.generateAndPrintPdf(
                        requestData: widget.requestData,
                        phone: widget.phone,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildPdfButton(
                    icon: Icons.assignment_ind,
                    label: 'ضمانت نامہ',
                    color: Colors.teal.shade700,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildPdfButton(
                    icon: Icons.verified_user,
                    label: 'بیان حلفی',
                    color: Colors.deepOrange.shade700,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 🎯 2. فزیکل سکیورٹیز کی تصدیق
            const Text('2. تحویل سے پہلے فزیکل وصولی کی تصدیق:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            _buildCheckboxTile('شناختی کارڈ کاپیاں (کسٹمر و ضامن) موصول ہو گئی ہیں (لازمی)', _controller.isCnicReceived, (v) => setState(() => _controller.isCnicReceived = v ?? false)),
            _buildCheckboxTile('کاغذات پر کسٹمر اور ضامن کے دستخط مکمل ہیں (لازمی)', _controller.isDocsSigned, (v) => setState(() => _controller.isDocsSigned = v ?? false)),
            _buildCheckboxTile('ایڈوانس رقم موصول ہو گئی ہے (اگر پیکیج میں شامل ہے)', _controller.isAdvanceReceived, (v) => setState(() => _controller.isAdvanceReceived = v ?? false)),
            _buildCheckboxTile('موبائل کا اصل ڈبہ بطور سکیورٹی موصول ہو گیا ہے', _controller.isBoxReceived, (v) => setState(() => _controller.isBoxReceived = v ?? false)),
            _buildCheckboxTile('فزیکل اسٹامپ پیپر و پرنوٹ موصول ہو گئے ہیں', _controller.isStampReceived, (v) => setState(() => _controller.isStampReceived = v ?? false)),
            _buildCheckboxTile('فزیکل بینک چیکس موصول ہو گئے ہیں (اگر پیکیج میں شامل ہے)', _controller.isChequesReceived, (v) => setState(() => _controller.isChequesReceived = v ?? false)),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 🎯 3. تصویر اور ڈسکرپشن
            const Text('3. تحویل کی تصویر اور اضافی تفصیلات:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text('تصویر بنائیں', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller.remarksController,
                    decoration: InputDecoration(
                      hintText: 'تحویل سے متعلق نوٹس / تفصیلات درج کریں...',
                      hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🎯 4. فائنل ہینڈ اوور بٹن
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _controller.isReadyForHandover ? _handleHandover : null,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'موبائل کسٹمر کے حوالے کریں اور اکاؤنٹ مکمل کریں',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      activeColor: Colors.green.shade700,
      title: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}