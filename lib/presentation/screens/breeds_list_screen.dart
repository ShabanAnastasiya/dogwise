import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/breeds_list/breeds_list_bloc.dart';
import '../../bloc/breeds_list/breeds_list_event.dart';
import '../../bloc/breeds_list/breeds_list_state.dart';
import '../widgets/shimmer_loader.dart';
import '../styling/app_text_styles.dart';
import '../styling/app_colors.dart';
import 'breed_details_screen.dart';

class BreedsListScreen extends StatelessWidget {
  const BreedsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.breedsListTitle, style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<BreedsListBloc, BreedsListState>(
        builder: (context, state) {
          if (state is BreedsListLoading) {
            return const ShimmerLoader();
          } else if (state is BreedsListLoaded || state is BreedsListLoadingMore) {
            final breeds = state is BreedsListLoaded ? state.breeds : (state as BreedsListLoadingMore).breeds;
            final page = state is BreedsListLoaded ? state.page : (state as BreedsListLoadingMore).page;
            final hasMore = state is BreedsListLoaded ? state.hasMore : true;
            final isOffline = state is BreedsListLoaded && state.isFromCache;
            return Column(
              children: [
                if (isOffline)
                  Container(
                    width: double.infinity,
                    color: AppColors.warning,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      AppLocalizations.of(context)!.offlineMode,
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 && hasMore) {
                        context.read<BreedsListBloc>().add(FetchBreedsPage(page + 1));
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: breeds.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == breeds.length && hasMore) {
                          // Индикатор загрузки при пагинации
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final breed = breeds[index];
                        // Анимация появления новых элементов
                        return GestureDetector(
                          onTap: () async {
                            final repo = context.read<BreedsListBloc>().repository;
                            final description = await repo.getBreedDescription(breed.name);
                            final gallery = await repo.getBreedGallery(breed.name);
                            final funFact = await repo.getFunFact();
                            final isOffline = state is BreedsListLoaded && state.isFromCache;
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                                  opacity: animation,
                                  child: BreedDetailsScreen(
                                    breed: breed,
                                    description: description,
                                    galleryImages: gallery,
                                    funFact: funFact,
                                  ),
                                ),
                                settings: RouteSettings(arguments: {'isOffline': isOffline}),
                              ),
                            );
                          },
                          child: Animate(
                            effects: [FadeEffect(duration: 400.ms), SlideEffect(duration: 400.ms)],
                            child: ListTile(
                              leading: Hero(
                                tag: 'breed_image_${breed.name}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    breed.imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/dog_placeholder.png',
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(breed.name, style: AppTextStyles.breedTitle),
                              tileColor: AppColors.primary,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is BreedsListEmpty) {
            return Center(child: Text(l10n.noData, style: AppTextStyles.emptyText));
          } else if (state is BreedsListError) {
            final isOffline = state.message == 'offlineMessage';
            return Center(child: Text(
              isOffline ? l10n.offlineMessage : l10n.errorMessage,
              style: AppTextStyles.errorText,
            ));
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<BreedsListBloc>().add(FetchBreeds()),
        child: const Icon(Icons.refresh),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.text,
      ),
    );
  }
}
