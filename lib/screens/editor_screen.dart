import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import '../models/models.dart';
import '../services/providers.dart';
import '../utils/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/poster_preview.dart';
import '../widgets/bottom_action_row.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Quote quote;

  const EditorScreen({super.key, required this.quote});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = ref.read(audioPlayerProvider);
      player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });
    });
  }

  Future<void> _pickBackgroundImage(WidgetRef ref, BuildContext context) async {
    try {
      final picker = ImagePicker();
      final source = kIsWeb ? ImageSource.gallery : ImageSource.gallery; // Both use gallery for simplicity
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        ref.read(editorProvider.notifier).updateBackgroundImage(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking background image: $e')),
        );
      }
    }
  }

  Future<void> _pickMusic(WidgetRef ref, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null && context.mounted) {
        ref.read(editorProvider.notifier).updateMusic(result.files.single.path);
        // Automatically start playing
        _toggleMusic(ref);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking music: $e')),
        );
      }
    }
  }

  void _toggleMusic(WidgetRef ref) async {
    final player = ref.read(audioPlayerProvider);
    final musicPath = ref.read(editorProvider).musicPath;

    if (musicPath == null) return;

    if (_isPlaying) {
      await player.pause();
    } else {
      await player.play(DeviceFileSource(musicPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final settings = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    final colors = [
      0xFF3F51B5, // Indigo
      0xFFF44336, // Red
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFF000000, // Black
      0xFF673AB7, // Deep Purple
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editStatus),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Real-time Poster Preview
                  Screenshot(
                    controller: ref.watch(screenshotControllerProvider),
                    child: PosterPreview(quote: quote),
                  ),
                  const SizedBox(height: 16),
                  const BottomActionRow(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text Size Slider
                Row(
                  children: [
                    const Icon(Icons.format_size, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppStrings.textSize, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: settings.fontSize,
                  min: 16,
                  max: 40,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => notifier.updateFontSize(value),
                ),

                // Background Color Palette
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppStrings.backgroundColor, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      final colorValue = colors[index];
                      return GestureDetector(
                        onTap: () => notifier.updateColor(colorValue),
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: settings.backgroundColorValue == colorValue
                                ? Border.all(color: AppTheme.primaryColor, width: 2)
                                : Border.all(color: Colors.grey.shade300),
                          ),
                          child: settings.backgroundColorValue == colorValue
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Background Image Controls
                Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppStrings.backgroundImage, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: Text(settings.backgroundImageUrl == null
                            ? AppStrings.setBackgroundImage
                            : 'Change Image'),
                        onPressed: () => _pickBackgroundImage(ref, context),
                      ),
                    ),
                    if (settings.backgroundImageUrl != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => notifier.updateBackgroundImage(null),
                        tooltip: AppStrings.removeBackgroundImage,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Music Controls
                if (!kIsWeb) ...[
                  Row(
                    children: [
                      const Icon(Icons.music_note_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Music', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.audio_file_outlined),
                          label: Text(settings.musicPath == null
                              ? 'Set Music'
                              : 'Change Music'),
                          onPressed: () => _pickMusic(ref, context),
                        ),
                      ),
                      if (settings.musicPath != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                          onPressed: () => _toggleMusic(ref),
                          color: AppTheme.primaryColor,
                          iconSize: 32,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            ref.read(audioPlayerProvider).stop();
                            notifier.updateMusic(null);
                          },
                          tooltip: 'Remove Music',
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
