import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsBlock extends StatefulWidget {
  final Function(bool isAccepted)? onTermsChanged;

  const TermsBlock({super.key, this.onTermsChanged});

  @override
  State<TermsBlock> createState() => TermsBlockState();
}

class TermsBlockState extends State<TermsBlock> {
  static const String termsText = '''
میں ہوش و حواس میں اقرار کرتا/کرتی ہوں کہ میں یہ موبائل قسطوں پر لے رہا/رہی ہوں. تمام درج کردہ کوائف بشمول نام، ولدیت اور قوم سو فیصد درست ہیں. میں بروقت ماہانہ قسط ادا کرنے کا مکمل پابند ہوں. کسی بھی تنازع یا خلاف ورزی کی صورت میں معاملہ عدالت جانے کے بجائے ہمارے پہلے سے طے شدہ ثالثوں کے بورڈ کے سامنے پیش کیا جائے گا، اور ثالثی ایکٹ کے تحت فیصلہ صادر ہوگا. تمام شرائط و ضوابط مجھ پر لازم ہوں گے. (براہ کرم اس عبارت کو آخر تک اسکرول کریں)
''';

  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 10) {
      if (!_isScrolledToBottom) {
        setState(() {
          _isScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'براہ کرم درج ذیل بیان حلفی اور شرائط کو آخر تک پڑھیں:',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // سکرول ایبل ٹیکسٹ باکس
            Container(
              height: 120,
              padding: const EdgeInsets.all(8), // درست کر دیا گیا ہے
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: const Text(
                      termsText,
                      style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: _isScrolledToBottom
                      ? (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                            if (widget.onTermsChanged != null) {
                              widget.onTermsChanged!(_isChecked);
                            }
                          });
                        }
                      : null,
                ),
                const Expanded(
                  child: Text(
                    'میں نے شرائط پڑھ لی ہیں اور ان سے متفق ہوں',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            if (!_isScrolledToBottom)
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Text(
                  '*(چیک باکس کھولنے کے لیے اوپر دی گئی تحریر کو مکمل آخر تک اسکرول کریں)*',
                  style: TextStyle(fontSize: 9, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}