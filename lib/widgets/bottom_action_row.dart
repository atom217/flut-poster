import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/providers.dart';
import '../services/video_service.dart';
import '../utils/app_strings.dart';
import 'package:universal_html/html.dart' as html;

class BottomActionRow extends ConsumerWidget {
  const BottomActionRow({super.key});

  Future<String?> _generateImage(BuildContext context, WidgetRef ref) async {
    try {
      final controller = ref.read(screenshotControllerProvider);
      final Uint8List? imageBytes = await controller.capture(); // Capture as bytes

      if (imageBytes == null) {
        // Handle case where capture failed
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.failedToCaptureImage), backgroundColor: Colors.red),
          );
        }
        return null;
      }

      if (kIsWeb) {
        // Web download logic using blob URL
        final blob = html.Blob([imageBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Trigger download
        html.AnchorElement(href: url)
          ..setAttribute("download", AppStrings.posterFileName)
          ..click();

        return "web_download_initiated"; 
      } else {
        // Mobile download logic
        final directory = await getTemporaryDirectory();
        final String fileName = 'jai_bhim_${DateTime.now().millisecondsSinceEpoch}.png';
        final String? path = await controller.captureAndSave(
          directory.path,
          fileName: fileName,
          pixelRatio: 3.0, // High quality
        );
        return path;
      }
    } catch (e) {
      debugPrint('Error generating image: $e'); // Log error for debugging
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.failedToGenerateImagePrefix}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _handleDownload(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.preparingImageForDownload),
        duration: Duration(milliseconds: 700),
      ),
    );

    final String? result = await _generateImage(context, ref);

    if (result != null && context.mounted) {
      if (result == "web_download_initiated") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.downloadInitiated),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.imageSavedToPrefix}${result.split('/').last}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: AppStrings.ok,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleShare(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.preparingImageForSharing),
        duration: Duration(milliseconds: 700),
      ),
    );

    final String? path = await _generateImage(context, ref);

    if (path != null && context.mounted) {
      // share_plus does not support file sharing on the web currently
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.sharingNotSupportedWeb),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (path != "web_download_initiated") { // Ensure it's not the web download indicator
        await Share.shareXFiles(
          [XFile(path)],
          text: AppStrings.shareText,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.cannotShareWeb),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleVideoExport(BuildContext context, WidgetRef ref) async {
    final musicPath = ref.read(editorProvider).musicPath;
    if (musicPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select music first to export as video.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating video...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final controller = ref.read(screenshotControllerProvider);
      final directory = await getTemporaryDirectory();
      final imagePath = await controller.captureAndSave(
        directory.path,
        fileName: 'temp_poster_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (imagePath != null) {
        final videoPath = await VideoService.generateStatusVideo(
          imagePath: imagePath,
          audioPath: musicPath,
        );

        if (context.mounted) Navigator.pop(context); // Close progress dialog

        if (videoPath != null && context.mounted) {
          await Share.shareXFiles(
            [XFile(videoPath)],
            text: AppStrings.shareText,
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate video.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasMusic = ref.watch(editorProvider).musicPath != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: Icons.share,
            label: AppStrings.shareLabel,
            onTap: () => _handleShare(context, ref),
          ),
          _buildActionButton(
            context,
            icon: Icons.download,
            label: AppStrings.downloadLabel,
            onTap: () => _handleDownload(context, ref),
          ),
          if (!kIsWeb && hasMusic)
            _buildActionButton(
              context,
              icon: Icons.videocam,
              label: 'Video',
              onTap: () => _handleVideoExport(context, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: IconButton(
            icon: Icon(icon, color: Theme.of(context).primaryColor),
            onPressed: onTap,
            tooltip: label, // Added tooltip for accessibility
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
