


import 'package:get/get.dart';
import 'package:onisan/backend/deepLinking/deepLinking.dart';
import 'package:onisan/components/snackbar/topAnimated.dart';


void goToNonStacked(String targetRoute) {
  bool isRouteFound = false;

  // Check if the current route is already the target
  if (Get.currentRoute == targetRoute) {
    print('## Already on $targetRoute');
    return; // Avoid redundant navigation
  }

  // Attempt to pop back to the target route if it exists in the stack
  Get.until((route) {
    if (route.settings.name == targetRoute) {
      isRouteFound = true;
      return true;
    }
    return false;
  });
  if (!isRouteFound) {
    // Navigate to the route if it's not found
    print('## Navigating to $targetRoute (new instance)');
    Get.toNamed(targetRoute);
  } else {
    print('## Navigated back to $targetRoute');
    // Get.until((route) => route.settings.name == route);

  }
}

// Dynamic Routing

//if i have a object locally pass it directly without downloading it again
goTargetDetails(dynamic target){
  if(target==null || target.id.isEmpty) {
    print("## goTargetDetails (target==null || target.id.isEmpty)");
    return;
  }
  Get.toNamed('/${dlConfig!.tagetName}/${target.id}', arguments: {'object': target});
}


//if i only have the object id download it from database using taht id
goTargetDetailsID(String id){
  if(id==null || id.isEmpty) {
    animatedSnack(message: "Failed to open post");

    print("## goTargetDetailsID (id==null || id.isEmpty)");

    return;
  }
  Get.toNamed('/${dlConfig!.tagetName}/${id}');
}