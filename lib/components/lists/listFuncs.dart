import 'mapFuncs.dart';

String convertListToString(List<String> items) {
  return items.join(', ');
}
String listToCommaSeparatedTextOrdered(List<String> largeList, List<String> smallList) {
  List<String> orderedList = [];

  for (String item in largeList) {
    if (smallList.contains(item)) {
      orderedList.add(item);
    }
  }

  return orderedList.join(', ');
}

String getLastIndex(Map<String, dynamic> fieldMap, {String? cr,  bool afterLast = false}) {
  int newItemIndex = 0;
  Map<String, dynamic>  map = cr !=null? removeSubstringFromKeys(cr, fieldMap):fieldMap;
  if (map.isNotEmpty) {
    newItemIndex = map.keys.map((key) => int.parse(key)).reduce((value, element) => value > element ? value : element) + 0;
  }

  if (afterLast) {
    newItemIndex++;
  }
  return newItemIndex.toString();
}

List<double> sortDescending(List<double> inputList) {
  List<double> sortedList = List.from(inputList); // Make a copy to avoid modifying the original list
  sortedList.sort((a, b) => b.compareTo(a)); // Sorting in descending order
  return sortedList;
}
List<int> sortDescendingInt(List<int> inputList) {
  List<int> sortedList = List.from(inputList); // Make a copy to avoid modifying the original list
  sortedList.sort((a, b) => b.compareTo(a)); // Sorting in descending order
  return sortedList;
}
List<double> convertStringListToDoubleList(List<String> stringList) {
  List<double> doubleList = [];
  for (String stringValue in stringList) {
    double doubleValue = double.tryParse(stringValue) ?? 0.0;
    doubleList.add(doubleValue);
  }
  return doubleList;
}

