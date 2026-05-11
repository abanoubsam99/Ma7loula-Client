import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/widgets/fixed_cached_network_image.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';

class Services extends StatefulWidget {
  String? image;
  String title;
  double? height;
  final VoidCallback onTap;

  Services(
      {Key? key,
      required this.image,
      required this.title,
      this.height,
      required this.onTap})
      : super(key: key);

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(
            left: 4,
            right: 4,
          ),
          // padding: EdgeInsets.only(left: 5.sp, right: 5.sp,),
          child: Stack(
            children: [
              InkResponse(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(builder: (context) {
                    // Process the image URL to ensure it's valid
                    String imageUrl = widget.image ?? '';
                    imageUrl = imageUrl.trim();
                    
                    // Debug print to see what's happening
                    print('=== DEBUG: Services Widget Image URL ===');
                    print('Original image URL: "$imageUrl"');
                    
                    // Use default image for empty URLs
                    if (imageUrl.isEmpty) {
                      print('Using default placeholder image');
                      imageUrl = 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png';
                    } 
                    // Add base URL for relative paths
                    else if (imageUrl.startsWith('/')) {
                      print('Converting relative URL to absolute');
                      imageUrl = 'https://api.ma7loula.com$imageUrl';
                    }
                    // If URL doesn't have a scheme, add one
                    else if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
                      print('Adding https:// prefix to URL');
                      imageUrl = 'https://api.ma7loula.com/$imageUrl';
                    }
                    
                    print('Final processed URL: $imageUrl');
                    print('======================================');
                    
                    // Use our fixed image widget to handle problematic URLs
                    print('Loading category image URL: "${widget.image ?? ''}"');
                    return FixedCachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      height: widget.height ?? 15.h,
                      width: double.maxFinite,
                      errorWidget: (context, url, error) {
                        print('Image loading error: $error for URL: $url');
                        return Container(
                          height: widget.height ?? 15.h,
                          width: double.maxFinite,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        ColorsPalette.black.withOpacity(0.7),
                        ColorsPalette.black.withOpacity(0.7),
                        ColorsPalette.primaryColor.withOpacity(.7)
                      ],
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: ColorsPalette.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
