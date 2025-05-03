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

void goTargetDetailsID(String? id) {
  // Handle null or empty ID
  if (id == null || id.isEmpty) {
    animatedSnack(message: "Failed to open ${dlConfig!.tagetName}");
    print("## goTargetDetailsID (id==null || id.isEmpty)");
    return;
  }

  // Define the target route
  final targetRoute = '/${dlConfig!.tagetName}/$id';

  // Get the current route
  final currentRoute = Get.currentRoute;

  // Check if the current route is already a target details page
  if (currentRoute.startsWith('/${dlConfig!.tagetName}/')) {
    // Extract the current ID from the route
    final currentId = currentRoute.split('/').last;

    // If the new ID matches the current ID, do nothing
    if (currentId == id) {
      print("## Already on $targetRoute, no navigation needed");
      return;
    } else {
      // Replace the current page with the new ID
      Get.offNamed(targetRoute);
      print("## Replaced current route with $targetRoute");
    }
  } else {
    // If not currently on a target details page, navigate normally
    Get.toNamed(targetRoute);
    print("## Navigated to $targetRoute");
  }
}

/// in postDetails
/*
  String? postId;
  Post? postModel;

  void initObjectData() {
    postId = Get.parameters['id'];
    postModel = Get.arguments?['object']; //if found model dont fetch
  }
    @override
  void initState() {
    super.initState();
    initObjectData();
    // Fetch post details based on postId
    postCtr.fetchPostById(postId!, postModel: postModel);
}


* */