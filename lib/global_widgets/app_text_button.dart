// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../config/app_colors.dart';
//
// class AppTextButton extends StatefulWidget {
//   final String title;
//   final Function()? onTap;
//
//   const AppTextButton({super.key, required this.title, required this.onTap});
//
//   @override
//   State<AppTextButton> createState() => _AppTextButtonState();
// }
//
// class _AppTextButtonState extends State<AppTextButton> {
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed:widget.onTap,
//       child: Container(
//         width: 160,
//         padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(15)),
//           color: AppColors.kTextPrimaryButton,
//         ),
//         child: Text(
//           widget.title,
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
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
      onPressed: widget.onTap,
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
          widget.title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
