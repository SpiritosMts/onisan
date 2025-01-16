import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:onisan/refs/refs.dart';



class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({Key? key}) : super(key: key);

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  final Map<String, dynamic> _deviceData = {};
   String appBarTitle = "Device Info";
   String generatedID = "";

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
        actions: [
          IconButton(
            onPressed: () async {
              // Perform the async operation first
              String id = await deviceInfoServ.getUniqueDeviceId();

              // Then call setState synchronously to update the UI
              setState(() {
                generatedID = id;
              });
            },
            icon: Icon(Iconsax.send_2_outline),
            tooltip: "id", // Optional tooltip for better accessibility
          ),
          SizedBox(width: 5),

        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // Add a text widget above the list
          Text(
            'Generated Id: < $generatedID >',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10), // Add spacing below the text

          // Add the list of device data
          ..._deviceData.keys.map(
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
        ],
      ),

    );
  }
}


