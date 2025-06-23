import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZakatInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String tooltip;
  final IconData? icon;

  const ZakatInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.tooltip,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.green.shade700) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
