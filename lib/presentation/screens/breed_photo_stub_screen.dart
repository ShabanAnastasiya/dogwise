import 'package:flutter/material.dart';

class BreedPhotoStubScreen extends StatelessWidget {
  const BreedPhotoStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Распознавание по фото')),
      body: const Center(
        child: Text(
          'Распознавание по фото отключено',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
