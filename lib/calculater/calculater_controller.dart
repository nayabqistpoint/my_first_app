import 'package:flutter/material.dart';
import 'calculater_config.dart';

class CalculaterController extends ChangeNotifier {
  double _totalAmount = 0.0;
  double _advanceAmount = 0.0;
  bool _hasSecurityCheck = false;

  double get totalAmount => _totalAmount;
  double get advanceAmount => _advanceAmount;
  bool get hasSecurityCheck => _hasSecurityCheck;

  void setTotalAmount(String value) { 
    _totalAmount = double.tryParse(value) ?? 0.0; 
    notifyListeners(); 
  }
  
  void setAdvanceAmount(String value) { 
    _advanceAmount = double.tryParse(value) ?? 0.0; 
    notifyListeners(); 
  }
  
  void toggleSecurityCheck(bool value) { 
    _hasSecurityCheck = value; 
    notifyListeners(); 
  }

  double getProfitPercentage(int months) {
    double baseProfit = _hasSecurityCheck 
        ? CalculaterConfig.baseProfitSecurityCheck 
        : CalculaterConfig.baseProfitNoSecurityCheck;
    return baseProfit + ((months - 6) * CalculaterConfig.profitIncrementPerMonth);
  }

  double getTotalWithProfit(int months) => _totalAmount + (_totalAmount * getProfitPercentage(months));

  double calculateInstallmentWithoutAdvance(int months) => getTotalWithProfit(months) / months;

  // یہاں ہم کم از کم 80% والی رزلਟ اماؤنٹ نکال رہے ہیں
  double getMinimumRequiredAdvance(int months) {
    double base6MonthInstallment = getTotalWithProfit(6) / 6;
    return base6MonthInstallment * 0.8;
  }

  double calculateInstallment(int months) {
    double total = getTotalWithProfit(months);
    double minAdvanceRequired = getMinimumRequiredAdvance(months);
    double effectiveAdvance = (_advanceAmount > 0 && _advanceAmount >= minAdvanceRequired) ? _advanceAmount : minAdvanceRequired;
    return (total - effectiveAdvance) / (months - 1);
  }

  String? getValidationMessage() {
    if (_totalAmount <= 0) return null; 
    
    double minAdvanceRequired = getMinimumRequiredAdvance(6);

    if (_advanceAmount > 0 && _advanceAmount < minAdvanceRequired) {
      return "یا تو ایڈوانس صفر رکھیں یا کم از کم ${minAdvanceRequired.toStringAsFixed(0)} روپے رکھیں۔";
    }
    
    return null;
  }

  List<Map<String, dynamic>> calculateInstallments() {
    List<Map<String, dynamic>> results = [];
    if (_totalAmount <= 0) return results;
    
    for (int i = 6; i <= 12; i++) {
      double total = getTotalWithProfit(i);
      double installmentWithout = calculateInstallmentWithoutAdvance(i);
      double installmentWith = calculateInstallment(i);
      
      // یہاں ہم چیک کرتے ہیں کہ اگر یوزر نے باکس خالی چھوڑا ہے تو 80% والی اصل رقم (رزلٹ) کیا بنتی ہے
      double minAdv = getMinimumRequiredAdvance(i);
      double actualAdvanceToDisplay = (_advanceAmount > 0 && _advanceAmount >= minAdv) ? _advanceAmount : minAdv;
      
      // آپشن A: ایڈوانس کے ساتھ (یہاں ہمیشہ اصل رقم آئے گی، کبھی صفر نہیں)
      results.add({
        "packageName": "${i}A",
        "title": "$i ماہ (ایڈوانس کے ساتھ)",
        "months": "$i ماہ",
        "total": total.toStringAsFixed(0),
        "installment": installmentWith.toStringAsFixed(0),
        "advance": actualAdvanceToDisplay.toStringAsFixed(0), // یہ اب وہ رزلٹ والی رقم ہے جو آپ مانگ رہے تھے
        "isAdvance": true,
      });

      // آپشن B: بغیر ایڈوانس کے (یہاں ایڈوانس ہمیشہ 0 ہوگا)
      results.add({
        "packageName": "${i}B",
        "title": "$i ماہ (بغیر ایڈوانس)",
        "months": "$i ماہ",
        "total": total.toStringAsFixed(0),
        "installment": installmentWithout.toStringAsFixed(0),
        "advance": "0",
        "isAdvance": false,
      });
    }
    return results;
  }
}