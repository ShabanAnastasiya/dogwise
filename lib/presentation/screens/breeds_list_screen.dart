import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/breeds_list/breeds_list_bloc.dart';
import '../../bloc/breeds_list/breeds_list_event.dart';
import '../../bloc/breeds_list/breeds_list_state.dart';
import 'filters_screen.dart';
import '../../bloc/filters/filters_state.dart';
import '../../bloc/filters/filters_bloc.dart';
import '../widgets/shimmer_loader.dart';
import '../styling/app_text_styles.dart';
import '../styling/app_colors.dart';
import 'breed_details_screen.dart';


class BreedsListScreen extends StatefulWidget {
  const BreedsListScreen({super.key});

  @override
  State<BreedsListScreen> createState() => _BreedsListScreenState();
}

class _BreedsListScreenState extends State<BreedsListScreen> {
  String? _breedLetter;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => FiltersBloc(),
          child: const FiltersScreen(),
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result is FiltersState) {
      setState(() {
        _breedLetter = result.breedLetter;
      });
    }
  }

  Widget _buildHighlightedText(String text, String query, ThemeData theme) {
    if (query.isEmpty) {
      return Text(text, style: AppTextStyles.breedTitle.copyWith(color: theme.colorScheme.onSurface));
    }
    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int index;
    final accentColor = theme.colorScheme.secondary;
    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        matches.add(TextSpan(
          text: text.substring(start, index),
          style: AppTextStyles.breedTitle.copyWith(color: theme.colorScheme.onSurface),
        ));
      }
      matches.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: AppTextStyles.breedTitle.copyWith(color: accentColor, fontWeight: FontWeight.bold),
      ));
      start = index + query.length;
    }
    if (start < text.length) {
      matches.add(TextSpan(
        text: text.substring(start),
        style: AppTextStyles.breedTitle.copyWith(color: theme.colorScheme.onSurface),
      ));
    }
    return RichText(text: TextSpan(children: matches));
  }

  @override
  Widget build(BuildContext context) {


    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.breedsListTitle, style: AppTextStyles.appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<BreedsListBloc, BreedsListState>(
        builder: (context, state) {
          if (state is BreedsListLoading) {
            return const ShimmerLoader();
          } else if (state is BreedsListLoaded) {
            final allBreeds = state.breeds;
            final isOffline = state.isFromCache;
            // Фильтрация по первой букве и поиску
            List filteredBreeds = allBreeds;
            if (_breedLetter != null && _breedLetter!.isNotEmpty) {
              filteredBreeds = filteredBreeds.where((b) => b.name.toUpperCase().startsWith(_breedLetter!)).toList();
            }
            if (_searchText.isNotEmpty) {
              filteredBreeds = filteredBreeds.where((b) => b.name.toLowerCase().contains(_searchText.toLowerCase())).toList();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchText = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
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
                if (_breedLetter != null && _breedLetter!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Letter: $_breedLetter',
                          style: AppTextStyles.body.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.accent
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _breedLetter = null),
                          tooltip: l10n.resetButton,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredBreeds.length,
                    itemBuilder: (context, index) {
                      final breed = filteredBreeds[index];
                      // Анимация появления новых элементов
                      return GestureDetector(
                        onTap: () async {
                          final repo = context.read<BreedsListBloc>().repository;
                          final description = await repo.getBreedDescription(breed.name);
                          final gallery = await repo.getBreedGallery(breed.name);
                          final funFact = await repo.getFunFact();
                          final isOffline = state.isFromCache;
                          if (!context.mounted) return;
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
      child: isOffline
        ? Image.asset(
            'assets/dog_placeholder.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          )
        : Image.network(
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
  title: _searchText.isEmpty
      ? Text(
          breed.name,
          style: AppTextStyles.breedTitle.copyWith(color: Theme.of(context).colorScheme.onSurface),
        )
      : _buildHighlightedText(breed.name, _searchText, Theme.of(context)),
  tileColor: Theme.of(context).colorScheme.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

)
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is BreedsListEmpty) {
            return Center(child: Text(l10n.noData, style: AppTextStyles.emptyText));
          } else if (state is BreedsListError) {
            return Center(child: Text(
              l10n.errorMessage,
              style: AppTextStyles.errorText,
            ));
          }
          return Container();
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          FloatingActionButton(
            heroTag: 'filters',
            onPressed: () => _openFilters(context),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: AppColors.text,
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () => context.read<BreedsListBloc>().add(RefreshBreeds()),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: AppColors.text,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
