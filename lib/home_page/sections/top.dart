import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/home_page/views/item_controller.dart';
import 'package:my_first_app/home_page/sections/sections_controller.dart';
import 'package:my_first_app/welcome/login_page.dart';
import 'package:my_first_app/home_page/views/customers_widgets/balance_helper.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.isBoxOpen('bankBox') ? Hive.box('bankBox').listenable() : ValueNotifier(null),
      builder: (context, _, child1) {
        return ValueListenableBuilder(
          // 🎯 1. ٹرانزیکشن باکس اور کسٹمر باکس کو ڈائریکٹ لسن کرنا
          valueListenable: Hive.isBoxOpen('transactionBox') ? Hive.box('transactionBox').listenable() : ValueNotifier(null),
          builder: (context, txBox, child2) {
            return ListenableBuilder(
              listenable: Listenable.merge([itemController, sectionsController]),
              builder: (context, child3) {
                
                // کیش / بینک بیلنس
                double totalBank = 0.0;
                if (Hive.isBoxOpen('bankBox')) {
                  for (var v in Hive.box('bankBox').values) {
                    if (v != null) totalBank += double.tryParse(v.toString()) ?? 0.0;
                  }
                }

                // 🎯 2. لائیو لینے / دینے والی رقم کا حساب
                double totalRed = 0.0;
                double totalGreen = 0.0;

                if (Hive.isBoxOpen('customerBox') && txBox is Box) {
                  var customerBox = Hive.box('customerBox');
                  for (var key in customerBox.keys) {
                    var customerData = customerBox.get(key);
                    if (customerData != null && customerData is Map) {
                      String phone = (customerData['customerPhone'] ?? key ?? '').toString();
                      
                      // بیلنس ہیلپر سے ڈائریکٹ نیٹ رقم
                      double balance = BalanceHelper.calculateCustomerBalance(txBox, phone);
                      
                      if (balance < 0) {
                        totalRed += balance.abs(); // لینے ہیں (Red)
                      } else if (balance > 0) {
                        totalGreen += balance;    // دینے ہیں (Green)
                      }
                    }
                  }
                }

                // اسٹاک ٹوٹل
                double totalStock = itemController.items.fold(0.0, (sum, i) => sum + (i.quantity * i.purchasePrice));

                return Column(
                  children: [
                    // ٹاپ ریڈ پٹی
                    Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rs. ${totalBank.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Text("نایاب قسط پوائنٹ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (v) {
                                  if (v == 'logout') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'logout',
                                    child: Row(children: [
                                      Icon(Icons.logout, color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('لاگ آؤٹ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🎯 3. بٹنز جن میں ڈائریکٹ لائیو رقمیں ڈسپلے ہوں گی
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          _btn(context, "آپ نے لینے ہیں", totalRed.toInt().toString(), Colors.red, "get"),
                          const SizedBox(width: 8),
                          _btn(context, "آپ نے دینے ہیں", totalGreen.toInt().toString(), Colors.green, "give"),
                          const SizedBox(width: 8),
                          _btn(context, "اسٹاک", totalStock.toInt().toString(), Colors.blue, "stock"),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _btn(BuildContext context, String title, String amount, Color color, String id) {
    bool isSelected = sectionsController.selectedTopButton == id;
    double width = (MediaQuery.of(context).size.width - 24) / 2;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => sectionsController.selectTopButton(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(50) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1),
              const SizedBox(height: 2),
              Text(amount, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}