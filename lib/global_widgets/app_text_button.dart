import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class AppTextButton extends StatefulWidget {
  final String title;
  final Function()? onTap;

  const AppTextButton({super.key, required this.title, required this.onTap});

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: AppColors.kPrimaryColor,
        ),
        child: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}