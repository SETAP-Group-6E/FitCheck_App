import 'package:fitcheck/Domain/repositories/wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/wardrobe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWardrobeRepository implements WardrobeRepository {
  int addClothingItemCalls = 0;
  int addOutfitCalls = 0;

  @override
  Future<void> addClothingItem({
    required String photoUrl,
    required String title,
    required String wearType,
    required String fabricMaterial,
    required int warmthRating,
    required bool waterResistance,
    required String layerCategory,
  }) async {
    addClothingItemCalls++;
  }

  @override
  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  }) async {
    addOutfitCalls++;
  }

  @override
  Future<List<Map<String, dynamic>>> getClothingItems() async => [];

  @override
  Future<List<Map<String, dynamic>>> getOutfits() async => [];

  @override
  Future<void> removeClothingItem({required String id}) async {}

  @override
  Future<void> removeOutfit({required String id}) async {}

  @override
  Future<void> updateClothingItem({
    required String id,
    String? photoUrl,
    String? title,
    String? wearType,
    String? fabricMaterial,
    int? warmthRating,
    bool? waterResistance,
    String? layerCategory,
  }) async {}

  @override
  Future<void> updateOutfit({
    required String id,
    String? name,
    String? description,
    bool? isOwned,
    List<String>? clothingItemIds,
  }) async {}
}

void setUpMobileScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> pumpWardrobePage(
  WidgetTester tester,
  FakeWardrobeRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WardrobePage(
        repository: repository,
        profileImage: const AssetImage('Assets/logo_white.png'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Wardrobe Page Tests', () {
    testWidgets('Wardrobe page renders core UI', (WidgetTester tester) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      await pumpWardrobePage(tester, fakeRepo);

      expect(find.text('Wardrobe'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_sharp), findsOneWidget);
      expect(find.byIcon(Icons.filter_list_outlined), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });

    testWidgets('Top add button opens CreateItem dialog', (
      WidgetTester tester,
    ) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      await pumpWardrobePage(tester, fakeRepo);

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.text('Add new item'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save item'), findsOneWidget);
    });

    testWidgets('Bottom add button opens CreateOutfit dialog', (
      WidgetTester tester,
    ) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      await pumpWardrobePage(tester, fakeRepo);

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      expect(find.text('Create outfit'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Save outfit'),
        findsOneWidget,
      );
    });

    testWidgets('Save item calls addClothingItem once', (
      WidgetTester tester,
    ) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      await pumpWardrobePage(tester, fakeRepo);

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'Black puffer jacket',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save item'));
      await tester.pumpAndSettle();

      expect(fakeRepo.addClothingItemCalls, 1);
    });

    testWidgets('Save outfit calls addOutfit once', (WidgetTester tester) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      await pumpWardrobePage(tester, fakeRepo);

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Casual fit');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save outfit'));
      await tester.pumpAndSettle();

      expect(fakeRepo.addOutfitCalls, 1);
    });

    testWidgets('Back button calls Navigator.pop', (WidgetTester tester) async {
      setUpMobileScreenSize(tester);
      final fakeRepo = FakeWardrobeRepository();

      
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: WardrobePage(
            repository: fakeRepo,
            profileImage: const AssetImage('Assets/logo_white.png'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
      await tester.pumpAndSettle();

      expect(observer.didPopCount, 1);
    });
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  int didPopCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPopCount++;
  }
}

