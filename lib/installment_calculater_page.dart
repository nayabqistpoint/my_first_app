import 'package:flutter/material.dart';
import 'calculater/calculater_header.dart';
import 'calculater/calculater_list.dart';

class InstallmentCalculaterPage extends StatelessWidget {
  const InstallmentCalculaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // AppBar کو یہاں سے مکمل ہٹا دیا ہے
      body: SafeArea(
        child: Column(
          children: [
            CalculaterHeader(), // اوپر والا حصہ اب پوری اسکرین کی ٹاپ پر آئے گا
            Expanded(child: CalculaterList()), // نیچے لسٹ والا حصہ
          ],
        ),
      ),
    );
  }
}