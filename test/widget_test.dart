// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogwise/main.dart';
import 'package:dogwise/core/models/dog_breed.dart';

class TestDogRepository {
  Future<List<DogBreed>> getBreeds() async {
    return [DogBreed(name: 'bulldog', imageUrl: 'https://images.dog.ceo/breeds/bulldog/n02096585_10047.jpg')];
  }
}

void main() {
  testWidgets('Breeds list loads and displays', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(dogRepository: TestDogRepository() as dynamic));
    await tester.pump(); // первый кадр
    await tester.pump(const Duration(seconds: 2)); // эмулируем загрузку
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('bulldog'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
