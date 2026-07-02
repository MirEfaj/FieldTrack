import 'package:flutter_test/flutter_test.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/error/result.dart';

void main() {
  group('Result', () {
    test('Success holds data', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Error holds failure', () {
      const result = Error<int>(NetworkFailure());
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('map transforms success value', () {
      const result = Success<int>(2);
      final mapped = result.map((v) => v * 2);
      expect(mapped, isA<Success<int>>());
      expect((mapped as Success<int>).data, 4);
    });
  });
}
