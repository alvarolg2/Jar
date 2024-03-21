import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewmodelTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('showBottomSheet -', () {});
  });
}
