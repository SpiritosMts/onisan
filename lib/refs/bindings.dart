import 'package:get/get.dart';
import 'package:onisan/onisan.dart';

class OnisanBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoadingService>(LoadingService(), permanent: true);
    Get.lazyPut<PaginationCtr>(() => PaginationCtr(), fenix: true);

    //settings ctr in main prj
  }
}

class CombinedBinding implements Bindings {
  @override
  void dependencies() {
    CustomVars.projectBindings(); // Call the project-specific bindings
    OnisanBinding().dependencies(); // Onisan bindings
  }
}
