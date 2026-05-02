import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/providers.dart';
import '../utils/file_stub.dart' if (dart.library.io) '../utils/file_io.dart';

class ProfileEditor extends ConsumerStatefulWidget {
  const ProfileEditor({super.key});

  @override
  ConsumerState<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<ProfileEditor> {
  late TextEditingController _nameController;
  late TextEditingController _subtitleController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: user.name);
    _subtitleController = TextEditingController(text: user.subtitle);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    ref.read(userProfileProvider.notifier).update((state) => state.copyWith(
          name: _nameController.text,
          subtitle: _subtitleController.text,
        ));
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        // On web, image.path is a blob URL. On mobile, it's a file path.
        ref.read(userProfileProvider.notifier).update((state) => state.copyWith(photoUrl: image.path));
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final photoUrl = user.photoUrl;

    // TODO: Use async validation for production apps to prevent main-thread jank.
    final hasValidPhoto = photoUrl != null && photoUrl.isNotEmpty &&
        (kIsWeb || fileExists(photoUrl));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Customization',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.amber.shade100,
                        backgroundImage: hasValidPhoto
                            ? (kIsWeb
                                ? NetworkImage(photoUrl!) as ImageProvider
                                : fileImageProvider(photoUrl!))
                            : null,
                        child: hasValidPhoto ? null : const Icon(Icons.person, color: Colors.amber, size: 30),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'User Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (_) => _updateProfile(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _subtitleController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Subtitle',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (_) => _updateProfile(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
