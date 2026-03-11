import 'dart:async';
import 'dart:io';

import 'package:fitcheck/Domain/repositories/wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<int> _kTransparentImage = <int>[
	0x89,
	0x50,
	0x4E,
	0x47,
	0x0D,
	0x0A,
	0x1A,
	0x0A,
	0x00,
	0x00,
	0x00,
	0x0D,
	0x49,
	0x48,
	0x44,
	0x52,
	0x00,
	0x00,
	0x00,
	0x01,
	0x00,
	0x00,
	0x00,
	0x01,
	0x08,
	0x06,
	0x00,
	0x00,
	0x00,
	0x1F,
	0x15,
	0xC4,
	0x89,
	0x00,
	0x00,
	0x00,
	0x0A,
	0x49,
	0x44,
	0x41,
	0x54,
	0x78,
	0x9C,
	0x63,
	0x00,
	0x01,
	0x00,
	0x00,
	0x05,
	0x00,
	0x01,
	0x0D,
	0x0A,
	0x2D,
	0xB4,
	0x00,
	0x00,
	0x00,
	0x00,
	0x49,
	0x45,
	0x4E,
	0x44,
	0xAE,
	0x42,
	0x60,
	0x82,
];

class _TestHttpOverrides extends HttpOverrides {
	@override
	HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
	bool _autoUncompress = true;

	@override
	bool get autoUncompress => _autoUncompress;

	@override
	set autoUncompress(bool value) {
		_autoUncompress = value;
	}

	@override
	Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

	@override
	dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
	@override
	Future<HttpClientResponse> close() async => _MockHttpClientResponse();

	@override
	dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
		implements HttpClientResponse {
	@override
	HttpClientResponseCompressionState get compressionState =>
			HttpClientResponseCompressionState.notCompressed;

	@override
	int get contentLength => _kTransparentImage.length;

	@override
	int get statusCode => HttpStatus.ok;

	@override
	StreamSubscription<List<int>> listen(
		void Function(List<int> event)? onData, {
		Function? onError,
		void Function()? onDone,
		bool? cancelOnError,
	}) {
		return Stream<List<int>>.fromIterable(<List<int>>[_kTransparentImage])
				.listen(
			onData,
			onError: onError,
			onDone: onDone,
			cancelOnError: cancelOnError,
		);
	}

	@override
	dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
			home: WardrobePage(repository: repository),
		),
	);
	await tester.pumpAndSettle();
}

void main() {
	final previousHttpOverrides = HttpOverrides.current;

	setUpAll(() {
		HttpOverrides.global = _TestHttpOverrides();
	});

	tearDownAll(() {
		HttpOverrides.global = previousHttpOverrides;
	});

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
  });
}
