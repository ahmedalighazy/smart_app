import 'package:flutter/material.dart';
import '../utils/direction_helper.dart';

/// A Row widget that automatically adapts its text direction based on the app's locale
class AdaptiveRow extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;
  final VerticalDirection verticalDirection;

  const AdaptiveRow({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      verticalDirection: verticalDirection,
      textDirection: context.textDirection,
      children: children,
    );
  }
}

/// A Text widget that automatically adapts its text direction based on the app's locale
class AdaptiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const AdaptiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign ?? context.textAlign,
      textDirection: context.textDirection,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// A TextField widget that automatically adapts its text direction based on the app's locale
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.decoration,
    this.style,
    this.maxLines,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration:
          decoration?.copyWith(hintTextDirection: context.textDirection) ??
          InputDecoration(hintTextDirection: context.textDirection),
      style: style,
      textDirection: context.textDirection,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}
