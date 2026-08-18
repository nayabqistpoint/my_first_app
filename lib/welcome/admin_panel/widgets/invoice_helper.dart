import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InvoiceHelper {
  static String _fixUrdu(String text) {
    if (text.trim().isEmpty) return text;
    return ArabicReshaper().reshape(text);
  }

  static int _extractMonths(dynamic rawValue) {
    if (rawValue == null) return 1;
    String strVal = rawValue.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(strVal) ?? 1;
  }

  static Future<void> generateAndPrintPdf({
    required Map<String, dynamic> requestData,
    required String phone,
  }) async {
    try {
      final pdf = pw.Document();
      final ttfFontBold = await PdfGoogleFonts.amiriBold();

      DateTime now = DateTime.now();
      String liveDateStr = "${now.day}/${now.month}/${now.year}";

      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      String phoneSuffix = cleanPhone.length >= 6 ? cleanPhone.substring(cleanPhone.length - 6) : cleanPhone;
      String invoiceNo = "INV-$phoneSuffix-01";

      var customerBox = Hive.box('customerbox');
      var packageBox = Hive.box('packagebox');

      dynamic customerData = customerBox.get(phone) ?? requestData;
      dynamic packageData = packageBox.get(phone) ?? requestData;

      String applicantName = customerData['customerName'] ?? customerData['name'] ?? customerData['applicantName'] ?? 'غیر موجود';
      String fatherName = customerData['customerFatherName'] ?? customerData['fatherName'] ?? 'غیر موجود';
      String cnicNumber = customerData['customerCnic'] ?? customerData['cnic'] ?? 'غیر موجود';
      String userPhone = customerData['phone'] ?? phone;
      String address = customerData['customerAddress'] ?? customerData['address'] ?? 'غیر موجود';

      String mobileName = packageData['mobileName'] ?? packageData['itemName'] ?? 'غیر موجود';
      String imeiNumber = packageData['imei'] ?? packageData['imeiNumber'] ?? '123456789012345';
      
      double totalPrice = double.tryParse(packageData['totalPrice']?.toString() ?? '0') ?? 0;
      double advancePrice = double.tryParse(
            packageData['advanceAmount']?.toString() ?? packageData['advancePrice']?.toString() ?? '0') ?? 0;
      
      double monthlyInstallment = double.tryParse(
            packageData['monthlyInstallment']?.toString() ?? packageData['installmentAmount']?.toString() ?? '0') ?? 0;
      
      int totalMonths = _extractMonths(packageData['totalMonths'] ?? packageData['packageName'] ?? packageData['package']);
      
      double remainingBalance = totalPrice - advancePrice;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🎯 1. اوریجنل ہیڈر
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(_fixUrdu('نایاب قسط پوائنٹ'), style: pw.TextStyle(font: ttfFontBold, fontSize: 20, color: PdfColors.blue900)),
                          pw.SizedBox(height: 2),
                          pw.Text(_fixUrdu('(آپ کی سہولت، ہمارا عزم)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5, color: PdfColors.grey800)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(_fixUrdu('زیرِ ملکیت: محمد ڈیری (رجسٹرڈ)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5, color: PdfColors.black)),
                          pw.SizedBox(height: 2),
                          pw.Text(_fixUrdu('آفیشل ہیلپ لائن: 03231988351'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10.5, color: PdfColors.black)),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                  pw.SizedBox(height: 10),

                  // 🎯 2. عنوان اور انوائس نمبر
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Text(_fixUrdu('فروخت رسید / سیلز انوائس'), style: pw.TextStyle(font: ttfFontBold, fontSize: 13, color: PdfColors.white)),
                      ),
                      pw.Text(_fixUrdu('رسید نمبر: $invoiceNo  |  تاریخ: $liveDateStr'), style: pw.TextStyle(font: ttfFontBold, fontSize: 11, color: PdfColors.black)),
                    ],
                  ),
                  pw.SizedBox(height: 15),

                  // 🎯 3. خریدار کی تفصیلات
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500, width: 0.8), borderRadius: pw.BorderRadius.circular(5)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(_fixUrdu('خریدار کی تفصیلات:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 11.5, color: PdfColors.blue900)),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(_fixUrdu('نام خریدار: $applicantName'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                            pw.Text(_fixUrdu('ولدیت/زوجیت: $fatherName'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                            pw.Text(_fixUrdu('فون نمبر: $userPhone'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(_fixUrdu('شناختی کارڈ نمبر: $cnicNumber'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                            pw.Text(_fixUrdu('پتہ: $address'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 18),

                  // 🎯 4. پروڈکٹ ٹیبل
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.8),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _tableCell('تفصیل پروڈکٹ / ماڈل', isHeader: true, font: ttfFontBold),
                          _tableCell('IMEI نمبر', isHeader: true, font: ttfFontBold),
                          _tableCell('کل قیمت (روپے)', isHeader: true, font: ttfFontBold),
                          _tableCell('ایڈوانس ادا شدہ', isHeader: true, font: ttfFontBold),
                          _tableCell('بقایا لائبلٹی', isHeader: true, font: ttfFontBold),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _tableCell(mobileName, font: ttfFontBold),
                          _tableCell(imeiNumber, font: ttfFontBold),
                          _tableCell(totalPrice.toStringAsFixed(0), font: ttfFontBold),
                          _tableCell(advancePrice.toStringAsFixed(0), font: ttfFontBold),
                          _tableCell(remainingBalance.toStringAsFixed(0), font: ttfFontBold),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 18),

                  // 🎯 5. اقساط کا پلان
                  pw.Text(_fixUrdu('اقساط کا پلان و شیڈول:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 11.5, color: PdfColors.blue900)),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.8),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          _tableCell('کل اقساط کی تعداد', isHeader: true, font: ttfFontBold),
                          _tableCell('ماہانہ قسط کی رقم', isHeader: true, font: ttfFontBold),
                          _tableCell('قسط کی مقررہ تاریخ', isHeader: true, font: ttfFontBold),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _tableCell('$totalMonths ماہ', font: ttfFontBold),
                          _tableCell('Rs. ${monthlyInstallment.toStringAsFixed(0)}', font: ttfFontBold),
                          _tableCell('ہر مہینے کی 5 تاریخ', font: ttfFontBold),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 18),

                  // 🎯 6. نوٹس
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(color: PdfColors.grey400)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(_fixUrdu('ضروری ہدایات و نوٹ:'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10, color: PdfColors.red900)),
                        pw.SizedBox(height: 3),
                        pw.Text(_fixUrdu('1. یہ سیلز انوائس مکمل معاہدہ اقساط اور بیانِ حلفی کی تعمیل کے بعد جاری کی گئی ہے۔'), style: pw.TextStyle(font: ttfFontBold, fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text(_fixUrdu('2. قسط کی ادائیگی کا واحد ثبوت صرف ادارے کے آفیشل نمبر (03231988351) سے موصول شدہ "ڈیجیٹل رسید" ہوگی۔'), style: pw.TextStyle(font: ttfFontBold, fontSize: 9)),
                      ],
                    ),
                  ),

                  // 🎯 دستخط کے لیے کھلی جگہ (50 height)
                  pw.SizedBox(height: 50),

                  // 🎯 7. دستخط
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(_fixUrdu('دستخط خریدار: _______________________'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                      pw.Text(_fixUrdu('دستخط و مہر (فروخت کنندہ / نگرانِ اعلیٰ): _______________________'), style: pw.TextStyle(font: ttfFontBold, fontSize: 10)),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // 🎯 8. آفیشل فوٹر
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue900, width: 1.0),
                      borderRadius: pw.BorderRadius.circular(4),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(_fixUrdu('نگرانِ اعلیٰ: حافظ محمد صابر (03012700351)'), style: pw.TextStyle(font: ttfFontBold, fontSize: 8.8, color: PdfColors.black)),
                            pw.SizedBox(height: 3),
                            pw.Text(_fixUrdu('قسط کی ادائیگی (جائز کیش، ایزی پیسہ، راست آئی ڈی): 03231988351'), style: pw.TextStyle(font: ttfFontBold, fontSize: 8.8, color: PdfColors.blue900)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(_fixUrdu('ای میل: nayabsahulatsenter@gmail.com'), style: pw.TextStyle(font: ttfFontBold, fontSize: 8.8, color: PdfColors.black)),
                            pw.SizedBox(height: 3),
                            pw.Text(_fixUrdu('پتہ: ہیڈ اسلام روڈ بستی محمد نگر نزد گورنمنٹ ہائی سکول بوائز قائم پور'), style: pw.TextStyle(font: ttfFontBold, fontSize: 8.2, color: PdfColors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e, stackTrace) {
      developer.log('Invoice PDF Generation Error', error: e, stackTrace: stackTrace);
    }
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, required pw.Font font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: pw.Center(
        child: pw.Text(
          _fixUrdu(text),
          style: pw.TextStyle(
            font: font,
            fontSize: isHeader ? 10.0 : 9.5,
            color: isHeader ? PdfColors.blue900 : PdfColors.black,
          ),
        ),
      ),
    );
  }
}