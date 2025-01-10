

class AssetsManager {
  static  String? blankImagePath;
  static  String? errImagePath;
  static  String? filesServiceAccountPath;

  // Method to initialize asset paths (called from the main project)
  static void initialize({
     String? blankImage,
     String? errImage,
     String? filesServiceAccount,
  }) {
    filesServiceAccountPath = filesServiceAccount;
    blankImagePath = blankImage;
    errImagePath = errImage;
  }
}
