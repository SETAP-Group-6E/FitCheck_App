import 'dart:convert';

import 'package:fitcheck/Data/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('WeatherService getCurrentWeatherByCoords', () {
    // Checks that the service stores the API key it was created with.
    test('can be constructed with an API key', () {
      final service = WeatherService('test-api-key');

      expect(service.apiKey, 'test-api-key');
    });

    // Checks that a successful weather response is parsed correctly.
    test(
      'returns temperature and condition from a successful response',
      () async {
        http.Request? capturedRequest;
        final client = MockClient((request) async {
          capturedRequest = request;

          return http.Response(
            jsonEncode({
              'main': {'temp': 12.5},
              'weather': [
                {'main': 'Rain'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final result = await http.runWithClient(() async {
          final service = WeatherService('test-api-key');
          return service.getCurrentWeatherByCoords(51.5, -0.1);
        }, () => client);

        expect(result['temp'], 12.5);
        expect(result['condition'], 'Rain');
        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.url.queryParameters['lat'], '51.5');
        expect(capturedRequest!.url.queryParameters['lon'], '-0.1');
        expect(capturedRequest!.url.queryParameters['units'], 'metric');
        expect(capturedRequest!.url.queryParameters['appid'], 'test-api-key');
      },
    );

    // Checks that failed weather API responses are passed back as errors.
    test('throws an Exception when the API returns a non-200 status', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });
      await expectLater(
        http.runWithClient(() async {
          final service = WeatherService('bad-api-key');
          return service.getCurrentWeatherByCoords(51.5, -0.1);
        }, () => client),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Weather fetch failed'),
          ),
        ),
      );
    });

    // Checks that missing weather conditions use the app fallback value.
    test(
      'returns Unknown when the response has no weather conditions',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'main': {'temp': 8},
              'weather': [],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final result = await http.runWithClient(() async {
          final service = WeatherService('test-api-key');
          return service.getCurrentWeatherByCoords(51.5, -0.1);
        }, () => client);

        expect(result['temp'], 8.0);
        expect(result['condition'], 'Unknown');
      },
    );
  });
}
