import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

/// Universal Exercise Media Viewer: Handles local assets, GIF animations,
/// backend static URLs, and remote web images seamlessly.
class ExerciseMediaWidget extends StatelessWidget {
  final String mediaUrl;
  final String? fallbackUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const ExerciseMediaWidget({
    super.key,
    required this.mediaUrl,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _buildImageContent(context);

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    return content;
  }

  Widget _buildImageContent(BuildContext context) {
    final cleanUrl = mediaUrl.trim();

    if (cleanUrl.isEmpty) {
      if (fallbackUrl != null && fallbackUrl!.trim().isNotEmpty) {
        return ExerciseMediaWidget(
          mediaUrl: fallbackUrl!,
          fit: fit,
          width: width,
          height: height,
          borderRadius: borderRadius,
          placeholder: placeholder,
        );
      }
      return _buildPlaceholder();
    }

    // 1. Direct Local Flutter Asset
    if (cleanUrl.startsWith('assets/')) {
      return Image.asset(
        cleanUrl,
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
        errorBuilder: (ctx, err, stack) {
          // If asset fails (e.g. on web dev server), try loading from local backend static host
          final backendUrl = '${ApiConstants.baseUrl}/$cleanUrl';
          return Image.network(
            backendUrl,
            fit: fit,
            width: width,
            height: height,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) {
              if (fallbackUrl != null && fallbackUrl!.isNotEmpty && fallbackUrl != mediaUrl) {
                return ExerciseMediaWidget(mediaUrl: fallbackUrl!, fit: fit, width: width, height: height);
              }
              return _buildPlaceholder();
            },
          );
        },
      );
    }

    // 2. HTTP/HTTPS Network URL
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
        errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF0F172A),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          );
        },
      );
    }

    // 3. Relative Path (e.g. "images/0001.jpg" or "videos/0001.gif")
    final assetPath = 'assets/exercises/$cleanUrl';
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (ctx, err, stack) {
        final backendUrl = '${ApiConstants.baseUrl}/exercises/$cleanUrl';
        return Image.network(
          backendUrl,
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Icon(Icons.fitness_center_rounded, color: Color(0xFF6366F1), size: 32),
      ),
    );
  }
}
