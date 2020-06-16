import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<bool> checkMediaPermission() async {
  final mediaPermission = Platform.isIOS
    ? Permission.photos
    : Permission.storage;
  
  Map<Permission, PermissionStatus> statuses = await [
    mediaPermission,
  ].request();
  
  return statuses[mediaPermission] == PermissionStatus.granted;
}