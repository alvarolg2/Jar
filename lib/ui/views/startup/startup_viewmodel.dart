import 'package:jar/services/update_service.dart';
import 'package:stacked/stacked.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final UpdateService _updateService = UpdateService();

  Future runStartupLogic() async {
    setBusy(true);
    await _updateService.checkForUpdate();
    setBusy(false);
    _navigationService.replaceWithHomeView();
  }
}
