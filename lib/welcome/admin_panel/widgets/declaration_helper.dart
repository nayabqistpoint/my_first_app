import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeclarationHelper {
  static String _fixUrdu(String text) {
    if (text.trim().isEmpty) return text;
    return ArabicReshaper().reshape(text);
  }

  static Future<void> generateAndPrintPdf({
    required Map<String, dynamic> requestData,
    required String phone,
    Uint8List? stampBytes,
    String? fileExtension,
  }) async {
    try {
      final pdf = pw.Document();
      final ttfFontBold = await PdfGoogleFonts.amiriBold();

      DateTime now = DateTime.now();
      String liveDateStr = "${now.day}/${now.month}/${now.year}";

      var customerBox = Hive.box('customerbox');
      var packageBox = Hive.box('packagebox');

      dynamic customerData = customerBox.get(phone) ?? requestData;
      dynamic packageData = packageBox.get(phone) ?? requestData;

      String applicantName = customerData['customerName'] ?? customerData['name'] ?? customerData['applicantName'] ?? 'غیر موجود';
      String fatherOrHusbandName = customerData['customerFatherName'] ?? customerData['fatherName'] ?? customerData['fatherOrHusbandName'] ?? 'غیر موجود';
      String currentAddress = customerData['customerAddress'] ?? customerData['address'] ?? customerData['currentAddress'] ?? 'غیر موجود';
      String cnicNumber = customerData['customerCnic'] ?? customerData['cnic'] ?? customerData['cnicNumber'] ?? 'غیر موجود';
      String mobileName = packageData['mobileName'] ?? packageData['itemName'] ?? 'غیر موجود';

      pw.MemoryImage? stampBgImage;

      if (stampBytes != null && stampBytes.isNotEmpty) {
        try {
          stampBgImage = pw.MemoryImage(stampBytes);
        } catch (e) {
          developer.log('Stamp Image Load Error: $e');
          stampBgImage = null;
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🎯 1. ای اسٹامپ ہیڈر (آپ کی ہدایت کے مطابق 260 کی فکسڈ جگہ)
                  if (stampBgImage != null)
                    pw.Container(
                      height: 260,
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.ClipRect(
                        child: pw.Image(
                          stampBgImage,
                          fit: pw.BoxFit.cover,
                          alignment: pw.Alignment.topCenter,
                        ),
                      ),
                    )
                  else
                    pw.SizedBox(height: 260),

                  // 🎯 2. عنوان (اپنی جگہ بالکل فکس ہے)
                  pw.Center(
                    child: pw.Text(
                      _fixUrdu('بیانِ حلفی (خریدار)'),
                      style: pw.TextStyle(font: ttfFontBold, fontSize: 14.5, color: PdfColors.black),
                    ),
                  ),
                  pw.SizedBox(height: 4),

                  // 🎯 خریدار کی تفصیلات (اب ایک ہی روانی میں ۲ لائنوں میں کمپریس کر دی ہیں)
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: _fixUrdu('منکہ مسمٰی/مسماۃ: $applicantName  ولدیت/زوجیت: $fatherOrHusbandName  سکنہ: $currentAddress  شناختی کارڈ نمبر: $cnicNumber۔ '),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 10.0, color: PdfColors.black),
                        ),
                        pw.TextSpan(
                          text: _fixUrdu('حلفاً اقرار کرتا/کرتی ہوں کہ نایاب قسط پوائنٹ (زیرِ ملکیت محمد ڈیری رجسٹرڈ) کو آئندہ صرف "ادارہ" تسلیم کیا جائے گا۔'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 10.0, color: PdfColors.black),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Divider(thickness: 0.6, color: PdfColors.black),
                  pw.SizedBox(height: 3),

                  // 🎯 3. تمام اوریجنل ۶ شقیں (سائز بہترین اور واضح)
                  _buildParagraph('1. ', 'میں نے مطلوبہ اثاثہ/موبائل بالکل ٹھیک حالت میں خود چیک کر کے حاصل کیا ہے، لہذا بعد میں کسی دفتری نقص یا خرابی کا عذر قابلِ قبول نہ ہوگا۔ نیز، موبائل کی وصولی کے وقت میری بنائی گئی آڈیو/ویڈیو ریکارڈنگ اور بائیومیٹرک تصدیق میری اپنی مرضی سے ہے، جسے ادارہ بوقتِ ضرورت پیش کرنے کا مجاز ہے۔', ttfFontBold),
                  _buildParagraph('2. ', 'میں اقرار کرتا ہوں کہ قسطوں پر حاصل کردہ موبائل فون، یا کسی دیگر الیکٹرانکس اشیاء کی ضمانت کے طور پر رکھوائے گئے ذاتی موبائل فون $mobileName کا اصل ڈبہ (Box) ادارے کے پاس بطورِ گروی رہے گا۔ میں اعتراف کرتا ہوں کہ مذکورہ موبائل فون میں ادارے کی بلاکنگ ایپ اور ایڈمن پرمیشنز (Admin Rights) میری رضامندی سے فعال کی گئی ہیں۔ قسط لیٹ ہونے پر ادارے کو موبائل آن لائن بلاک کرنے کا پورا قانونی حق حاصل ہے اور بلاکنگ کے دوران بھی اقساط کا شیڈول اور نادہندگی کا وقت برابر جاری رہے گا۔', ttfFontBold),
                  _buildParagraph('3. ', 'میں اقرار کرتا ہوں کہ اگر میرے ذمے ایک سے زائد اقساط واجب الادا ہو گئیں، تو ادارہ صرف ایک قسط (جزوی ادائیگی) لینے سے انکار کا پورا حق رکھتا ہے، اور ایک قسط دینے سے میرا پرانا ڈیفالٹ یا نادہندگی کا وقت معاف نہیں ہوگا۔', ttfFontBold),
                  _buildParagraph('4. ', 'میں سیلز ایگریمنٹ کی تمام شقوں بشمول شق ۲، ۳، ۵ اور ۶ (موبائل بلاکنگ ٹائم لائن، حلولِ اقساط کے تحت یکمشت بقایا قرض کی ادائیگی، ثالثی پینل کا فیصلہ, اور عدم تعمیل کی صورت میں تمام معقول و رسید شدہ قانونی و عدالتی اخراجات کی میرے کھاتے میں ایڈجسٹمنٹ) کو اچھی طرح پڑھ اور سمجھ کر تسلیم کرتا ہوں اور ان کا بلا عذر پابند رہنے کا عہد کرتا ہوں ۔', ttfFontBold),
                  _buildParagraph('5. ', 'مسلسل ۲ اقساط کی نادہندگی پر پیدا ہونے والی یکمشت بقایا لائبلٹی (قرض) کی ضمانت و ادائیگی کے لیے جو سیکیورٹی چیک یا پرا نوٹ میں نے دیا ہے، میں ادارہ کو The Negotiable instruments Act کی دفعہ 20 کے تحت یہ اختیار دیتا ہوں کہ وہ بوقوعِ ڈیفالٹ اس پر اصل واجب الادا رقم خود پُر کر سکے۔ چیک ڈس آنر ہونے پر ادارہ میرے خلاف فوری فوجداری کارروائی (F.I.R زیرِ دفعہ 489-F) اور پرا نوٹ پر قانونی دعویٰ دائر کرنے کا مکمل حق رکھتا ہے۔', ttfFontBold),
                  _buildParagraph('6. ', 'میں حلفاً اقرار کرتا ہوں کہ میرا فراہم کردہ رہائشی پتہ اور موبائل نمبر بالکل درست ہیں۔ اس نمبر پر بھیجا گیا کوئی بھی ڈیجیٹل نوٹس/میسج یا پتے پر بھیجی گئی ڈاک مجھے موصول شدہ تصور ہوگی۔ نیز، قسط کی ادائیگی کا واحد قانونی ثبوت صرف ادارے کے آفیشل نمبر (03231988351) سے جاری کردہ "ڈیجیٹل رسید" ہوگی، اس کے علاوہ ہر قسم کا زبانی یا غیر سرکاری دعویٰ باطل سمجھا جائے گا۔', ttfFontBold),

                  pw.SizedBox(height: 6),

                  // 🎯 4. دستخط اور انگوٹھا
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط/انگوٹھا مقر: _______________________'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.8, color: PdfColors.black)),
                      pw.Text(_fixUrdu('تاریخ: $liveDateStr'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.8, color: PdfColors.black)),
                    ],
                  ),

                  pw.SizedBox(height: 6),

                  // 🎯 5. گواہان (اب دونوں لائنیں پیج پر بالکل صاف اور مارجن کے ساتھ آئیں گی)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('گواہ نمبر 1 (نام و شناختی کارڈ): _______________________'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.2, color: PdfColors.black)),
                      pw.Text(_fixUrdu('دستخط: _______________________'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.2, color: PdfColors.black)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('گواہ نمبر 2 (نام و شناختی کارڈ): _______________________'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.2, color: PdfColors.black)),
                      pw.Text(_fixUrdu('دستخط: _______________________'),
                          style: pw.TextStyle(font: ttfFontBold, fontSize: 9.2, color: PdfColors.black)),
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
      developer.log('Declaration PDF Generation Error', error: e, stackTrace: stackTrace);
    }
  }

  static pw.Widget _buildParagraph(String prefix, String text, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.2),
      child: pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: prefix,
              style: pw.TextStyle(font: fontBold, fontSize: 9.8, color: PdfColors.black),
            ),
            pw.TextSpan(
              text: _fixUrdu(text),
              style: pw.TextStyle(font: fontBold, fontSize: 9.8, color: PdfColors.black),
            ),
          ],
        ),
      ),
    );
  }
}