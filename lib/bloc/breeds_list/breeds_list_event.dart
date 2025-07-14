import 'package:equatable/equatable.dart';

abstract class BreedsListEvent extends Equatable {
  const BreedsListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBreeds extends BreedsListEvent {}

class FetchBreedsPage extends BreedsListEvent {
  final int page;
  FetchBreedsPage(this.page);

  @override
  List<Object?> get props => [page];
}
