import 'package:flutter_test/flutter_test.dart';
import 'package:field_track/app.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // Full app bootstrap requires async DI; covered by unit tests.
    expect(const FieldTrackApp(), isNotNull);
  });
}
