import 'package:equatable/equatable.dart';

abstract class FiltersEvent extends Equatable {
  const FiltersEvent();
  @override
  List<Object?> get props => [];
}

class SetBreedLetterFilter extends FiltersEvent {
  final String? letter;
  const SetBreedLetterFilter(this.letter);
  @override
  List<Object?> get props => [letter];
}

class ResetFilters extends FiltersEvent {}
