import 'package:equatable/equatable.dart';
import '../../core/models/dog_breed.dart';

abstract class BreedsListState extends Equatable {
  const BreedsListState();

  @override
  List<Object?> get props => [];
}

class BreedsListInitial extends BreedsListState {}
class BreedsListLoading extends BreedsListState {}
class BreedsListLoaded extends BreedsListState {
  final List<DogBreed> breeds;
  final bool isFromCache;
  const BreedsListLoaded(this.breeds, {this.isFromCache = false});

  @override
  List<Object?> get props => [breeds, isFromCache];
}
class BreedsListError extends BreedsListState {
  final String message;
  const BreedsListError(this.message);

  @override
  List<Object?> get props => [message];
}
class BreedsListEmpty extends BreedsListState {}

