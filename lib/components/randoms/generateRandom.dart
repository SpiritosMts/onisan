
import 'dart:math';

import 'package:uuid/uuid.dart';

/// **************** randomize ***************************
//single
T getRandomItem<T>(List<T> items) {
  if (items.isEmpty) {
    throw ArgumentError("##(random get) The list cannot be empty");
  }

  int randomIndex = Random().nextInt(items.length);
  return items[randomIndex];

  //usage String randomLogo = getRandomItem(logos);
}

//multi
List<T> getRandomItems<T>(List<T> items, int count) {
  if (count >= items.length) {
    return items; // Return all items if the count exceeds the list size
  }

  List<T> randomItems = [];
  List<int> usedIndices = [];

  while (randomItems.length < count) {
    int randomIndex = Random().nextInt(items.length);

    if (!usedIndices.contains(randomIndex)) {
      randomItems.add(items[randomIndex]);
      usedIndices.add(randomIndex);
    }
  }

  return randomItems;
  //usage List<String> randomLogos = getRandomItems(logos, 3);
}

// random number
double getRandomDouble({
  required double min,
  required double max,
  int decimalPlaces = 1,
  double step = 0.1,
}) {
  Random random = Random();

  // Calculate the range based on the step interval
  int stepsInRange = ((max - min) / step).round();

  // Get a random step within the range
  double randomStep = random.nextInt(stepsInRange + 1) * step;

  // Calculate the value
  double value = min + randomStep;

  // Return the value rounded to the specified number of decimal places
  return double.parse(value.toStringAsFixed(decimalPlaces));
}

//random time
String getRandomTime(String startDate, String endDate) {
  // Convert string to DateTime
  DateTime start = DateTime.parse("${startDate}T00:00:00.000Z");
  DateTime end = DateTime.parse("${endDate}T23:59:59.999Z");

  // Ensure that the start time is before the end time
  if (start.isAfter(end)) {
    throw ArgumentError("## Start date cannot be after end date.");
  }

  // Generate a random number of milliseconds between start and end
  Random random = Random();
  int maxMilliseconds = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;

  // Use nextDouble and scale to avoid exceeding the limit
  int randomMilliseconds = (random.nextDouble() * maxMilliseconds).toInt();

  // Generate the random DateTime
  DateTime randomDate = start.add(Duration(milliseconds: randomMilliseconds));

  // Return the DateTime in ISO 8601 format
  return randomDate.toIso8601String();
}

String generateRandomUUID() {
  var uuid = Uuid();
  return uuid.v4();  // Generates a random UUID (v4)
}