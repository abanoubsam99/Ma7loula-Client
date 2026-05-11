import 'package:flutter/material.dart';

import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/util_values.dart';

class PaymentMethodCard extends StatelessWidget {
  final String name;
  final String imageIcon;
  final int? value;
  final Function(int?)? onChanged;
  final int? selectedValue;

  const PaymentMethodCard({
    super.key,
    required this.name,
    required this.imageIcon,
    this.value,
    this.onChanged,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        Text(
          name,
          style: const TextStyle(
            color: ColorsPalette.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Image.asset(
          imageIcon,
          height: 24,
          width: 24,
        )
      ],
    );
    return Material(
      child: Builder(
        builder: (context) {
          if ([value, onChanged].contains(null)) {
            return ListTile(
              tileColor: ColorsPalette.lightGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: UtilValues.borderRadius5),
              title: title,
            );
          } else {
            return RadioListTile(
              tileColor: ColorsPalette.darkGrey.withOpacity(0.18),
              shape: RoundedRectangleBorder(
                  borderRadius: UtilValues.borderRadius5),
              value: value!,
              groupValue: selectedValue,
              onChanged: onChanged!,
              activeColor: ColorsPalette.primaryColor,
              title: title,
            );
          }
        },
      ),
    );
  }
}
