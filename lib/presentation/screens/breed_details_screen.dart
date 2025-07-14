import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styling/app_text_styles.dart';
import '../styling/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/models/dog_breed.dart';

class BreedDetailsScreen extends StatelessWidget {
  final DogBreed breed;
  final String? description;
  final List<String>? galleryImages;
  final String? funFact;
  const BreedDetailsScreen({
    Key? key,
    required this.breed,
    this.description,
    this.galleryImages,
    this.funFact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name, style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'breed_image_${breed.name}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  breed.imageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/dog_placeholder.png',
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Баннер офлайн-режима
            if (ModalRoute.of(context)?.settings.arguments is Map &&
                (ModalRoute.of(context)?.settings.arguments as Map)['isOffline'] == true)
              Container(
                width: double.infinity,
                color: AppColors.warning,
                padding: const EdgeInsets.all(8),
                child: Text(
                  l10n.offlineMode,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
              ),
            // Анимация для остального контента
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(breed.name, style: AppTextStyles.breedTitle),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    description?.isNotEmpty == true
                      ? description!
                      : (funFact ?? l10n.funFactTitle),
                    style: AppTextStyles.breedSubtitle,
                  ),
                ),
                const SizedBox(height: 24),
                if (galleryImages != null && galleryImages!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(l10n.galleryTitle, style: AppTextStyles.breedSubtitle),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: galleryImages!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final img = galleryImages![index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            img,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: AppColors.accent,
                              child: Icon(Icons.error, color: AppColors.text),
                            ),
                          ),
                        ).animate().fade(duration: 400.ms);
                      },
                    ),
                  ),
                ],
              ],
            ).animate().fade(duration: 500.ms).scale(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
