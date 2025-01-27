import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppTextButton extends StatelessWidget {
  final String title;
  final Function()? onTap;

  const AppTextButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Container(
        // Adjust width and height dynamically using MediaQuery
        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
        padding: EdgeInsets.symmetric(vertical: 10), // Adjust padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: AppColors.kTextPrimaryButton,
        ),
        alignment: Alignment.center, // Center text inside the button
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
