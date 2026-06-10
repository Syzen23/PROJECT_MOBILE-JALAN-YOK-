import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedAppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, width: width, height: height, fit: fit);
    }

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return Image.file(File(imageUrl), width: width, height: height, fit: fit);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultError(width: width, height: height),
    );
  }

  static Widget _defaultPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF007AFF),
          ),
        ),
      ),
    );
  }

  static Widget _defaultError({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.landscape, color: Colors.grey, size: 32),
      ),
    );
  }
}

ImageProvider appImageProvider(String? path) {
  final image = path == null || path.isEmpty
      ? 'assets/images/Pantai.png'
      : path;

  if (image.startsWith('http://') || image.startsWith('https://')) {
    return CachedNetworkImageProvider(image);
  }
  if (image.startsWith('assets/')) {
    return AssetImage(image);
  }
  return FileImage(File(image));
}
