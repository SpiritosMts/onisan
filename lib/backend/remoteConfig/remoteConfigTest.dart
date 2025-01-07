import 'package:flutter/material.dart';
import 'package:onisan/refs/refs.dart'; // Assuming refs.dart contains remoteConfigServ

class RemoteConfigPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Remote Config Panel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: remoteConfigServ.remoteConfigValues.entries.map((entry) {
            return Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: 18));
          }).toList(),
        ),
      ),
    );
  }
}
