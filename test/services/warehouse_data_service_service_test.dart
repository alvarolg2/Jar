import 'package:flutter_test/flutter_test.dart';
import 'package:jar/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('WarehouseDataServiceServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
