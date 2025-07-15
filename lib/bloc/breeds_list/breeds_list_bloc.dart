import 'package:flutter_bloc/flutter_bloc.dart';
import 'breeds_list_event.dart';
import 'breeds_list_state.dart';
import '../../data/repositories/dog_repository_impl.dart';


class BreedsListBloc extends Bloc<BreedsListEvent, BreedsListState> {
  final DogRepositoryImpl repository;

  BreedsListBloc(this.repository) : super(BreedsListInitial()) {
    on<FetchBreeds>(_onFetchBreeds);
    on<RefreshBreeds>(_onRefreshBreeds);
    add(FetchBreeds());
  }

  Future<void> _onFetchBreeds(FetchBreeds event, Emitter<BreedsListState> emit) async {

    emit(BreedsListLoading());
    try {
      final breeds = await repository.getBreeds();

      if (breeds.isEmpty) {
        emit(BreedsListEmpty());
      } else {
        emit(BreedsListLoaded(breeds, isFromCache: false));
      }
    } catch (e) {

      final cached = await repository.getBreeds();
      if (cached.isNotEmpty) {

        emit(BreedsListLoaded(cached, isFromCache: true));
      } else {

        emit(BreedsListError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshBreeds(RefreshBreeds event, Emitter<BreedsListState> emit) async {

    emit(BreedsListLoading());
    try {
      final breeds = await repository.getBreeds(forceNetwork: true);

      emit(BreedsListLoaded(breeds, isFromCache: false));
    } catch (e) {

      emit(BreedsListError(e.toString()));
    }
  }


}
