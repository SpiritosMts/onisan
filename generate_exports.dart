import 'dart:io';


// dart run generate_exports.dart

void main() {
  final directory = Directory('lib');
  final outputFile = File('lib/onisan.dart');

  final buffer = StringBuffer();
  buffer.writeln("library onisan;\n");

  // Recursively find all .dart files (excluding onisan.dart itself)
  directory.listSync(recursive: true).forEach((entity) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('onisan.dart')) {
      // Ensure correct path by removing 'lib/' prefix and using forward slashes
      final relativePath = entity.uri.pathSegments
          .skip(1) // Skip the 'lib' segment
          .join('/'); // Join remaining path segments with '/'
      buffer.writeln("export '$relativePath';");
    }
  });

  // Write to onisan.dart
  outputFile.writeAsStringSync(buffer.toString());

  print('onisan.dart generated successfully!');
}