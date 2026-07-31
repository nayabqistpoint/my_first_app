import 'package:flutter/material.dart';

class CustomerInfoWidget extends StatefulWidget {
  const CustomerInfoWidget({super.key});

  @override
  State<CustomerInfoWidget> createState() => CustomerInfoWidgetState();
}

// یہاں 'AutomaticKeepAliveClientMixin' ملایا گیا ہے تاکہ ڈیٹا ری بلڈ ہونے پر اڑے نہیں
class CustomerInfoWidgetState extends State<CustomerInfoWidget> with AutomaticKeepAliveClientMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? customerSelfiePath;

  @override
  bool get wantKeepAlive => true; // یہ ڈیٹا کو ہمیشہ زندہ اور محفوظ رکھے گا

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    casteController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // پیرنٹ پیج کو صرف اس فنکشن کے ذریعے کسٹمر کا ڈیٹا ملے گا
  Map<String, dynamic> getCustomerData() {
    return {
      'customerName': nameController.text.trim(),
      'customerFatherName': fatherNameController.text.trim(),
      'customerCaste': casteController.text.trim(),
      'customerPhone': phoneController.text.trim(),
      'customerCnic': cnicController.text.trim(),
      'customerAddress': addressController.text.trim(),
      'customerSelfie': customerSelfiePath ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin کے لیے لازمی ہے
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. کسٹمر کی ذاتی معلومات',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(controller: nameController, label: 'کسٹمر کا پورا نام', icon: Icons.person),
          const SizedBox(height: 12),
          _buildTextField(controller: fatherNameController, label: 'والد / شوہر کا نام', icon: Icons.person_outline),
          const SizedBox(height: 12),
          _buildTextField(controller: casteController, label: 'قوم', icon: Icons.group),
          const SizedBox(height: 12),
          _buildTextField(controller: phoneController, label: 'موبائل نمبر', icon: Icons.phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField(controller: cnicController, label: 'شناختی کارڈ نمبر (CNIC)', icon: Icons.credit_card, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildTextField(controller: addressController, label: 'گھر کا پتہ', icon: Icons.home),
          const SizedBox(height: 16),

          // سیلفی سیکشن
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      customerSelfiePath != null ? Icons.check_circle : Icons.camera_alt,
                      color: customerSelfiePath != null ? Colors.green : Colors.red[800],
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customerSelfiePath != null ? 'کسٹمر کی سیلفی لے لی گئی ہے' : 'کسٹمر کی لائیو سیلفی لیں',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: customerSelfiePath != null ? Colors.green.shade700 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      customerSelfiePath = 'dummy_path/customer_selfie.jpg';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('کسٹمر کی سیلفی محفوظ ہو گئی ہے')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customerSelfiePath != null ? Colors.green : Colors.red[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(customerSelfiePath != null ? Icons.done : Icons.camera, size: 16),
                  label: Text(customerSelfiePath != null ? 'دوبارہ لیں' : 'تصویر لیں', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'یہ خانہ خالی نہیں چھوڑ سکتے';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800], size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}