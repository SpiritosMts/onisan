
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  // Private constructor for singleton
  static DeviceInfoService get instance => _instance;

  DeviceInfoService._internal();

  // Singleton instance
  static final DeviceInfoService _instance = DeviceInfoService._internal();

  // Getter to access the instance

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return _readWebBrowserInfo(await _deviceInfoPlugin.webBrowserInfo);
      } else if (Platform.isAndroid) {
        return _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        return _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      } else if (Platform.isLinux) {
        return _readLinuxDeviceInfo(await _deviceInfoPlugin.linuxInfo);
      } else if (Platform.isWindows) {
        return _readWindowsDeviceInfo(await _deviceInfoPlugin.windowsInfo);
      } else if (Platform.isMacOS) {
        return _readMacOsDeviceInfo(await _deviceInfoPlugin.macOsInfo);
      } else {
        return {'Error': 'Unsupported platform'};
      }
    } catch (e) {
      return {'Error': 'Failed to get device information: $e'};
    }
  }







  Future<String> getUniqueDeviceId() async {
    const uuid = Uuid();
    if (kIsWeb) {
      return await DeviceInfoService.instance.generateWebId();
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => await DeviceInfoService.instance.generateAndroidId(),
      TargetPlatform.iOS => await DeviceInfoService.instance.generateIOSId(),
      TargetPlatform.linux => "Linux device-specific logic to generate ID here", // Replace with actual implementation
      TargetPlatform.windows => "Windows device-specific logic to generate ID here", // Replace with actual implementation
      TargetPlatform.macOS => "macOS device-specific logic to generate ID here", // Replace with actual implementation
      TargetPlatform.fuchsia => "Fuchsia device-specific logic to generate ID here", // Replace with actual implementation
      _ => uuid.v4(), // Default UUID
    };
  }




  //*********************   Generate IDs  **********************************************

  Future<String> generateAndroidId() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError("## This function is only for Android");
    }
    final androidInfo = await _deviceInfoPlugin.androidInfo;

    return "${androidInfo.manufacturer}-${androidInfo.model}-${androidInfo.id}";
  }


  Future<String> generateIOSId() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError("##This function is only for iOS");
    }

    final iosInfo = await _deviceInfoPlugin.iosInfo;

    // Combine unique fields to create a unique ID for the device
    return "${iosInfo.name}-${iosInfo.systemName}-${iosInfo.identifierForVendor}";
  }
  Future<String> generateWebId() async {
    if (!kIsWeb) {
      throw UnsupportedError("##This function is only for Web");
    }

    return const Uuid().v4();

    final webInfo = await _deviceInfoPlugin.webBrowserInfo;
    return "${webInfo.userAgent}-${webInfo.platform}-${webInfo.hardwareConcurrency}";
  }


  //*******************************************************************
  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      // 'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      //'isiOSAppOnMac': data.isiOSAppOnMac,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }


  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      //'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

}
