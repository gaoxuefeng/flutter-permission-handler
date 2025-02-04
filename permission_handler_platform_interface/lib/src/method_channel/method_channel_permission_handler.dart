import 'dart:async';

import 'package:flutter/services.dart';

import '../../permission_handler_platform_interface.dart';
import 'utils/codec.dart';

const MethodChannel _methodChannel =
    MethodChannel('flutter.baseflow.com/permissions/methods');

/// An implementation of [PermissionHandlerPlatform] that uses [MethodChannel]s.
class MethodChannelPermissionHandler extends PermissionHandlerPlatform {
  /// Checks the current status of the given [Permission].
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final status = await _methodChannel.invokeMethod(
        'checkPermissionStatus', permission.value);

    return Codec.decodePermissionStatus(status);
  }

  /// Checks the current status of the service associated with the given
  /// [Permission].
  ///
  /// Notes about specific permissions:
  /// - **[Permission.phone]**
  ///   - Android:
  ///     - The method will return [ServiceStatus.notApplicable] when:
  ///       - the device lacks the TELEPHONY feature
  ///       - TelephonyManager.getPhoneType() returns PHONE_TYPE_NONE
  ///       - when no Intents can be resolved to handle the `tel:` scheme
  ///     - The method will return [ServiceStatus.disabled] when:
  ///       - the SIM card is missing
  ///   - iOS:
  ///     - The method will return [ServiceStatus.notApplicable] when:
  ///       - the native code can not find a handler for the `tel:` scheme
  ///     - The method will return [ServiceStatus.disabled] when:
  ///       - the mobile network code (MNC) is either 0 or 65535. See
  ///          https://stackoverflow.com/a/11595365 for details
  ///   - **PLEASE NOTE that this is still not a perfect indication** of the
  ///     device's capability to place & connect phone calls as it also depends
  ///     on the network condition.
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    final status = await _methodChannel.invokeMethod(
        'checkServiceStatus', permission.value);

    return Codec.decodeServiceStatus(status);
  }

  /// Opens the app settings page.
  ///
  /// Returns [true] if the app settings page could be opened, otherwise
  /// [false].
  Future<bool> openAppSettings() async {
    final wasOpened = await _methodChannel.invokeMethod('openAppSettings');

    return wasOpened ?? false;
  }

  Future openNotificationSetting() async {
    final wasOpened =
        await _methodChannel.invokeMethod('openNotificationSetting');

    return wasOpened ?? false;
  }

  /// Requests the user for access to the supplied list of [Permission]s, if
  /// they have not already been granted before.
  ///
  /// Returns a [Map] containing the status per requested [Permission].
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    final data = Codec.encodePermissions(permissions);
    final status =
        await _methodChannel.invokeMethod('requestPermissions', data);

    return Codec.decodePermissionRequestResult(Map<int, int>.from(status));
  }

  /// Checks if you should show a rationale for requesting permission.
  ///
  /// This method is only implemented on Android, calling this on iOS always
  /// returns [false].
  Future<bool> shouldShowRequestPermissionRationale(
      Permission permission) async {
    final shouldShowRationale = await _methodChannel.invokeMethod(
        'shouldShowRequestPermissionRationale', permission.value);

    return shouldShowRationale ?? false;
  }
}
