import 'package:equatable/equatable.dart';

abstract class BreedsListEvent extends Equatable {
  const BreedsListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBreeds extends BreedsListEvent {}

class RefreshBreeds extends BreedsListEvent {}
