import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/colors.dart';

class CustomRichText extends StatelessWidget {
  final String title, subtitle;
  final TextStyle subtitleTextStyle;
  final VoidCallback onTab;

  const CustomRichText({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTab,
    required this.subtitleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
          children: [
            TextSpan(text: subtitle, style: subtitleTextStyle),
          ],
        ),
      ),
    );
  }
}
class PrimaryTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double fontSize;
  final Color textColor;

  const PrimaryTextButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.fontSize,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class DividerRow extends StatelessWidget {
  const DividerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              color: AppColor.kGreyColor,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
class PrimaryTextFormField extends StatelessWidget {
  final String hintText;
  final OutlineInputBorder? border, enabledBorder, focusedBorder, errorBorder, focusedErrorBorder;
  final double width, height;
  final TextEditingController controller;
  final Color? hintTextColor, fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final TextInputType? keyboardType;
  final double? borderRadius;
  final Function(String)? onChanged;
  final Function(PointerDownEvent)? onTapOutside;

  const PrimaryTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.width,
    required this.height,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.hintTextColor,
    this.fillColor,
    this.inputFormatters,
    this.prefixIcon,
    this.prefixIconColor,
    this.keyboardType,
    this.borderRadius = 8,
    this.onChanged,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.kLightAccentColor,
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.kGreyColor),
        decoration: InputDecoration(
          fillColor: fillColor ?? AppColor.kLightAccentColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: hintTextColor ?? AppColor.kGreyColor),
          prefixIcon: prefixIcon,
          prefixIconColor: prefixIconColor,
          border: border,
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedErrorBorder,
        ),
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onTapOutside: onTapOutside,
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final OutlineInputBorder? border, enabledBorder, focusedBorder, errorBorder, focusedErrorBorder;
  final double width, height;
  final TextEditingController controller;

  const PasswordTextField({
    super.key,
    required this.hintText,
    required this.height,
    required this.controller,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    required this.width,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        obscureText: _obscureText,
        controller: widget.controller,
        style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.kGreyColor),
        decoration: InputDecoration(
          fillColor: AppColor.kLightAccentColor,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: AppColor.kGreyColor),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14, color: AppColor.kGreyColor),
          border: widget.border,
          enabledBorder: widget.enabledBorder,
          focusedBorder: widget.focusedBorder,
          errorBorder: widget.errorBorder,
          focusedErrorBorder: widget.focusedErrorBorder,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final double? width, height, borderRadius, fontSize;
  final IconData? iconData;
  final Color? textColor, bgColor;

  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    required this.textColor,
    required this.bgColor,
    this.iconData,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tween = Tween<double>(begin: 1.0, end: 0.95);
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: ScaleTransition(
        scale: tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeIn)),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius ?? 8)),
          child: Container(
            height: widget.height ?? 55,
            alignment: Alignment.center,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.iconData != null)
                  Icon(widget.iconData, color: AppColor.kWhiteColor),
                if (widget.iconData != null) const SizedBox(width: 4),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize ?? 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
