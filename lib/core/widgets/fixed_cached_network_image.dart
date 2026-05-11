import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A simplified image widget that automatically fixes common URL issues
class FixedCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final Widget Function(BuildContext, String)? placeholder;

  const FixedCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Apply URL fixes directly here
    final fixedUrl = _fixImageUrl(imageUrl);
    
    // Forward to the standard CachedNetworkImage with the fixed URL
    return CachedNetworkImage(
      imageUrl: fixedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? ((context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            strokeWidth: 2,
          ),
        ),
      )),
      errorWidget: errorWidget ?? ((context, url, error) {
        print('Image loading error: $error for URL: $url');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
          ),
        );
      }),
    );
  }

  /// Fixes common issues with image URLs
  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';
    
    print('=== DEBUG: FixedCachedNetworkImage processing URL ===');
    print('Original URL: "$url"');
    
    // Direct fix for the specific pattern we're seeing in the logs
    if (url.contains('/cb1f310e2647254ecb92ab8e8328de7b27c07b51.jpg/cb1f310e2647254ecb92ab8e8328de7b27c07b51.jpg')) {
      final fixedUrl = url.replaceAll('/cb1f310e2647254ecb92ab8e8328de7b27c07b51.jpg/cb1f310e2647254ecb92ab8e8328de7b27c07b51.jpg', 
                                     '/cb1f310e2647254ecb92ab8e8328de7b27c07b51.jpg');
      print('Fixed known problematic URL: $fixedUrl');
      return fixedUrl;
    }
    
    // Check for duplicated filenames pattern (common issue)
    final RegExp duplicatePattern = RegExp(r'([^/]+\.[\w]+)/\1$');
    if (duplicatePattern.hasMatch(url)) {
      final match = duplicatePattern.firstMatch(url);
      if (match != null) {
        final fixedUrl = url.substring(0, url.length - match.group(1)!.length - 1);
        print('Detected duplicated filename, fixed URL: $fixedUrl');
        return fixedUrl;
      }
    }
    
    // Additional check for any repeated segments in the URL
    final segments = url.split('/');
    if (segments.length >= 2) {
      final lastSegment = segments.last;
      final secondLastSegment = segments[segments.length - 2];
      
      if (lastSegment == secondLastSegment && lastSegment.contains('.')) {
        // Remove the duplicated last segment
        segments.removeLast();
        final fixedUrl = segments.join('/');
        print('Removed duplicated segment from URL: $fixedUrl');
        return fixedUrl;
      }
    }
    
    // Handle other URL issues
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) {
        final fixedUrl = 'https://api.ma7loula.com$url';
        print('Added base URL to relative path: $fixedUrl');
        return fixedUrl;
      } else {
        final fixedUrl = 'https://api.ma7loula.com/$url';
        print('Added complete base URL: $fixedUrl');
        return fixedUrl;
      }
    }
    
    print('URL appears valid, no changes needed');
    print('==================================================');
    return url;
  }
}
