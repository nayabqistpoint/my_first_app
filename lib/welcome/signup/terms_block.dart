import 'package:flutter/material.dart';

class TermsBlock extends StatefulWidget {
  final Function(bool isAccepted)? onTermsChanged;
  final bool initialValue;

  const TermsBlock({
    super.key, 
    this.onTermsChanged,
    this.initialValue = false,
  });

  @override
  State<TermsBlock> createState() => TermsBlockState();
}

// یہاں 'AutomaticKeepAliveClientMixin' کا اضافہ کیا گیا ہے
class TermsBlockState extends State<TermsBlock> with AutomaticKeepAliveClientMixin {
  static const String termsText = '''
میں ہوش و حواس میں اقرار کرتا/کرتی ہوں کہ میں یہ موبائل قسطوں پر لے رہا/رہی ہوں. تمام درج کردہ کوائف بشمول نام، ولدیت اور قوم سو فیصد درست ہیں۔ میں بروقت ماہانہ قسط ادا کرنے کا مکمل پابند ہوں۔ کسی بھی تنازع یا خلاف ورزی کی صورت میں معاملہ عدالت جانے کے بجائے ہمارے پہلے سے طے شدہ ثالثوں کے بورڈ کے سامنے پیش کیا جائے گا، اور ثالثی ایکٹ کے تحت فیصلہ صادر ہوگا۔ تمام شرائط و ضوابط مجھ پر لازم ہوں گے۔
''';

  final ScrollController _scrollController = ScrollController();
  late bool _isChecked;

  @override
  bool get wantKeepAlive => true; // ٹک کی حالت ہمیشہ زندہ رہے گی

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // لازمی ہے
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '4. اقرار نامہ اور ضابطہ اخلاق',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 6),
            const Text('براہ کرم درج ذیل بیان حلفی اور شرائط کا مطالعہ کریں:', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const Text(termsText, style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                      if (widget.onTermsChanged != null) {
                        widget.onTermsChanged!(_isChecked);
                      }
                    });
                  },
                ),
                const Expanded(
                  child: Text('میں نے شرائط پڑھ لی ہیں اور ان سے متفق ہوں', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}