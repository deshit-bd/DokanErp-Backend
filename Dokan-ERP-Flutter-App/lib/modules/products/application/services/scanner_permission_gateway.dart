enum ScannerPermissionStatus {
  granted,
  denied;

  bool get isGranted => this == ScannerPermissionStatus.granted;
}

abstract interface class ScannerPermissionGateway {
  Future<ScannerPermissionStatus> ensureCameraPermission();
}
