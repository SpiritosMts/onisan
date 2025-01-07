import 'package:get/get.dart';
import 'package:onisan/components/loading/loadingCtr.dart';

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
