import 'package:flutter/material.dart';

class ImageUtils {
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'assets/images/default_course.png';
    }
    
    // Handle URLs
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Handle local assets
    if (imagePath.startsWith('assets/')) {
      return imagePath;
    }
    
    // Handle relative paths
    return 'assets/images/$imagePath';
  }

  static Widget getImageWidget(String? imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    final url = getImageUrl(imagePath);
    
    // If it's a network URL, use NetworkImage
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage(width, height, fit);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    
    // Otherwise use AssetImage
    return Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultImage(width, height, fit);
      },
    );
  }

  static Widget _buildDefaultImage(double? width, double? height, BoxFit fit) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: width != null ? width / 2 : 24,
        color: Colors.grey[600],
      ),
    );
  }
} 