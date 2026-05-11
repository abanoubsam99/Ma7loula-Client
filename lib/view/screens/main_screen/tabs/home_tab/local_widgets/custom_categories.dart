import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/util_values.dart';

class CustomCategories extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int? index;
  final VoidCallback onTap;
  final int id;
  final double height, width;

  const CustomCategories(
      {Key? key,
      required this.imageUrl,
      required this.name,
      this.index,
      required this.height,
      required this.id,
      required this.width,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final borderRadius = UtilValues.borderRadius10.topLeft;
    return /* index != 0 ? */ GestureDetector(
      key: ValueKey(id),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            color: ColorsPalette.white,
            //borderRadius: UtilValues.borderRadius5,
            child: CachedNetworkImage(
              errorWidget: (context, url, error) => Container(
                height: 150.0,
                child: Icon(Icons.error),
              ),
              imageUrl: imageUrl,
              height: height,
              width: width,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 1,
            right: 5,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: ColorsPalette.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          UtilValues.gap8,
        ],
      ),
    ) /*: SizedBox()*/;
  }
}
