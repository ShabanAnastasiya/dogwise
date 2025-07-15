import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> showPhotoPickerBottomSheet(BuildContext context) async {
  final picker = ImagePicker();
  return showModalBottomSheet<File?>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Сделать фото'),
            onTap: () async {
              final pickedFile = await picker.pickImage(source: ImageSource.camera);
              if (!context.mounted) return;
              if (pickedFile != null) {
                final file = File(pickedFile.path);
                Navigator.of(context).pop(file);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Выбрать из галереи'),
            onTap: () async {
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (!context.mounted) return;
              Navigator.of(context).pop(pickedFile != null ? File(pickedFile.path) : null);
            },
          ),
        ],
      ),
    ),
  );
}
