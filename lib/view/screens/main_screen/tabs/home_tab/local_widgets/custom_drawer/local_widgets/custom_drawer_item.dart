import 'package:flutter/material.dart';

import '../../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../../core/utils/util_values.dart';
import '../../../../../../../../core/widgets/loading_widget.dart';

class CustomDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomDrawerItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Padding(
        padding: UtilValues.padding16V24H,
        child: isLoading
            ? const LoadingWidget(size: 25)
            : Row(
                children: [
                  Icon(
                    icon,
                    color: ColorsPalette.primaryColor,
                    size: 30,
                  ),
                  UtilValues.gap16,
                  Text(
                    title,
                    style: const TextStyle(
                      color: ColorsPalette.veryDarkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
