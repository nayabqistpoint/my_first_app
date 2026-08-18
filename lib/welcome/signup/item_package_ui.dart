import 'package:flutter/material.dart';
import 'package:my_first_app/installment_calculater_page.dart';
import 'package:record/record.dart'; // اصلی آڈیو ریکارڈنگ پیکیج
import 'item_package_logic.dart';

// ری یوزیبل IMEI ڈائیلاگ کی امپورٹ
import 'package:my_first_app/features/imei_details_dialog.dart';

class ItemPackageUI extends StatefulWidget {
  const ItemPackageUI({super.key});

  @override
  State<ItemPackageUI> createState() => ItemPackageUIState();
}

class ItemPackageUIState extends State<ItemPackageUI> with AutomaticKeepAliveClientMixin {
  late final ItemPackageLogic _logic;
  bool _isPurchaseRequested = false;
  
  // آڈیو ریکارڈنگ سے متعلقہ اسٹیٹس
  bool _isRecording = false;
  bool _hasRecordedAudio = false;
  String? _audioPath;

  // اصلی آڈیو ریکارڈر کا ابجیکٹ
  final AudioRecorder _audioRecorder = AudioRecorder();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logic = ItemPackageLogic();
  }

  @override
  void dispose() {
    _audioRecorder.dispose(); // میموری لیک سے بچنے کے لیے ریکارڈر ڈسپوز
    super.dispose();
  }

  /// باہر سے یا سائن ان / پرچیز پیج سے سوئچ فورس آن کرنے کا ہیلپر
  void setPurchaseRequested(bool value) {
    if (mounted) {
      setState(() {
        _isPurchaseRequested = value;
      });
    }
  }

  Map<String, dynamic> getPackageData() {
    if (!_isPurchaseRequested) {
      return {'isPurchaseRequested': false};
    }
    return {
      'isPurchaseRequested': true,
      'hasAudioRecorded': _hasRecordedAudio,
      'audioPath': _audioPath,
      ..._logic.getPackageData(),
    };
  }

  void _openCalculator(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallmentCalculaterPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _logic.updatePackageData(
          name: result['mobileName'] ?? '',
          pkgName: result['packageName'] ?? '',
          cash: result['cashPrice'] ?? '',
          advance: result['advanceAmount'] ?? '',
          installment: result['monthlyInstallment'] ?? '',
          total: result['totalPrice'] ?? '',
          buyStock: result['isBuyStockMode'] ?? false,
          stockImei: result['imei'],
          chqNumber: result['checkNumber'],
          bnkName: result['bankName'],
        );
      });
    }
  }

  // اصلی مائیک سے ریکارڈنگ شروع یا بند کرنے کا فنکشن
  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // ریکارڈنگ روکیں اور فائل کا پاتھ حاصل کریں
        final path = await _audioRecorder.stop();
        if (path != null) {
          setState(() {
            _isRecording = false;
            _hasRecordedAudio = true;
            _audioPath = path; // یہاں اصلی ریکارڈیڈ فائل کا سچا پاتھ آئے گا
          });
        }
      } else {
        // مائیکرو فون کی اجازت چیک کریں
        if (await _audioRecorder.hasPermission()) {
          // ریکارڈنگ شروع کریں
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc), 
            path: '', // خالی چھوڑنے سے یہ خود ہی بہترین ٹیمپریری پاتھ بنا لیتا ہے
          );
          setState(() {
            _isRecording = true;
            _hasRecordedAudio = false;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('آڈیو ریکارڈنگ کے لیے مائیک کی اجازت درکار ہے')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ریکارڈنگ میں مسئلہ آیا: $e')),
        );
      }
    }
  }

  // --- ڈائنامک IMEI / نقد قیمت باکس ---
  Widget _buildDynamicPriceOrImeiBox({required bool hasImei, required String cashPrice, required String? imei}) {
    if (hasImei && imei != null) {
      // اگر اسٹاک سے آئے تو نقد قیمت کی جگہ IMEI کا ہائپر لنک نظر آئے گا
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('IMEI نمبر:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
            Flexible(
              child: InkWell(
                onTap: () => showImeiDetailsDialog(context, imei),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 12, color: Colors.blue),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        imei,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // اگر مینول آئے تو نقد قیمت کا باکس ظاہر ہوگا
      return _buildBox('نقد قیمت:', cashPrice.isEmpty ? '0' : cashPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final String modelName = _logic.mobileName ?? '';
    final String packageName = _logic.packageName ?? '';
    final String cashPrice = _logic.cashPrice ?? '';
    final String advanceAmount = _logic.advanceAmount ?? '';
    final String monthlyInstallment = _logic.monthlyInstallment ?? '';
    final String totalPrice = _logic.totalPrice ?? '';
    
    final String? imei = _logic.imei;
    final String? checkNumber = _logic.checkNumber;
    final String? bankName = _logic.bankName;

    bool hasImei = (imei != null && imei.isNotEmpty);
    bool hasCheckOrBank = (checkNumber != null && checkNumber.isNotEmpty) || (bankName != null && bankName.isNotEmpty);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آئٹم اور پیکج کی معلومات',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Row(
                  children: [
                    const Text('پرچیز ریکویسٹ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _isPurchaseRequested,
                      activeThumbColor: Colors.red[800],
                      onChanged: (value) {
                        setState(() {
                          _isPurchaseRequested = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            if (_isPurchaseRequested) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ElevatedButton.icon(
                  onPressed: () => _openCalculator(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.calculate, size: 14),
                  label: const Text('قسط کیلکولیٹر کھولیں', style: TextStyle(fontSize: 10)),
                ),
              ),
              const SizedBox(height: 8),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildBox('ماڈل:', modelName == 'N/A' || modelName.isEmpty ? 'منتخب کریں' : modelName)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('پیکج:', packageName == 'N/A' || packageName.isEmpty ? 'منتخب کریں' : packageName)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // نقد قیمت اور IMEI دونوں کے لیے ایک ہی ڈائنامک باکس
                      Expanded(
                        child: _buildDynamicPriceOrImeiBox(
                          hasImei: hasImei,
                          cashPrice: cashPrice,
                          imei: imei,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('ایڈوانس:', advanceAmount.isEmpty ? '0' : advanceAmount)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildBox('ماہانہ قسط:', monthlyInstallment.isEmpty ? '0' : monthlyInstallment)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('کل ادھار قیمت:', totalPrice.isEmpty ? '0' : totalPrice, isTotal: true)),
                    ],
                  ),
                  if (hasCheckOrBank) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (checkNumber != null && checkNumber.isNotEmpty)
                          Expanded(child: _buildBox('چیک نمبر:', checkNumber, isSpecial: true))
                        else
                          const Spacer(),
                        if (checkNumber != null && checkNumber.isNotEmpty && bankName != null && bankName.isNotEmpty) const SizedBox(width: 6),
                        if (bankName != null && bankName.isNotEmpty)
                          Expanded(child: _buildBox('بینک کا نام:', bankName, isSpecial: true))
                        else
                          const Spacer(),
                      ],
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(color: Colors.red, thickness: 1),
              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'قانونی تصدیق (لازمی آڈیو اعتراف):',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'موبائل ماڈل، ایڈوانس اور قسط کی رقم بول کر وائس ریکارڈ لازمی کریں تاکہ ریکوئسٹ جمع ہو سکے۔',
                      style: TextStyle(fontSize: 9, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording ? Colors.green : Colors.red[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic, size: 14),
                          label: Text(_isRecording ? 'ریکارڈنگ روکیں' : 'آڈیو ریکارڈ کریں', style: const TextStyle(fontSize: 10)),
                        ),
                        Row(
                          children: [
                            Icon(
                              _hasRecordedAudio ? Icons.check_circle : Icons.warning_amber_rounded,
                              size: 16,
                              color: _hasRecordedAudio ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hasRecordedAudio ? 'آڈیو محفوظ ہو گئی' : 'آڈیو درکار ہے',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _hasRecordedAudio ? Colors.green : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String label, String value, {bool isTotal = false, bool isSpecial = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isTotal ? Colors.red.shade50 : (isSpecial ? Colors.amber.shade50 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTotal ? Colors.red.shade200 : (isSpecial ? Colors.amber.shade300 : Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isTotal ? Colors.red[800] : (isSpecial ? Colors.brown.shade800 : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}