import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';



// Helper method to create a navigation button


class RoutingManagerScreen extends StatelessWidget {
  const RoutingManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routing UI"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final route = CustomVars.routes[index];
          return buildNavigationButton(route.name, route.name);
        },
      ),
    );
  }


}