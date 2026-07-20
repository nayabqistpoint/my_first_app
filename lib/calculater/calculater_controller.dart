import 'package:flutter/material.dart';

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
    double baseProfit = _hasSecurityCheck ? 0.25 : 0.35;
    return baseProfit + ((months - 6) * 0.05);
  }

  double getTotalWithProfit(int months) => _totalAmount + (_totalAmount * getProfitPercentage(months));

  double calculateInstallmentWithoutAdvance(int months) => getTotalWithProfit(months) / months;

  double calculateInstallment(int months) {
    double total = getTotalWithProfit(months);
    double base6MonthInstallment = getTotalWithProfit(6) / 6;
    double minAdvanceRequired = base6MonthInstallment * 0.8;
    double effectiveAdvance = (_advanceAmount > 0 && _advanceAmount >= minAdvanceRequired) ? _advanceAmount : minAdvanceRequired;
    return (total - effectiveAdvance) / (months - 1);
  }

  // نیا بہتر کردہ میسج فنکشن
  String? getValidationMessage() {
    // اگر ٹوٹل رقم صفر ہے یا یوزر نے کچھ نہیں لکھا تو کوئی میسج نہیں
    if (_totalAmount <= 0) return null; 
    
    double base6MonthInstallment = getTotalWithProfit(6) / 6;
    double minAdvanceRequired = base6MonthInstallment * 0.8;

    // اگر ایڈوانس صفر ہے یا حد سے کم ہے تو میسج دکھائیں
    if (_advanceAmount > 0 && _advanceAmount < minAdvanceRequired) {
      return "یا تو ایڈوانس صفر رکھیں یا کم از کم ${minAdvanceRequired.toStringAsFixed(0)} روپے رکھیں۔";
    }
    
    return null;
  }

  List<Map<String, String>> calculateInstallments() {
    List<Map<String, String>> results = [];
    if (_totalAmount <= 0) return results;
    
    for (int i = 6; i <= 12; i++) {
      double total = getTotalWithProfit(i);
      double installmentWithout = calculateInstallmentWithoutAdvance(i);
      double installmentWith = calculateInstallment(i);

      results.add({
        "months": "$i ماہ",
        "total": total.toStringAsFixed(0),
        "without": installmentWithout.toStringAsFixed(0),
        "with": installmentWith.toStringAsFixed(0),
      });
    }
    return results;
  }
}