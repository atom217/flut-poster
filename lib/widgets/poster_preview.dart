import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/providers.dart';
import '../utils/app_strings.dart';
import '../utils/file_stub.dart' if (dart.library.io) '../utils/file_io.dart';

class PosterPreview extends ConsumerWidget {
  final Quote quote;

  const PosterPreview({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = ref.watch(selectedTemplateProvider);
    final editorSettings = ref.watch(editorProvider);
    final user = ref.watch(userProfileProvider);
    final photoUrl = user.photoUrl;

    final backgroundImageUrl = editorSettings.backgroundImageUrl;

    // Function to get image provider based on platform
    ImageProvider? getBackgroundImageProvider(String? url) {
      if (url == null) return null;
      if (kIsWeb) {
        return NetworkImage(url);
      } else {
        return fileImageProvider(url);
      }
    }

    final bgImageProvider = getBackgroundImageProvider(backgroundImageUrl);

    // Function to get the image widget based on platform
    Widget getImageWidget(String? url, Color textColor) {
      if (url == null) {
        return Icon(Icons.person, color: textColor, size: 20);
      }

      if (kIsWeb) {
        // On web, url is a blob URL or data URL
        // Use NetworkImage for web URLs. If it's a local path from web picker, it might be a blob URL
        // For simplicity, assuming it's a path that can be directly used by Image.network or Image.asset if it were an asset
        // In a real scenario, web path handling might need more nuance.
        // For now, let's try NetworkImage, as XFile.path on web often yields a usable URL.
        // If it's a data URL, Image.memory could be used.
        return Image.network(
          url, // Assuming url is a valid web path/blob URL
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: textColor, size: 20),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Icon(Icons.person, color: textColor, size: 20); // Placeholder while loading
          },
        );
      } else {
        // On mobile: use file-based image via abstracted helper
        final provider = fileImageProvider(url);
        if (provider != null) {
          return Image(
            image: provider,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: textColor, size: 20),
          );
        }
        return Icon(Icons.person, color: textColor, size: 20);
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: template.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        image: bgImageProvider != null
            ? DecorationImage(
                image: bgImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: bgImageProvider == null && template.gradientColors != null
            ? LinearGradient(
                colors: template.gradientColors!,
                begin: template.gradientBegin ?? Alignment.topLeft,
                end: template.gradientEnd ?? Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            // User Profile Section (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: getImageWidget(photoUrl, template.textColor), // Use helper function
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: template.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.subtitle,
                        style: TextStyle(
                          color: template.textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Quote Content (Center)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quote.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: template.textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      width: 40,
                      color: template.textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${AppStrings.quoteAuthorPrefix}${quote.author}',
                      style: TextStyle(
                        color: template.textColor.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Layered Design Element (Bottom Right Decoration)
            Positioned(
              bottom: -20,
              right: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.format_quote,
                  size: 150,
                  color: template.textColor,
                  semanticLabel: 'Decorative Quote Icon',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
