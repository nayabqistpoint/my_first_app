import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GuarantorHelper {
  // 🎯 اردو الٹے الفاظ کو درست جوڑنے کا فنکشن
  static String _fixUrdu(String text) {
    if (text.trim().isEmpty) return text;
    return ArabicReshaper().reshape(text);
  }

  // 🎯 packageName سے صرف نمبرز نکالنے کا فنکشن
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

      // ۱۔ فونٹس
      final ttfFont = await PdfGoogleFonts.amiriRegular();
      final ttfFontBold = await PdfGoogleFonts.amiriBold();

      // ۲۔ لائیو تاریخ
      DateTime now = DateTime.now();
      String liveDateStr = "${now.day}/${now.month}/${now.year}";

      // ۳۔ Hive Boxes
      var customerBox = Hive.box('customerbox');
      var guarantorBox = Hive.box('guarantorbox');
      var packageBox = Hive.box('packagebox');

      dynamic customerData = customerBox.get(phone) ?? requestData;
      dynamic guarantorData = guarantorBox.get(phone) ?? requestData;
      dynamic packageData = packageBox.get(phone) ?? requestData;

      // ۴۔ ڈیٹا کیز
      String guarantorName = guarantorData['guarantorName'] ?? guarantorData['name'] ?? 'غیر موجود';
      String guarantorFatherName = guarantorData['guarantorFatherName'] ?? guarantorData['fatherName'] ?? 'غیر موجود';
      String guarantorCnic = guarantorData['guarantorCnic'] ?? guarantorData['cnic'] ?? 'غیر موجود';
      String guarantorPhone = guarantorData['guarantorPhone'] ?? guarantorData['phone'] ?? 'غیر موجود';
      String guarantorAddress = guarantorData['guarantorAddress'] ?? guarantorData['address'] ?? 'غیر موجود';

      String customerName = customerData['customerName'] ?? customerData['name'] ?? 'غیر موجود';
      String customerFatherName = customerData['customerFatherName'] ?? customerData['fatherName'] ?? customerData['fatherFatherName'] ?? 'غیر موجود';
      String customerCnic = customerData['customerCnic'] ?? customerData['cnic'] ?? 'غیر موجود';

      String mobileName = packageData['mobileName'] ?? packageData['itemName'] ?? 'غیر موجود';
      String totalPrice = packageData['totalPrice']?.toString() ?? '0';
      String advanceAmount = packageData['advanceAmount']?.toString() ?? packageData['advance']?.toString() ?? '0';
      String monthlyInstallment = packageData['monthlyInstallment']?.toString() ?? '0';
      
      dynamic rawPackageName = packageData['packageName'] ?? packageData['installmentsCount'];
      String packageName = _cleanNumbersOnly(rawPackageName);

      String checkNumber = packageData['checkNumber']?.toString() ?? packageData['chequeNo']?.toString() ?? '____________';
      String bankName = packageData['bankName']?.toString() ?? '____________';

      // ۵۔ پی ڈی ایف پیج
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
                  // 🎯 Header
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
                    child: pw.Text(_fixUrdu('(ضمانت نامہ)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13)),
                  ),
                  pw.SizedBox(height: 6),

                  // 🎯 ۱۔ ضامن کی معلومات
                  pw.Text(_fixUrdu('1. ضامن کی معلومات:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.SizedBox(height: 3),

                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(child: pw.Text(_fixUrdu('ضامن کا نام: $guarantorName'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5))),
                            pw.Expanded(child: pw.Text(_fixUrdu('ولدیت: $guarantorFatherName'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5))),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Expanded(child: pw.Text(_fixUrdu('شناختی کارڈ: $guarantorCnic'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5))),
                            pw.Expanded(child: pw.Text(_fixUrdu('موبائل نمبر: $guarantorPhone'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5))),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Expanded(child: pw.Text(_fixUrdu('موجودہ پتہ: $guarantorAddress'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  // 🎯 ۲۔ تفصیل اثاثہ جات, مالیات و سیکیورٹی
                  pw.Text(_fixUrdu('2. تفصیل اثاثہ جات, مالیات و سیکیورٹی:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.Divider(thickness: 0.5),

                  pw.Text(_fixUrdu('مطلوبہ اثاثہ و ماڈل: $mobileName'), style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('کل قیمت: $totalPrice ایڈوانس: $advanceAmount ماہانہ قسط: $monthlyInstallment اقساط کی تعداد: $packageName'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),
                  pw.SizedBox(height: 2),
                  pw.Text(_fixUrdu('سیکیورٹی چیک نمبر: $checkNumber بینک: $bankName'),
                      style: pw.TextStyle(font: ttfFont, fontSize: 9.5)),

                  pw.SizedBox(height: 8),

                  // 🎯 ۳۔ صراحتِ ضمانت
                  pw.Text(_fixUrdu('3. صراحتِ ضمانت :'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.Divider(thickness: 0.5),

                  pw.Text(
                    _fixUrdu('میں مسمٰی (ضامن): $guarantorName بحیثیتِ ضامن، مسمٰی (درخواست گزار): $customerName ولدیت: $customerFatherName شناختی کارڈ نمبر: $customerCnic کی مکمل ضمانت دیتا ہوں۔'),
                    style: pw.TextStyle(font: ttfFont, fontSize: 9.5),
                    textAlign: pw.TextAlign.justify,
                  ),

                  pw.SizedBox(height: 10),

                  // 🎯 قانونی اقرار نامہ و حلف نامہ
                  pw.Text(_fixUrdu('قانونی اقرار نامہ و حلف نامہ:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5)),
                  pw.Divider(thickness: 0.5),

                  pw.Text(
                    _fixUrdu('"میں بقیدِ ہوش و حواسِ خمسہ بلا کسی جبر و اکراہ یہ اقرار کرتا ہوں کہ اگر مذکورہ درخواست گزار (خرید دار) نایاب قسط پوائنٹ کی قسطیں بروقت (ہر ماہ کی ۵ تاریخ تک) ادا کرنے میں ناکام رہا، روپوش ہو گیا، یا کسی بھی قسم کی نادہندگی کا مرتکب ہوا, تو نایاب قسط پوائنٹ کو یہ قانونی حق حاصل ہوگا کہ وہ کل واجب الادا رقم یا اثاثہ مجھ سے (بطورِ ضامن) وصول کرے۔ میں تمام بقایا جات کی ادائیگی کا ذاتی طور پر ذمہ دار اور پابند رہوں گا۔"'),
                    style: pw.TextStyle(font: ttfFont, fontSize: 9.2),
                    textAlign: pw.TextAlign.justify,
                  ),

                  pw.Spacer(),

                  // 🎯 دستخط، انگوٹھا اور نگران اعلیٰ
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط و انگوٹھا ضامن: _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8.5)),
                      pw.Text(_fixUrdu('دستخط نگران اعلیٰ (حافظ محمد صابر): _______________________'), style: pw.TextStyle(font: ttfFont, fontSize: 8.5)),
                    ],
                  ),

                  pw.SizedBox(height: 12),

                  // 🎯 تاریخ اور نوٹ
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('تاریخ: $liveDateStr'), style: pw.TextStyle(font: ttfFont, fontSize: 8.5)),
                      pw.Text(
                        _fixUrdu('نوٹ: ضامن کے شناختی کارڈ کی کاپی منسلک کرنا لازمی ہے۔'),
                        style: pw.TextStyle(font: ttfFontBold, fontSize: 8.5),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 3),

                  // 🎯 فوٹر (بغیر ڈیش کے بالکل درست نمبرز کے ساتھ)
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
      developer.log('Guarantor PDF Generation Error', error: e, stackTrace: stackTrace);
    }
  }
}