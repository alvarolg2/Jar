import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  Future<void> checkForUpdate() async {
    if (!kDebugMode && Platform.isAndroid) {
      try {
        final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          if (updateInfo.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
          }
          else if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al buscar actualizaciones: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Omitiendo búsqueda de actualizaciones (Debug/iOS).');
      }
    }
  }
}