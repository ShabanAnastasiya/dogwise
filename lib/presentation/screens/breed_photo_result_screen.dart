import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/dog_breed.dart';

class BreedPhotoResultScreen extends StatelessWidget {
  final File imageFile;
  final String? breedName;
  final DogBreed? breedInfo;
  final bool isLoading;
  final String? error;

  const BreedPhotoResultScreen({
    super.key,
    required this.imageFile,
    this.breedName,
    this.breedInfo,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Результат поиска по фото')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile, width: 220, height: 220, fit: BoxFit.cover),
            const SizedBox(height: 24),
            if (isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Определяем породу, пожалуйста, подождите...'),
            ] else if (error != null) ...[
              Icon(Icons.error, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ] else if (breedInfo != null) ...[
              Text(breedInfo!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (breedInfo!.imageUrl.isNotEmpty)
                Image.network(breedInfo!.imageUrl, width: 120, height: 120, fit: BoxFit.cover),
            ] else if (breedName != null) ...[
              Text(breedName!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Информация о породе не найдена в базе.'),
            ] else ...[
              const Text('Не удалось определить породу по фото.'),
            ],
          ],
        ),
      ),
    );
  }
}
