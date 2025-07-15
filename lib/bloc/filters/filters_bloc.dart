import 'package:flutter_bloc/flutter_bloc.dart';
import 'filters_event.dart';
import 'filters_state.dart';

class FiltersBloc extends Bloc<FiltersEvent, FiltersState> {
  FiltersBloc() : super(const FiltersState()) {
    on<SetBreedLetterFilter>((event, emit) {
      emit(state.copyWith(breedLetter: event.letter));
    });
    on<ResetFilters>((event, emit) {
      emit(const FiltersState());
    });
  }
}
