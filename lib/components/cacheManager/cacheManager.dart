
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class MyCustomCacheManager extends CacheManager {
  static const key = "customCacheKey";

  MyCustomCacheManager()
      : super(
    Config(
      key,
      stalePeriod: Duration(days: 30), // Cache duration
      maxNrOfCacheObjects: 100, // Maximum number of cached images
    ),
  );

  static MyCustomCacheManager instance = MyCustomCacheManager();
}

