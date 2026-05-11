import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../utils/image_url_fixer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool enableFullScreenViewer;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.enableFullScreenViewer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check for empty URL before processing
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
        ),
      );
    }
    
    // Use the ImageUrlFixer utility to fix any URL issues
    final String processedImageUrl = ImageUrlFixer.fix(imageUrl);
    
    return GestureDetector(
      onTap: enableFullScreenViewer
          ? () {
        showImageViewer(
          context,
          CachedNetworkImageProvider(processedImageUrl),
        );
      }
          : null,
      child: CachedNetworkImage(
        imageUrl: processedImageUrl,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (context, url, error) {
          developer.log('Image loading error: $error for URL: $url');
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            ),
          );
        },
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
  
  // The old _ensureFullImageUrl method has been replaced by the ImageUrlFixer utility class
}

