import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AgreementHelper {
  // 🎯 اردو الٹے الفاظ کو درست جوڑنے کا فنکشن
  static String _fixUrdu(String text) {
    if (text.trim().isEmpty) return text;
    return ArabicReshaper().reshape(text);
  }

  // 🎯 packageName (مثلاً 6A) سے صرف نمبرز نکالنے کا فنکشن
  static String _cleanNumbersOnly(dynamic value) {
    if (value == null) return '0';
    String str = value.toString();
    String cleaned = str.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
    return cleaned.isEmpty ? '0' : cleaned;
  }

  static Future<void> generateAndPrintPdf({
    required Map<String, dynamic> requestData,
    required String phone,
  }) async {
    try {
      final pdf = pw.Document();

      // ۱۔ آن لائن اردو فونٹس
      final ttfFont = await PdfGoogleFonts.amiriRegular();
      final ttfFontBold = await PdfGoogleFonts.amiriBold();

      // ۲۔ لائیو تاریخ (Live Date Stamp)
      DateTime now = DateTime.now();
      String liveDateStr = "${now.day}/${now.month}/${now.year}";

      // ۳۔ Hive Boxes کی ایکسس
      var customerBox = Hive.box('customerbox');
      var guarantorBox = Hive.box('guarantorbox');
      var packageBox = Hive.box('packagebox');

      dynamic customerData = customerBox.get(phone) ?? requestData;
      dynamic guarantorData = guarantorBox.get(phone) ?? requestData;
      dynamic packageData = packageBox.get(phone) ?? requestData;

      // ۴۔ ڈیٹا کیز (Customer & Guarantor Box)
      String customerName = customerData['customerName'] ?? customerData['name'] ?? 'غیر موجود';
      String customerCnic = customerData['customerCnic'] ?? customerData['cnic'] ?? 'غیر موجود';
      String customerFatherName = customerData['customerFatherName'] ?? customerData['fatherName'] ?? 'غیر موجود';
      String customerPhone = phone;

      String guarantorName = guarantorData['guarantorName'] ?? guarantorData['name'] ?? 'غیر موجود';
      String guarantorCnic = guarantorData['guarantorCnic'] ?? guarantorData['cnic'] ?? 'غیر موجود';

      // ۵۔ ڈیٹا کیز (Package Box)
      String mobileName = packageData['mobileName'] ?? packageData['itemName'] ?? 'غیر موجود';
      String totalPrice = packageData['totalPrice']?.toString() ?? '0';
      String advanceAmount = packageData['advanceAmount']?.toString() ?? packageData['advance']?.toString() ?? '0';
      String monthlyInstallment = packageData['monthlyInstallment']?.toString() ?? '0';
      
      dynamic rawPackageName = packageData['packageName'] ?? packageData['installmentsCount'];
      String packageName = _cleanNumbersOnly(rawPackageName);

      String checkNumber = packageData['checkNumber']?.toString() ?? packageData['chequeNo']?.toString() ?? '____________';
      String bankName = packageData['bankName']?.toString() ?? '____________';

      // ۶۔ پی ڈی ایف پیج
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🎯 Header (سلوگن کے ساتھ)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(_fixUrdu('نایاب قسط پوائنٹ'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13)),
                          pw.Text(_fixUrdu('(آپ کی سہولت, ہمارا عزم)'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                        ],
                      ),
                      pw.Text(_fixUrdu('زیر ملکیت: محمد ڈیری (رجسٹرڈ)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Divider(thickness: 1),
                  pw.Center(
                    child: pw.Text(_fixUrdu('(معاہدہ اقساط)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13)),
                  ),
                  pw.SizedBox(height: 6),

                  // فریقین کی تفصیلات
                  pw.Text(_fixUrdu('فریق اول (بائع): نایاب قسط پوائنٹ بذریعہ نگران اعلیٰ حافظ محمد صابر ولد محمد صادق'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('فریق دوم (خریدار): مسمٰی/مسماۃ: $customerName  شناختی کارڈ: $customerCnic'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('ولدیت: $customerFatherName موبائل نمبر: $customerPhone'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('ضامن: مسمٰی: $guarantorName شناختی کارڈ: $guarantorCnic'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),

                  pw.SizedBox(height: 5),
                  pw.Text(_fixUrdu('تفصیل اثاثہ, مالیات و سیکیورٹی:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.Divider(thickness: 0.5),

                  pw.Text(_fixUrdu('مطلوبہ اثاثہ و ماڈل: $mobileName'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('کل قیمت: $totalPrice ایڈوانس: $advanceAmount ماہانہ قسط: $monthlyInstallment اقساط کی تعداد: $packageName'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('سیکیورٹی چیک نمبر: $checkNumber بینک: $bankName'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),

                  pw.SizedBox(height: 5),
                  pw.Text(_fixUrdu('شرائط و دفعات معاہدہ:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.Divider(thickness: 0.5),

                  // 🎯 ۶ شرائط (بڑا سائز اور گہرا بولڈ)
                  _buildParagraph('1. ملکیت و رہن:', ' فریق اول نے اثاثہ فریق دوم کے فزیکل قبضے میں دے دیا ہے، جس کے بعد اس کے استعمال کی تمام تر سول و کریمینل ذمہ داری خریدار پر ہوگی۔ موبائل کا اصل ڈبہ (Box) اور سیکیورٹی چیک/پرونوٹ فریق اول کے پاس بطور "رہن" (گروی) محفوظ رہیں گے۔', ttfFont, ttfFontBold),
                  _buildParagraph('2. اقساط کا شیڈول و بلاکنگ (ٹائم لائن):', ' ماہانہ قسط ہر مہینے کی ۵ تاریخ تک واجب الادا ہے۔ قسط ادا نہ ہونے پر ۱۵ تاریخ کو موبائل آن لائن بلاک کر دیا جائے گا (بحالی فیس 1000 روپے ہوگی)۔ اگر نادہندگی برقرار رہی تو ۲۰ تاریخ کو کسٹمر کو ۱۰ دن کی مہلت کا لیگل نوٹس جاری کیا جائے گا۔', ttfFont, ttfFontBold),
                  _buildParagraph('3. حلول اقساط و یکمشت لائبلٹی:', ' مسلسل ۲ اقساط شارٹ ہونے پر کسٹمر کا حقِ قسط ختم ہو جائے گا اور کل بقایا رقم بوقوع ڈیفالٹ یکمشت واجب الادا قرض (Liability) بن جائے گی۔ ادارہ سیکیورٹی چیک/پرونوٹ میں ڈیجی کھاتا لیجر کے مطابق یہ کل رقم خود بھر کر کارروائی کرنے کا مجاز ہوگا۔', ttfFont, ttfFontBold),
                  _buildParagraph('4. تصفیہ و نقد واپسی:', ' ثالثی کارروائی شروع ہونے سے قبل، کسٹمر کو حق حاصل ہے کہ وہ ادارے کے بااعتماد ڈیلرز (عامر موبائلز قائم پور، نعیم موبائلز قائم پور، ناصر موبائلز حاصل پور) سے مارکیٹ ریٹ رسید لگوا کر موبائل واپس کرے اور بقیہ خسارہ نقد ادا کر کے کھاتا صاف کر لے۔', ttfFont, ttfFontBold),
                  _buildParagraph('5. ثالثی معاہدہ (Pre-Dispute Arbitration):', ' کسی بھی تنازع یا ۲ اقساط کی نادہندگی پر The Arbitration Act 1940 کی روشنی میں، دونوں فریقین کی رضامندی سے نیچے دیے گئے جدول میں سے کسی بھی ایک معزز شخص کو واحد ثالث (Sole Arbitrator) مقرر کیا جائے گا۔ کسٹمر کو لیگل نوٹس کے بعد متبادل نام تجویز کرنے یا اعتراض کا حق صرف ۱۰ دن تک بذریعہ دفتری رسید/ڈاک حاصل ہوگا۔ ثالث دونوں فریقین کو بلا کر، دکان کے ڈیجی کھاتا لیجر ریکارڈ اور اس معاہدے کی روشنی میں ۱۵ دن کے اندر اندر تحریری فیصلہ (Arbitral Award) دینے کا پابند ہوگا، جو فریقین پر حتمی اور لازم (Binding) ہوگا اور دیوانی عدالت سے ڈگری کروایا جا سکے گا۔', ttfFont, ttfFontBold),

                  pw.SizedBox(height: 4),

                  // 🎯 اردو RTL ٹیبل
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell(_fixUrdu('عہدہ / سماجی حیثیت'), ttfFontBold, isHeader: true),
                          _buildTableCell(_fixUrdu('نام ثالث (Arbitrator Name)'), ttfFontBold, isHeader: true),
                          _buildTableCell(_fixUrdu('نمبر شمار'), ttfFontBold, isHeader: true),
                        ],
                      ),
                      pw.TableRow(children: [
                        _buildTableCell(_fixUrdu('عالم دین، امام مسجد، تاجر'), ttfFont),
                        _buildTableCell(_fixUrdu('مولانا محمود صاحب'), ttfFont),
                        _buildTableCell('1', ttfFont),
                      ]),
                      pw.TableRow(children: [
                        _buildTableCell(_fixUrdu('ریٹائرڈ ہیڈ ماسٹر'), ttfFont),
                        _buildTableCell(_fixUrdu('ماسٹر جاوید'), ttfFont),
                        _buildTableCell('2', ttfFont),
                      ]),
                      pw.TableRow(children: [
                        _buildTableCell(_fixUrdu('سابقہ چیئرمین عشر زکوٰۃ کمیٹی'), ttfFont),
                        _buildTableCell(_fixUrdu('اشفاق مونڈ'), ttfFont),
                        _buildTableCell('3', ttfFont),
                      ]),
                      pw.TableRow(children: [
                        _buildTableCell(_fixUrdu('تاجر'), ttfFont),
                        _buildTableCell(_fixUrdu('صدام مونڈ'), ttfFont),
                        _buildTableCell('4', ttfFont),
                      ]),
                      pw.TableRow(children: [
                        _buildTableCell('', ttfFont),
                        _buildTableCell('', ttfFont),
                        _buildTableCell('5', ttfFont),
                      ]),
                    ],
                  ),

                  pw.SizedBox(height: 4),

                  _buildParagraph('6. ثالثی و عدالتی اخراجات:', ' معاہدے یا ثالثی فیصلے سے انحراف کرنے والا فریق، ثالثی کے آغاز سے لے کر عدالت سے ڈگری کرانے تک کے تمام قانونی و دفتری اخراجات ادا کرنے کا پابند ہوگا گے۔ نادہندگی کی صورت میں یہ اخراجات کسٹمر کے ذمے بقایا کھاتے میں شامل کیے جائیں گے۔', ttfFont, ttfFontBold),

                  pw.Spacer(), // فوٹر کو نچلے حصے پر سیٹ کرنے کے لیے

                  // ۳ دستخط
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط/انگوٹھا خریدار: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                      pw.Text(_fixUrdu('دستخط/انگوٹھا ضامن: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // نگران اعلیٰ دستخط اور لائیو تاریخ
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط نگران اعلیٰ (فریق اول): _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                      pw.Text(_fixUrdu('تاریخ: $liveDateStr'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                    ],
                  ),

                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 2),

                  // 🎯 نیا فوٹر (بغیر ڈیش کے فون نمبرز کے ساتھ)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('نگرانِ اعلیٰ: حافظ محمد صابر (03012700351)'), style: pw.TextStyle(font: ttfFont, fontSize: 7.5)),
                      pw.Text(_fixUrdu('ای میل: nayabsahulatcentre@gmail.com'), style: pw.TextStyle(font: ttfFont, fontSize: 7.5)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('آن لائن ادائیگی و واٹس ایپ: 03231988351 (راست/جیزکیش/ایزی پیسہ)'), style: pw.TextStyle(font: ttfFont, fontSize: 7.5)),
                      pw.Text(_fixUrdu('پتہ: ہیڈ اسلام روڈ، بستی محمد نگر، قائم پور'), style: pw.TextStyle(font: ttfFont, fontSize: 7.5)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e, stackTrace) {
      developer.log('PDF Generation Error', error: e, stackTrace: stackTrace);
    }
  }

  // 🎯 بڑا سائز (9.5pt) اور پرفیکٹ بولڈ ہیڈنگ ویجیٹ
  static pw.Widget _buildParagraph(String title, String text, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: _fixUrdu(title),
              style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.black),
            ),
            pw.TextSpan(
              text: _fixUrdu(text),
              style: pw.TextStyle(font: fontRegular, fontSize: 8.2),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: isHeader ? 8.5 : 8),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }
}