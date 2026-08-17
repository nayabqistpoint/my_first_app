import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeclarationHelper {
  // 🎯 اردو الٹے الفاظ کو درست جوڑنے کا فنکشن
  static String _fixUrdu(String text) {
    if (text.trim().isEmpty) return text;
    return ArabicReshaper().reshape(text);
  }

  static Future<void> generateAndPrintPdf({
    required Map<String, dynamic> requestData,
    required String phone,
  }) async {
    try {
      final pdf = pw.Document();

      // ۱۔ فونٹس
      final ttfFont = await PdfGoogleFonts.amiriRegular();
      final ttfFontBold = await PdfGoogleFonts.amiriBold();

      // ۲۔ لائیو تاریخ
      DateTime now = DateTime.now();
      String liveDateStr = "${now.day}/${now.month}/${now.year}";

      // ۳۔ Hive Boxes
      var customerBox = Hive.box('customerbox');
      var packageBox = Hive.box('packagebox');

      dynamic customerData = customerBox.get(phone) ?? requestData;
      dynamic packageData = packageBox.get(phone) ?? requestData;

      // ۴۔ ڈیٹا کیز
      String applicantName = customerData['customerName'] ?? customerData['name'] ?? customerData['applicantName'] ?? 'غیر موجود';
      String fatherOrHusbandName = customerData['customerFatherName'] ?? customerData['fatherName'] ?? customerData['fatherOrHusbandName'] ?? 'غیر موجود';
      String currentAddress = customerData['customerAddress'] ?? customerData['address'] ?? customerData['currentAddress'] ?? 'غیر موجود';
      String cnicNumber = customerData['customerCnic'] ?? customerData['cnic'] ?? customerData['cnicNumber'] ?? 'غیر موجود';

      String mobileName = packageData['mobileName'] ?? packageData['itemName'] ?? 'غیر موجود';

      // ۵۔ پی ڈی ایف پیج
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(22),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🎯 ۱۔ ای اسٹامپ کے لوگو اور بارکوڈ کے لیے زیادہ کھلی جگہ (4.5 Inches Top Gap)
                  pw.SizedBox(height: 230),

                  // 🎯 ۲۔ عنوان
                  pw.Center(
                    child: pw.Text(_fixUrdu('بیانِ حلفی (خریدار)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13)),
                  ),
                  pw.SizedBox(height: 6),

                  // 🎯 ۳۔ خریدار کی تفصیلات
                  pw.Text(_fixUrdu('منکہ مسمٰی/مسماۃ: $applicantName  ولدیت/زوجیت: $fatherOrHusbandName'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.2)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('سکنہ: $currentAddress  شناختی کارڈ نمبر: $cnicNumber'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.2)),

                  pw.SizedBox(height: 5),
                  pw.Text(_fixUrdu('حلفاً اقرار کرتا/کرتی ہوں کہ:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 9.5)),
                  pw.Text(_fixUrdu('نایاب قسط پوائنٹ (زیرِ ملکیت محمد ڈیری رجسٹرڈ) کو آئندہ صرف "ادارہ" تسلیم کیا جائے گا۔'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 8.2)),
                  pw.Divider(thickness: 0.5),

                  // 🎯 ۴۔ تمام شقیں (مناسب اور خوبصورت فاصلے کے ساتھ)
                  _buildParagraph('1. ', 'میں نے مطلوبہ اثاثہ/موبائل بالکل ٹھیک حالت میں خود چیک کر کے حاصل کیا ہے، لہذا بعد میں کسی دفتری نقص یا خرابی کا عذر قابلِ قبول نہ ہوگا۔ نیز، موبائل کی وصولی کے وقت میری بنائی گئی آڈیو/ویڈیو ریکارڈنگ اور بائیومیٹرک تصدیق میری اپنی مرضی سے ہے، جسے ادارہ بوقتِ ضرورت پیش کرنے کا مجاز ہے۔', ttfFont),
                  _buildParagraph('2. ', 'میں اقرار کرتا ہوں کہ قسطوں پر حاصل کردہ موبائل فون، یا کسی دیگر الیکٹرانکس اشیاء کی ضمانت کے طور پر رکھوائے گئے ذاتی موبائل فون $mobileName کا اصل ڈبہ (Box) ادارے کے پاس بطورِ گروی رہے گا۔ میں اعتراف کرتا ہوں کہ مذکورہ موبائل فون میں ادارے کی بلاکنگ ایپ اور ایڈمن پرمیشنز (Admin Rights) میری رضامندی سے فعال کی گئی ہیں۔ قسط لیٹ ہونے پر ادارے کو موبائل آن لائن بلاک کرنے کا پورا قانونی حق حاصل ہے اور بلاکنگ کے دوران بھی اقساط کا شیڈول اور نادہندگی کا وقت برابر جاری رہے گا۔', ttfFont),
                  _buildParagraph('3. ', 'میں اقرار کرتا ہوں کہ اگر میرے ذمے ایک سے زائد اقساط واجب الادا ہو گئیں، تو ادارہ صرف ایک قسط (جزوی ادائیگی) لینے سے انکار کا پورا حق رکھتا ہے، اور ایک قسط دینے سے میرا پرانا ڈیفالٹ یا نادہندگی کا وقت معاف نہیں ہوگا۔', ttfFont),
                  _buildParagraph('4. ', 'میں سیلز ایگریمنٹ کی تمام شقوں بشمول شق ۲، ۳، ۵ اور ۶ (موبائل بلاکنگ ٹائم لائن، حلولِ اقساط کے تحت یکمشت بقایا قرض کی ادائیگی، ثالثی پینل کا فیصلہ, اور عدم تعمیل کی صورت میں تمام معقول و رسید شدہ قانونی و عدالتی اخراجات کی میرے کھاتے میں ایڈجسٹمنٹ) کو اچھی طرح پڑھ اور سمجھ کر تسلیم کرتا ہوں اور ان کا بلا عذر پابند رہنے کا عہد کرتا ہوں ۔', ttfFont),
                  _buildParagraph('5. ', 'مسلسل ۲ اقساط کی نادہندگی پر پیدا ہونے والی یکمشت بقایا لائبلٹی (قرض) کی ضمانت و ادائیگی کے لیے جو سیکیورٹی چیک یا پرا نوٹ میں نے دیا ہے، میں ادارہ کو The Negotiable instruments Act کی دفعہ 20 کے تحت یہ اختیار دیتا ہوں کہ وہ بوقوعِ ڈیفالٹ اس پر اصل واجب الادا رقم خود پُر کر سکے۔ چیک ڈس آنر ہونے پر ادارہ میرے خلاف فوری فوجداری کارروائی (F.I.R زیرِ دفعہ 489-F) اور پرا نوٹ پر قانونی دعویٰ دائر کرنے کا مکمل حق رکھتا ہے۔', ttfFont),
                  _buildParagraph('6. ', 'میں حلفاً اقرار کرتا ہوں کہ میرا فراہم کردہ رہائشی پتہ اور موبائل نمبر بالکل درست ہیں۔ اس نمبر پر بھیجا گیا کوئی بھی ڈیجیٹل نوٹس/میسج یا پتے پر بھیجی گئی ڈاک مجھے موصول شدہ تصور ہوگی۔ نیز، قسط کی ادائیگی کا واحد قانونی ثبوت صرف ادارے کے آفیشل نمبر (03231988351) سے جاری کردہ "ڈیجیٹل رسید" ہوگی، اس کے علاوہ ہر قسم کا زبانی یا غیر سرکاری دعویٰ باطل سمجھا جائے گا۔', ttfFont),

                  pw.Spacer(),

                  // 🎯 ۵۔ دستخط مقر اور تاریخ
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط/انگوٹھا مقر: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8.5)),
                      pw.Text(_fixUrdu('تاریخ: $liveDateStr'), style: pw.TextStyle(font: ttfFont, fontSize: 8.5)),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  // 🎯 ۶۔ گواہان
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('گواہ نمبر 1 (نام و شناختی کارڈ): _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                      pw.Text(_fixUrdu('دستخط: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('گواہ نمبر 2 (نام و شناختی کارڈ): _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                      pw.Text(_fixUrdu('دستخط: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8)),
                    ],
                  ),

                  pw.SizedBox(height: 5),
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
      developer.log('Declaration PDF Generation Error', error: e, stackTrace: stackTrace);
    }
  }

  static pw.Widget _buildParagraph(String prefix, String text, pw.Font fontRegular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: prefix,
              style: pw.TextStyle(font: fontRegular, fontSize: 8.2, color: PdfColors.black),
            ),
            pw.TextSpan(
              text: _fixUrdu(text),
              style: pw.TextStyle(font: fontRegular, fontSize: 8.0),
            ),
          ],
        ),
      ),
    );
  }
}