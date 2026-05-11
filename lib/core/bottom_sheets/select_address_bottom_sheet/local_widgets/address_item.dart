import 'package:flutter/material.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';

class AddressItem extends StatelessWidget {
  final String addressName;
  final String address;
  final VoidCallback onTap;
  final IconData locationIcon;

  const AddressItem({
    Key? key,
    required this.addressName,
    required this.address,
    required this.onTap,
    this.locationIcon = Icons.location_on_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        locationIcon,
        color: ColorsPalette.veryDarkGrey,
      ),
      title: Text(
        addressName,
        style: const TextStyle(
          color: ColorsPalette.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        address,
        style: const TextStyle(
          color: ColorsPalette.darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
