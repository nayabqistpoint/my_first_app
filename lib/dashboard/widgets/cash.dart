import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controller.dart';

class CashWidget extends StatefulWidget {
  const CashWidget({super.key});

  @override
  State<CashWidget> createState() => _CashWidgetState();
}

class _CashWidgetState extends State<CashWidget> {
  late final TextEditingController _bankNameController;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('bankBox').listenable(),
      builder: (context, box, child) {
        // 1. Calculate balances once per Box change
        final double cashBalance =
            (box.get('Cash') ?? box.get('cashInHand') ?? 0.0).toDouble();

        final Map<String, double> bankBalances = {};
        double totalBankBalance = 0.0;

        for (final key in box.keys) {
          final String keyStr = key.toString();
          if (keyStr != 'cashInHand' && keyStr != 'Cash') {
            final String cleanName = keyStr.startsWith('bank_')
                ? keyStr.replaceFirst('bank_', '')
                : keyStr;
            final double amt = (box.get(key) ?? 0.0).toDouble();
            bankBalances[cleanName] = amt;
            totalBankBalance += amt;
          }
        }

        final bankEntries = bankBalances.entries.toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Bank Balance & Cash in Hand Row ---
              Row(
                children: [
                  // Bank Balance Card
                  Expanded(
                    child: _BalanceCard(
                      title: "Bank Balance",
                      amount: totalBankBalance,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Cash in Hand Card (Clickable)
                  Expanded(
                    child: _BalanceCard(
                      title: "Cash In Hand",
                      amount: cashBalance,
                      color: Colors.blue,
                      onTap: () => _showCashAdjustmentDialog(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --- Bank List Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PopupMenuButton<int>(
                        offset: const Offset(0, 30),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.blue,
                          size: 26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            enabled: false,
                            child: SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Add Bank",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _bankNameController,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText: "بینک کا نام لکھیں",
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      final text = _bankNameController.text.trim();
                                      if (text.isNotEmpty) {
                                        dashboardController.updateBankBalance(text, 0.0);
                                        _bankNameController.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                    ),
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Rs. ${totalBankBalance.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Banks List",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // --- Bank List ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: bankEntries.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.black12, height: 1),
                      itemBuilder: (context, index) {
                        final bankName = bankEntries[index].key;
                        final bankAmount = bankEntries[index].value;

                        return InkWell(
                          onTap: () => _showBankAdjustmentDialog(
                              context, bankName, bankAmount),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rs. ${bankAmount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  bankName,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Dialogs ---

  void _showCashAdjustmentDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("کیش ان ہینڈ اپ ڈیٹ کریں",
            textAlign: TextAlign.right, style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: "رقم درج کریں",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.updateCash(-amount);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text("رقم نکالیں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.updateCash(amount);
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("جمع کریں (+)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) => amountController.dispose()); // Dispose controller on close
  }

  void _showBankAdjustmentDialog(
      BuildContext context, String bankName, double currentAmount) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(bankName,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("موجودہ بیلنس: Rs. ${currentAmount.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: "رقم درج کریں",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.adjustBankBalance(bankName, -amount);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text("رقم نکالیں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.adjustBankBalance(bankName, amount);
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("جمع کریں (+)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) => amountController.dispose()); // Dispose controller on close
  }
}

// --- Reusable Balance Card Widget ---

class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final VoidCallback? onTap;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text(
            "Rs. ${amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}