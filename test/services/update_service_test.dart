import 'package:flutter_test/flutter_test.dart';
import 'package:jar/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('UpdateServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
