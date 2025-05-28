import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../assets.dart';
import '../colors/colors.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text, icons;
  final double? width, height, borderRadius, fontSize;
  final Color? textColor, bgColor;

  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icons,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.textColor,
    this.bgColor,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Tween<double> _tween = Tween(begin: 1.0, end: 0.95);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _tween.animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        )),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100),
          ),
          child: Container(
            height: widget.height ?? 55,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              color: widget.bgColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 100),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SvgPicture.asset(widget.icons, width: 20, height: 20),
                ),
                const Spacer(),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.black,
                    fontSize: widget.fontSize ?? 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    widget.icons,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    ),
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
