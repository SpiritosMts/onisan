String formatNumberK(int number) {
  if (number >= 1000000000) {
    return '${(number / 1000000000).toStringAsFixed(1)}B'; // Billions
  } else if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M'; // Millions
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}k'; // Thousands
  } else {
    return number.toString(); // Less than 1000
  }
}

double getDoubleMinValue(List<double> values) {
  return values.reduce((currentMin, value) => value < currentMin ? value : currentMin);
}
double getDoubleMaxValue(List<double> values) {
  return values.reduce((currentMax, value) => value > currentMax ? value : currentMax);
}
String formatNumberAfterComma2(double number) {
  String numberString = number.toStringAsFixed(0); // Convert to a string without decimal digits

  if (number == 0) {
    return '0'; // Return '0' for zero value
  }

  // Handle negative numbers
  bool isNegative = number < 0;
  if (isNegative) {
    numberString = numberString.substring(1); // Remove the negative sign
  }

  // Add comma separator from the right
  String formattedNumber = '';
  int count = 0;

  for (int i = numberString.length - 1; i >= 0; i--) {
    formattedNumber = numberString[i] + formattedNumber;
    count++;
    if (count == 3 && i > 0) {
      formattedNumber = ',' + formattedNumber;
      count = 0;
    }
  }

  if (isNegative) {
    formattedNumber = '-$formattedNumber'; // Add back the negative sign
  }

  if (number < 1000 && number > -1000) {
    formattedNumber = '0,$formattedNumber';
  }

  return formattedNumber;
}
