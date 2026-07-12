import 'package:permission_handler/permission_handler.dart';

import '../../application/services/scanner_permission_gateway.dart';

class DokanScannerPermissionService implements ScannerPermissionGateway {
  const DokanScannerPermissionService();

  @override
  Future<ScannerPermissionStatus> ensureCameraPermission() async {
    final current = await Permission.camera.status;
    final result =
        current.isGranted ? current : await Permission.camera.request();
    return result.isGranted
        ? ScannerPermissionStatus.granted
        : ScannerPermissionStatus.denied;
  }
}
