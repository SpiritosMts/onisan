

String sumOfAscii(String x) {
  int sum = 0;

  // Iterate through each character in the string
  for (int i = 0; i < x.length; i++) {
    // Get the ASCII value of the character at index i
    int asciiValue = x.codeUnitAt(i);

    // Add the ASCII value to the sum
    sum += asciiValue;
  }

  return sum.toString();
}


String formatAndCapitalize(String input) {
  if (input.isEmpty) return input; // Return the input if it's empty

  // Convert camelCase or PascalCase to separate words
  String spaced = input.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]} ${m[2]!.toLowerCase()}');

  return spaced.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}