import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/models/dog_breed.dart';

class DogRemoteDatasource {
  final Dio dio;

  DogRemoteDatasource(this.dio);

  Future<List<DogBreed>> fetchBreeds() async {
    try {
      final response = await dio.get('https://dog.ceo/api/breeds/list/all');
      final breedsMap = response.data['message'] as Map<String, dynamic>;
      final List<DogBreed> breeds = [];
      for (final breed in breedsMap.keys) {
        final imageResponse = await dio.get('https://dog.ceo/api/breed/$breed/images/random');
        breeds.add(DogBreed(
          name: breed,
          imageUrl: imageResponse.data['message'] as String,
        ));
      }
      return breeds;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DogBreed>> fetchBreedsPaginated(int page, {int pageSize = 25}) async {
    try {
      final response = await dio.get('https://dog.ceo/api/breeds/list/all');
      final breedsMap = response.data['message'] as Map<String, dynamic>;
      final breedNames = breedsMap.keys.toList();
      final start = page * pageSize;
      final end = (start + pageSize).clamp(0, breedNames.length);
      final pageBreeds = breedNames.sublist(start, end);
      List<DogBreed> result = [];
      for (final breed in pageBreeds) {
        try {
          final imageResponse = await dio.get('https://dog.ceo/api/breed/$breed/images/random');
          result.add(DogBreed(
            name: breed,
            imageUrl: imageResponse.data['message'] as String,
          ));
        } catch (_) {
          result.add(DogBreed(
            name: breed,
            imageUrl: '', // fallback image
          ));
        }
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> fetchBreedDescription(String breed) async {
    // Dog CEO API не предоставляет описания, можно использовать заглушку или сторонний API
    return null;
  }

  Future<List<String>> fetchBreedGallery(String breed) async {
    try {
      final response = await dio.get('https://dog.ceo/api/breed/$breed/images');
      final images = (response.data['message'] as List<dynamic>).cast<String>();
      return images;
    } catch (e) {
      print('[DogRemoteDatasource] fetchBreedGallery error: $e');
      return [];
    }
  }

  Future<String> fetchFunFact() async {
    // Можно использовать статический список фактов или сторонний API
    const facts = [
      'Dogs have a sense of time and can miss their owners.',
      'A dog’s nose print is unique, much like a person’s fingerprint.',
      'Dogs can learn more than 1000 words and gestures.',
      'The Basenji is the only barkless dog.',
      'Three dogs survived the Titanic sinking.'
    ];
    final factsCopy = List<String>.from(facts);
    factsCopy.shuffle();
    return factsCopy.first;
  }

  Future<void> cacheBreeds(List<DogBreed> breeds) async {
    final box = await Hive.openBox('breeds_cache');
    await box.put('breeds', breeds.map((e) => e.toJson()).toList());
  }

  Future<List<DogBreed>> getCachedBreeds() async {
    final box = await Hive.openBox('breeds_cache');
    final cached = box.get('breeds');
    if (cached is List) {
      return cached.map((e) => DogBreed.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }
}
