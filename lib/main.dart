import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/style/color.dart';
import 'presentation/styling/app_colors.dart';
import 'presentation/style/text_style.dart';
import 'presentation/screens/breeds_list_screen.dart';
import 'bloc/breeds_list/breeds_list_bloc.dart';
import 'bloc/breeds_list/breeds_list_event.dart';
import 'data/datasources/dog_remote_datasource.dart';
import 'data/repositories/dog_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/services/connectivity_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'core/notifiers/theme_notifier.dart';
import 'core/notifiers/language_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  final dio = Dio();
  final dogRemoteDatasource = DogRemoteDatasource(dio);
  final connectivityService = ConnectivityService();
  final dogRepository = DogRepositoryImpl(dogRemoteDatasource, connectivityService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LanguageNotifier()),
      ],
      child: MyApp(dogRepository: dogRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DogRepositoryImpl dogRepository;
  const MyApp({super.key, required this.dogRepository});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    return MaterialApp(
      title: 'DogWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: GTColor.primary),
        scaffoldBackgroundColor: GTColor.background,
        textTheme: TextTheme(
          displayLarge: GTTextStyle.heading,
          bodyLarge: GTTextStyle.body,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkAccent,
          surface: AppColors.darkBackground,
          secondary: AppColors.darkAccent,
          onSurface: AppColors.darkText,
          onPrimary: AppColors.darkText,
          onSecondary: AppColors.darkText,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: TextTheme(
          displayLarge: GTTextStyle.heading.copyWith(color: AppColors.darkText),
          bodyLarge: GTTextStyle.body.copyWith(color: AppColors.darkText),
        ),
      ),
      themeMode: themeNotifier.themeMode,
      locale: languageNotifier.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: BlocProvider(
        create: (_) => BreedsListBloc(dogRepository)..add(FetchBreeds()),
        child: const BreedsListScreen(),
      ),
    );
  }
}
