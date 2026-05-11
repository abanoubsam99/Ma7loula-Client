import 'dart:developer' as developer;

/// Utility class to fix common image URL issues throughout the app
class ImageUrlFixer {
  static String fix(String url) {
    if (url.isEmpty) return '';
    
    // Debug print
    developer.log('=== DEBUG: Image URL Fixer ===');
    developer.log('Original URL: "$url"');
    
    // Check if the URL contains a filepath with an image extension
    if (url.contains('.jpg') || url.contains('.jpeg') || url.contains('.png') || 
        url.contains('.gif') || url.contains('.webp')) {
      
      // Split the URL into segments
      final segments = url.split('/');
      
      // First check if there are any duplicated segments next to each other
      List<String> cleanedSegments = [];
      String? lastSegment;
      for (final segment in segments) {
        // If this segment is the same as the last one and contains a file extension
        if (segment == lastSegment && 
            (segment.contains('.jpg') || segment.contains('.jpeg') || 
             segment.contains('.png') || segment.contains('.gif') || 
             segment.contains('.webp'))) {
          // Skip this duplicate
          developer.log('Found duplicate segment: $segment');
          continue;
        }
        cleanedSegments.add(segment);
        lastSegment = segment;
      }
      
      // Rebuild the URL without duplicates
      final cleanedUrl = cleanedSegments.join('/');
      
      // If we made changes, log and return
      if (cleanedUrl != url) {
        developer.log('Fixed URL with duplicates: $cleanedUrl');
        return cleanedUrl;
      }
      
      // Special case check for the specific error pattern
      if (url.contains('storage/products') && url.contains('.jpg/.jpg')) {
        final fixedUrl = url.replaceAll('.jpg/.jpg', '.jpg');
        developer.log('Fixed .jpg/.jpg pattern: $fixedUrl');
        return fixedUrl;
      }
    }
    
    // Check for duplicated filenames pattern (common issue)
    final RegExp duplicatePattern = RegExp(r'([^/]+\.[\w]+)/\1$');
    if (duplicatePattern.hasMatch(url)) {
      final match = duplicatePattern.firstMatch(url);
      if (match != null) {
        final fixedUrl = url.substring(0, url.length - match.group(1)!.length - 1);
        developer.log('Detected duplicated filename, fixed URL: $fixedUrl');
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
        developer.log('Removed duplicated segment from URL: $fixedUrl');
        return fixedUrl;
      }
    }
    
    // Handle other URL issues
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) {
        final fixedUrl = 'https://api.ma7loula.com$url';
        developer.log('Added base URL to relative path: $fixedUrl');
        return fixedUrl;
      } else {
        final fixedUrl = 'https://api.ma7loula.com/$url';
        developer.log('Added complete base URL: $fixedUrl');
        return fixedUrl;
      }
    }
    
    developer.log('URL appears valid, no changes needed');
    developer.log('===========================');
    return url;
  }
}
