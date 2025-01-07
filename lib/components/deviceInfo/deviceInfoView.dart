import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onisan/refs/refs.dart';



class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({Key? key}) : super(key: key);

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  final Map<String, dynamic> _deviceData = {};
  late String appBarTitle;

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  Future<void> _fetchDeviceInfo() async {
    final deviceInfo = await deviceInfoServ.getDeviceInfo();

    if (!mounted) return;

    setState(() {
      _deviceData.addAll(deviceInfo);
      appBarTitle = _getAppBarTitle();
    });
  }

  String _getAppBarTitle() => kIsWeb
      ? 'Web Browser Info'
      : switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android Device Info',
    TargetPlatform.iOS => 'iOS Device Info',
    TargetPlatform.linux => 'Linux Device Info',
    TargetPlatform.windows => 'Windows Device Info',
    TargetPlatform.macOS => 'MacOS Device Info',
    TargetPlatform.fuchsia => 'Fuchsia Device Info',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        elevation: 4,
      ),
      body: ListView(
        children: _deviceData.keys.map(
              (String property) {
            return Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    property,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${_deviceData[property]}',
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}


