import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionUtil {
  /// Silent check: does NOT prompt the system permission dialog.
  static Future<bool> checkStoragePermission() async {
    try {
      final PermissionState ps = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(), // default, safe
      );
      // Full auth or limited access both count as "allowed"
      return ps.isAuth || ps.hasAccess;
    } catch (e) {
      return false; // fail closed
    }
  }


  /// Ask Permission
  static Future<bool?> requestStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    final result = await Permission.storage.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      return null; // null means open settings
    } else {
      return false; // false means just denied
    }
  }
}
