import 'package:flutter/material.dart';

class ZakatInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String tooltip;

  const ZakatInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
