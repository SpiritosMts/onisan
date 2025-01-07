import '../dateAndTime/dateAndTime.dart';

Map<String, Map<String, dynamic>> orderMapByTime(Map<String, dynamic> mp){
  List<MapEntry<String, dynamic>> list = mp.entries.toList();
  list.sort((a, b) {
    DateTime timeA = dateFormatHM.parse(a.value['time']);
    DateTime timeB = dateFormatHM.parse(b.value['time']);
    return timeB.compareTo(timeA);
  });
  Map<String, Map<String, dynamic>> sortedMap = {};
  list.asMap().forEach((index, entry) {
    sortedMap[entry.key] = entry.value;
  });

  return sortedMap;
}
Map<String, dynamic> addCaracterAtStartOfKeys(String caracter, Map<String, dynamic> originalMap){
  Map<String, dynamic> modifiedMap = {};

  originalMap.forEach((key, value) {
    String modifiedKey = caracter + key;
    modifiedMap[modifiedKey] = value;
  });
  return modifiedMap;
}
Map<String, dynamic> removeSubstringFromKeys(String substring, Map<String, dynamic> originalMap) {
  Map<String, dynamic> modifiedMap = {};

  originalMap.forEach((key, value) {
    String modifiedKey = key.replaceAll(substring, '');
    modifiedMap[modifiedKey] = value;
  });

  return modifiedMap;
}


