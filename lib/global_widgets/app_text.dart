import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class AppText extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;

  const AppText(
      {super.key,
      required this.title,
      this.fontSize,
      this.fontColor,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? "--",
      style: TextStyle(
          color: fontColor ?? AppColors.kPrimaryTextColor,
          fontSize: fontSize ?? 20,
          fontWeight: fontWeight ?? FontWeight.normal),
    );
  }
}
