import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/providers.dart';

Future<void> pickAndSetProfilePhoto(WidgetRef ref, BuildContext context) async {
  final picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(userProfileProvider.notifier).update(
        (state) => state.copyWith(photoUrl: image.path),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}
