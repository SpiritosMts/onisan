
//prefs load-save
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


Future<bool> savePrefsList<T>(String key,String userId, List<T> list) async {

  // print('## saving local <$key> list ...');

  List<String> stringList = list.map((item) => json.encode(item)).toList();
  print('## saved local <$key> list  (${stringList.length})');
  // if(key=='productsList')printJson((list[0] as Product).toJson());
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return await prefs.setStringList(userId+key, stringList);
}
Future<List<T>> loadPrefsList<T>(String key,String userId, T Function(Map<String, dynamic>) fromJson) async {
  //print('## loading local <$key> ...');

  List<T> loadedList = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String>? stringList = prefs.getStringList(userId+key);
  if (stringList != null) {
    loadedList =  stringList.map((stringItem) => fromJson(json.decode(stringItem))).toList();
    //if(key=='productsList')printJson((loadedList[0] as Product).toJson());

    //print('## loaded local <$key> list  (${stringList.length})');

  } else {
    print('## prefs key = <${userId + key}> dont exist in prefs');

  }
  return loadedList;

}
Future<void> clearAllPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.clear();
  print('## All preferences cleared.');
}


