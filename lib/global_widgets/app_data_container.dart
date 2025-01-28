import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import 'app_text.dart';

class AppDataContainer extends StatelessWidget {
  final String? title, subtitle, subtitle2, subtitle3;

  const AppDataContainer(
      {super.key, this.title, this.subtitle, this.subtitle2, this.subtitle3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      width: 173,
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
          color: AppColors.kContainerBox,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: AppColors.kContainerBoarder)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title: title,
            fontSize: 17,
            fontColor: AppColors.kPrimaryTextColor,
            fontWeight: FontWeight.bold,
          ),
          AppText(
            title: subtitle,
            fontSize: 15,
            fontColor: AppColors.kTextSecondaryFiled,
          ),
          subtitle2 == null ||subtitle2 == "0.00"||subtitle2 == "--"
              ? SizedBox.shrink()
              : AppText(
                  title: subtitle2,
                  fontSize: 15,
                  fontColor: AppColors.kTextSecondaryFiled,
                ),
          subtitle3 == null ||subtitle2 == "0.00"||subtitle2 == "--"
              ? SizedBox.shrink()
              : AppText(
                  title: subtitle3,
                  fontSize: 15,
                  fontColor: AppColors.kTextSecondaryFiled,
                ),
        ],
      ),
    );
  }
}
