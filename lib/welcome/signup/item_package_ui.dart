import 'package:flutter/material.dart';
import 'package:my_first_app/installment_calculater_page.dart';
import 'item_package_logic.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logic = ItemPackageLogic();
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
          stockColor: result['color'],
          chqNumber: result['checkNumber'],
          bnkName: result['bankName'],
        );
      });
    }
  }

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _hasRecordedAudio = true;
        _audioPath = "audio_recorded_placeholder_path";
      } else {
        _isRecording = true;
        _hasRecordedAudio = false;
      }
    });
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
    final String? color = _logic.color;
    final String? checkNumber = _logic.checkNumber;
    final String? bankName = _logic.bankName;

    bool hasImeiOrColor = (imei != null && imei.isNotEmpty) || (color != null && color.isNotEmpty);
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
                  '3. آئٹم اور پیکج کی معلومات',
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
            
            // جب پرچیز ریکویسٹ آن ہو گی، تب ہی کیلکولیٹر، تفصیلات اور آڈیو سیکشن نظر آئے گا
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
                      Expanded(child: _buildBox('نقد قیمت:', cashPrice.isEmpty ? '0' : cashPrice)),
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
                  if (hasImeiOrColor) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (imei != null && imei.isNotEmpty)
                          Expanded(child: _buildBox('IMEI نمبر:', imei, isSpecial: true))
                        else
                          const Spacer(),
                        if (imei != null && imei.isNotEmpty && color != null && color.isNotEmpty) const SizedBox(width: 6),
                        if (color != null && color.isNotEmpty)
                          Expanded(child: _buildBox('کلر:', color, isSpecial: true))
                        else
                          const Spacer(),
                      ],
                    ),
                  ],
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

              // --- قانونی اعتراف کے لیے لازمی آڈیو ریکارڈنگ سیکشن (اب پرچیز سوئچ آن ہونے پر یہیں شو ہوگا) ---
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