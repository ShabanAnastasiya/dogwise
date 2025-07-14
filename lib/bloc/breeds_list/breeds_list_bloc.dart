import 'package:flutter_bloc/flutter_bloc.dart';
import 'breeds_list_event.dart';
import 'breeds_list_state.dart';
import '../../data/repositories/dog_repository_impl.dart';
import '../../core/models/dog_breed.dart';

class BreedsListBloc extends Bloc<BreedsListEvent, BreedsListState> {
  final DogRepositoryImpl repository;

  BreedsListBloc(this.repository) : super(BreedsListInitial()) {
    on<FetchBreeds>(_onFetchBreeds);
    on<FetchBreedsPage>(_onFetchBreedsPage);
    add(FetchBreedsPage(0));
  }

  Future<void> _onFetchBreeds(FetchBreeds event, Emitter<BreedsListState> emit) async {
    print('[BLoC] FetchBreeds: start loading');
    emit(BreedsListLoading());
    try {
      final breeds = await repository.getBreedsPaginated(0);
      print('[BLoC] FetchBreeds: loaded from network, count: \'${breeds.length}\'');
      if (breeds.isEmpty) {
        emit(BreedsListEmpty());
      } else {
        emit(BreedsListLoaded(breeds, page: 0, hasMore: breeds.length == 25, isFromCache: false));
      }
    } catch (e) {
      print('[BLoC] FetchBreeds: error: $e');
      final cached = await repository.getBreedsPaginated(0);
      if (cached.isNotEmpty) {
        print('[BLoC] FetchBreeds: loaded from cache, count: \'${cached.length}\'');
        emit(BreedsListLoaded(cached, page: 0, hasMore: cached.length == 25, isFromCache: true));
      } else {
        print('[BLoC] FetchBreeds: no data available');
        emit(BreedsListError(e.toString()));
      }
    }
  }

  Future<void> _onFetchBreedsPage(FetchBreedsPage event, Emitter<BreedsListState> emit) async {
    print('[BLoC] FetchBreedsPage: page=${event.page}');
    final currentState = state;
    List<DogBreed> breeds = [];
    int page = event.page;
    if (currentState is BreedsListLoaded) {
      breeds = List.from(currentState.breeds);
      page = currentState.page + 1;
      emit(BreedsListLoadingMore(breeds, page));
    } else if (currentState is BreedsListLoadingMore) {
      breeds = List.from(currentState.breeds);
      page = currentState.page;
    } else {
      emit(BreedsListLoading());
    }
    try {
      final newBreeds = await repository.getBreedsPaginated(page);
      print('[BLoC] FetchBreedsPage: loaded from network, count: \'${newBreeds.length}\'');
      final hasMore = newBreeds.length == 25;
      breeds.addAll(newBreeds);
      if (breeds.isEmpty) {
        emit(BreedsListEmpty());
      } else {
        emit(BreedsListLoaded(breeds, page: page, hasMore: hasMore, isFromCache: false));
      }
    } catch (e) {
      print('[BLoC] FetchBreedsPage: error: $e');
      final cached = await repository.getBreedsPaginated(page);
      if (cached.isNotEmpty) {
        print('[BLoC] FetchBreedsPage: loaded from cache, count: \'${cached.length}\'');
        breeds.addAll(cached);
        emit(BreedsListLoaded(breeds, page: page, hasMore: cached.length == 25, isFromCache: true));
      } else {
        print('[BLoC] FetchBreedsPage: no data available');
        emit(BreedsListError('No data available'));
      }
    }
  }
}
