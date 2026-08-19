import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'pay_now_controller.dart';

class PayNowBody extends StatefulWidget {
  const PayNowBody({super.key});

  @override
  State<PayNowBody> createState() => _PayNowBodyState();
}

class _PayNowBodyState extends State<PayNowBody> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasAudio = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  // اصلی مائیک سے ریکارڈنگ کنٹرول کرنے کا فنکشن
  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        if (path != null) {
          setState(() {
            _isRecording = false;
            _hasAudio = true;
          });
          // کنٹرولر کے اندر اصل پاتھ سیٹ ہو جائے گا
          payNowController.audioPath = path; 
        }
      } else {
        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: '',
          );
          setState(() {
            _isRecording = true;
            _hasAudio = false;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isRecording ? Colors.green : (_hasAudio ? Colors.green.shade400 : Colors.grey.shade400),
        ),
        borderRadius: BorderRadius.circular(10),
        color: _isRecording ? Colors.green.shade50 : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // بائیں طرف مدھم انسٹرکشنز اور ٹائٹل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRecording ? "ریکارڈنگ ہو رہی ہے..." : (_hasAudio ? "آڈیو ریکارڈ ہو گئی ہے" : "آڈیو ریکارڈنگ (اختیاری)"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _isRecording ? Colors.green[800] : (_hasAudio ? Colors.green[700] : Colors.black),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "اپنا نام، کل بقایا رقم اور ماہانہ قسط زبانی ریکارڈ کروائیں۔",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // دائیں طرف مائیک کا بٹن
          IconButton(
            onPressed: _toggleRecording,
            icon: Icon(
              _isRecording ? Icons.stop : (_hasAudio ? Icons.check_circle : Icons.mic),
              color: _isRecording ? Colors.green : (_hasAudio ? Colors.green : Colors.red),
            ),
            tooltip: _isRecording ? "ریکارڈنگ روکیں" : "آڈیو ریکارڈ کریں",
          ),
        ],
      ),
    );
  }
}