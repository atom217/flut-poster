import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/providers.dart';

class EditorScreen extends ConsumerWidget {
  final Quote quote;

  const EditorScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Text('Edit Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality to be implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(settings.backgroundColorValue),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quote.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '- ${quote.author}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Text Size', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: settings.fontSize,
                  min: 16,
                  max: 40,
                  onChanged: (value) => notifier.updateFontSize(value),
                ),
                const Text('Background Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      final colorValue = colors[index];
                      return GestureDetector(
                        onTap: () => notifier.updateColor(colorValue),
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: settings.backgroundColorValue == colorValue
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
