
class SortOption {
  final String fieldName;
  final bool isDescending;
  final String displayName;

  SortOption({
    required this.fieldName,
    required this.isDescending,
    required this.displayName,
  });
}

class FilterOption {
  final String fieldName; // Field in the database
  final String displayName; // Label for UI
  final String condition; // Filtering condition (e.g., whereIn, equalTo)
  final int maxSelections; // Maximum selectable values
  final List<String> allOptions; // All available options
  final List<String> selectedValues; // Currently selected values

  FilterOption({
    required this.fieldName,
    required this.displayName,
    required this.condition,
    required this.maxSelections,
    required this.allOptions,
    List<String>? selectedValues,
  }) : selectedValues = selectedValues ?? [];
}

