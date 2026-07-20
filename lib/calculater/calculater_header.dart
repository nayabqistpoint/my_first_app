import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CalculaterHeader extends StatelessWidget {
  const CalculaterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // سرخ ہیڈر پٹی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            color: const Color(0xFFE53935),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("قسط کیلکولیٹر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("نایاب قسط پوائنٹ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    autofocus: true, 
                    decoration: const InputDecoration(
                      hintText: "موبائل کی نقد رقم درج کریں",
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "ایڈوانس رقم درج کریں",
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // سوئچ اور جملہ - سوئچ کا رنگ بلیو کر دیا ہے
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "کیا آپ نے رعایت کے لیے سیکیورٹی چیک مہیا کیا ہے؟",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: false,
                      onChanged: (bool value) {},
                      activeTrackColor: Colors.blue.withValues(alpha: 0.5),
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),

                // رابطہ نمبر سیکشن
                InkWell(
                  onTap: () async {
                    final Uri launchUri = Uri(scheme: 'tel', path: '03012700351');
                    await launchUrl(launchUri);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "رابطہ: حافظ محمد صابر - 03012700351",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}