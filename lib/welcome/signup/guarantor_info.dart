import 'package:flutter/material.dart';

class GuarantorInfoWidget extends StatefulWidget {
  const GuarantorInfoWidget({super.key});

  @override
  State<GuarantorInfoWidget> createState() => GuarantorInfoWidgetState();
}

class GuarantorInfoWidgetState extends State<GuarantorInfoWidget> {
  bool isGuarantorPresent = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController casteController = TextEditingController(); // قوم کا الگ خانہ
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController(); // رشتے کا الگ خانہ
  final TextEditingController addressController = TextEditingController(); // گھر کا پتہ
  String? guarantorSelfiePath;

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    casteController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    relationshipController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getGuarantorData() {
    if (!isGuarantorPresent) {
      return {
        'isGuarantorPresent': false,
        'guarantorName': '',
        'guarantorFatherName': '',
        'guarantorCaste': '',
        'guarantorPhone': '',
        'guarantorCnic': '',
        'guarantorRelationship': '',
        'guarantorAddress': '',
        'guarantorSelfie': '',
      };
    }

    return {
      'isGuarantorPresent': true,
      'guarantorName': nameController.text.trim(),
      'guarantorFatherName': fatherNameController.text.trim(),
      'guarantorCaste': casteController.text.trim(),
      'guarantorPhone': phoneController.text.trim(),
      'guarantorCnic': cnicController.text.trim(),
      'guarantorRelationship': relationshipController.text.trim(),
      'guarantorAddress': addressController.text.trim(),
      'guarantorSelfie': guarantorSelfiePath ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. ضامن کی معلومات',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'کیا ضامن موجود ہے؟',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isGuarantorPresent,
                    activeThumbColor: Colors.red[800],
                    onChanged: (value) {
                      setState(() {
                        isGuarantorPresent = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          if (isGuarantorPresent) ...[
            const SizedBox(height: 12),
            _buildTextField(controller: nameController, label: 'ضامن کا پورا نام', icon: Icons.person),
            const SizedBox(height: 12),
            _buildTextField(controller: fatherNameController, label: 'ضامن کے والد / شوہر کا نام', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(controller: casteController, label: 'قوم', icon: Icons.group),
            const SizedBox(height: 12),
            _buildTextField(controller: phoneController, label: 'ضامن کا موبائل نمبر', icon: Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(controller: cnicController, label: 'ضامن کا شناختی کارڈ نمبر (CNIC)', icon: Icons.credit_card, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(controller: relationshipController, label: 'کسٹمر کے ساتھ رشتہ', icon: Icons.handshake),
            const SizedBox(height: 12),
            _buildTextField(controller: addressController, label: 'گھر کا پتہ', icon: Icons.home),
            const SizedBox(height: 16),

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
                        guarantorSelfiePath != null ? Icons.check_circle : Icons.camera_alt,
                        color: guarantorSelfiePath != null ? Colors.green : Colors.red[800],
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        guarantorSelfiePath != null ? 'ضامن کی سیلفی لے لی گئی ہے' : 'ضامن کی لائیو سیلفی لیں',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: guarantorSelfiePath != null ? Colors.green.shade700 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        guarantorSelfiePath = 'dummy_path/guarantor_selfie.jpg';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ضامن کی سیلفی محفوظ ہو گئی ہے')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guarantorSelfiePath != null ? Colors.green : Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: Icon(guarantorSelfiePath != null ? Icons.done : Icons.camera, size: 16),
                    label: Text(guarantorSelfiePath != null ? 'دوبارہ لیں' : 'تصویر لیں', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
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
        if (isGuarantorPresent && (value == null || value.trim().isEmpty)) {
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