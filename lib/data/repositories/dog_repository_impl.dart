import '../datasources/dog_remote_datasource.dart';
import '../../core/models/dog_breed.dart';
import '../../core/services/connectivity_service.dart';

class DogRepositoryImpl {
  final DogRemoteDatasource remoteDatasource;
  final ConnectivityService connectivityService;

  DogRepositoryImpl(this.remoteDatasource, this.connectivityService);

  Future<List<DogBreed>> getBreeds() async {
    return await remoteDatasource.fetchBreeds();
  }

  Future<List<DogBreed>> getBreedsPaginated(int page, {int pageSize = 25, bool forceNetwork = false}) async {
    final isConnected = await connectivityService.isConnected();
    final cached = await remoteDatasource.getCachedBreeds();
    // 1. Если онлайн — загружаем из сети
    if (isConnected) {
      try {
        final breeds = await remoteDatasource.fetchBreedsPaginated(page, pageSize: pageSize);
        if (page == 0 && breeds.isNotEmpty) {
          final allBreeds = await remoteDatasource.fetchBreeds();
          await remoteDatasource.cacheBreeds(allBreeds);
        }
        return breeds;
      } catch (e) {
        // Если ошибка сети, но есть кэш — отдаём кэш
        if (cached.isNotEmpty) {
          return cached.skip(page * pageSize).take(pageSize).toList();
        }
        throw Exception('Network error: $e');
      }
    }
    // 2. Если офлайн и кэш есть — отдаём кэш
    if (cached.isNotEmpty) {
      return cached.skip(page * pageSize).take(pageSize).toList();
    }
    // 3. Если офлайн и кэша нет — ошибка
    throw Exception('No internet connection and no cached data');
  }

  Future<String?> getBreedDescription(String breed) async {
    return await remoteDatasource.fetchBreedDescription(breed);
  }

  Future<List<String>> getBreedGallery(String breed) async {
    return await remoteDatasource.fetchBreedGallery(breed);
  }

  Future<String> getFunFact() async {
    return await remoteDatasource.fetchFunFact();
  }
}
