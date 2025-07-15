import 'package:equatable/equatable.dart';

class FiltersState extends Equatable {
  final String? breedLetter;
  const FiltersState({this.breedLetter});
  FiltersState copyWith({String? breedLetter}) => FiltersState(breedLetter: breedLetter ?? this.breedLetter);
  @override
  List<Object?> get props => [breedLetter];
}
