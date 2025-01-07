

class AssetsManager {
  static late String blankImagePath;
  static late String errImagePath;
  static late String filesServiceAccountPath;

  // Method to initialize asset paths (called from the main project)
  static void initialize({
    required String blankImage,
    required String errImage,
    required String filesServiceAccount,
  }) {
    filesServiceAccountPath = filesServiceAccount;
    blankImagePath = blankImage;
    errImagePath = errImage;
  }
}
