import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dog_breed.g.dart';

@JsonSerializable()
class DogBreed extends Equatable {
  final String name;
  final String imageUrl;

  const DogBreed({
    required this.name,
    required this.imageUrl,
  });

  factory DogBreed.fromJson(Map<String, dynamic> json) => _$DogBreedFromJson(json);
  Map<String, dynamic> toJson() => _$DogBreedToJson(this);

  DogBreed copyWith({String? name, String? imageUrl}) {
    return DogBreed(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [name, imageUrl];
}
