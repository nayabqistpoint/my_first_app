import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/add_party_dialog.dart';
import 'customers_widgets/customer_row_ui.dart';
import 'customers_widgets/customer_controller.dart';

class CustomersListView extends StatefulWidget {
  const CustomersListView({super.key});

  @override
  State<CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<CustomersListView> {
  final CustomerController _controller = CustomerController();

  @override
  void initState() {
    super.initState();
    _controller.loadAndSortCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ------------------ ٹاپ بار (RTL) ------------------
        Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => showAddPartyDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 4.0,
                      shadowColor: Colors.green.shade900.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text("ایڈ پارٹی", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        setState(() {
                          _controller.searchCustomers(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "سرچ...",
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 38,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      items: ["سب", "باقی", "مکمل"].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (_) {},
                      hint: const Text("فلٹر", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(color: Colors.black12, thickness: 1, height: 1),

        // ------------------ محفوظ لائیو کسٹمر لسٹ ------------------
        Expanded(
          child: Hive.isBoxOpen('customerBox')
              ? ValueListenableBuilder(
                  valueListenable: Hive.box('customerBox').listenable(),
                  builder: (context, Box box, _) {
                    _controller.loadAndSortCustomers();

                    if (_controller.customers.isEmpty) {
                      return const Center(
                        child: Text("کوئی کسٹمر موجود نہیں ہے", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: _controller.customers.length,
                      itemBuilder: (context, index) {
                        var customer = _controller.customers[index];
                        return CustomerRowUI(
                          name: customer['name'] ?? 'نامعلوم',
                          phone: customer['phone'] ?? '',
                          description: customer['description'] ?? '',
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}