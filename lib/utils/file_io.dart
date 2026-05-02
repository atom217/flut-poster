import 'dart:io';
import 'package:flutter/widgets.dart';

ImageProvider? fileImageProvider(String path) {
  final f = File(path);
  return f.existsSync() ? FileImage(f) : null;
}

bool fileExists(String path) => File(path).existsSync();
