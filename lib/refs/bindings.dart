import 'package:get/get.dart';
import 'package:onisan/components/loading/loadingCtr.dart';
import 'package:onisan/onisan.dart';

import '../backend/pagination/paginationCtr.dart';
import '../notif/notifCtr.dart';

class OnisanBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoadingService>(LoadingService());
    Get.lazyPut<PaginationCtr>(() => PaginationCtr(),fenix: true);
    Get.put<FirebaseMessagingCtr>(FirebaseMessagingCtr());

    //settings ctr in main prj

  }
}

class CombinedBinding implements Bindings {
  @override
  void dependencies() {
    CustomVars.projectBindings; // prj bindings
    OnisanBinding().dependencies(); // Onisan bindings
  }
}