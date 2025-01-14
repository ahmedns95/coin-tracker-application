import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class AppText extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final Color? fontColor;

  const AppText({super.key, required this.title, this.fontSize,this.fontColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? "--",
      style: TextStyle(
        color: fontColor??AppColors.kPrimaryColor,
        fontSize: fontSize ?? 20,
      ),
    );
  }
}
