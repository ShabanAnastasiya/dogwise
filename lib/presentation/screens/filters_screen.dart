import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../bloc/filters/filters_bloc.dart';
import '../../bloc/filters/filters_event.dart';
import '../../bloc/filters/filters_state.dart';
import '../../core/notifiers/theme_notifier.dart';
import '../../core/notifiers/language_notifier.dart';
import '../styling/app_text_styles.dart';
import '../styling/app_colors.dart';

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;
    final locale = languageNotifier.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterTitle, style: AppTextStyles.appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<FiltersBloc, FiltersState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filterTitle,
                  style: AppTextStyles.breedTitle.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),

                const SizedBox(height: 24),
                Text(
                  l10n.filterLetter,
                  style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: state.breedLetter,
                  hint: Text(l10n.filterLetter, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: List.generate(26, (i) {
                    final letter = String.fromCharCode(65 + i);
                    return DropdownMenuItem(
                      value: letter,
                      child: Text(letter, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    );
                  }),
                  selectedItemBuilder: (context) {
                    return List.generate(26, (i) {
                      final letter = String.fromCharCode(65 + i);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      );
                    });
                  },
                  onChanged: (val) {
                    context.read<FiltersBloc>().add(SetBreedLetterFilter(val));
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(l10n.themeLabel, style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (val) {
                        themeNotifier.setTheme(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    Text(isDark ? l10n.darkTheme : l10n.lightTheme, style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.languageLabel, style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    const Spacer(),
                    DropdownButton<Locale>(
  value: locale,
  dropdownColor: Theme.of(context).colorScheme.surface,
  items: [
    DropdownMenuItem(
      value: const Locale('en'),
      child: Text(l10n.english, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    ),
    DropdownMenuItem(
      value: const Locale('ru'),
      child: Text(l10n.russian, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    ),
  ],
  onChanged: (loc) {
    if (loc != null) languageNotifier.setLocale(loc);
  },
),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
  child: ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(state);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
    ),
    child: Text(l10n.applyButton),
  ),
),
                    const SizedBox(width: 16),
                    Expanded(
  child: OutlinedButton(
    onPressed: () {
      context.read<FiltersBloc>().add(ResetFilters());
      themeNotifier.setTheme(ThemeMode.light);
      languageNotifier.setLocale(const Locale('en'));
    },
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accent,
    ),
    child: Text(l10n.resetButton),
  ),
),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
