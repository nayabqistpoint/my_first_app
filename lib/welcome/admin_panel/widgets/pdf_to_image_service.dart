import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';

class PdfToImageService {
  /// ویب اور تمام پلیٹ فارمز پر PDF صفحے کو PNG بائٹس میں بدلنا
  static Future<Uint8List?> convertPdfPageToImage(Uint8List pdfBytes) async {
    try {
      if (pdfBytes.isEmpty) return null;

      final document = await PdfDocument.openData(pdfBytes);
      final page = await document.getPage(1);
      
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      
      await document.close();
      return pageImage?.bytes;
    } catch (e) {
      // اگر ویب براؤزر پر ڈیکوڈنگ فیل ہو تو ایپ کریش نہیں ہوگی
      return null;
    }
  }
}