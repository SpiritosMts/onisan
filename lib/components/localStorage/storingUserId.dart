import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onisan/refs/refs.dart';
import 'package:uuid/uuid.dart';

/// ********* store restore user ID ****************
String encrypt(String id, String key) {
  var keyBytes = utf8.encode(key);
  var idBytes = utf8.encode(id);
  var hmac = Hmac(sha256, keyBytes);
  return base64UrlEncode(hmac.convert(idBytes).bytes);
}



/// Generate or retrieve the encrypted persistent ID

Future<String> getUserStoredId({bool useUuid = false,bool withEncrypt = false}) async {
  const boxName = "persistent_id_box"; // Hive box name
  const idKey = "persistent_id"; // Key for storing the ID in Hive

  // Secure storage for the encryption key
  final secureStorage = FlutterSecureStorage();
  String? secretKey = await secureStorage.read(key: "encryption_key");

  // Generate and store a secure key if not already stored
  if (secretKey == null) {
    secretKey = const Uuid().v4(); // Use a better secure random key generator in production
    await secureStorage.write(key: "encryption_key", value: secretKey);
  }

  // Open a Hive box
  final box = await Hive.openBox(boxName);//"persistent_id_box"
  try {
    // Check if the ID exists
    final storedId = box.get(idKey);//"persistent_id"
    if (storedId != null) {
      print("## stored ID found: $storedId");

      return storedId; // Return the existing encrypted ID
    }

    // Generate a new ID
    String? newId;
    if (useUuid) {
      newId = const Uuid().v4();
    } else {
      try {
        newId = await deviceInfoServ.getUniqueDeviceId();
      } catch (e) {
        print("## Error retrieving device ID: $e");
        newId = const Uuid().v4(); // Fallback to UUID
      }
    }

    print("## new ID generated: $newId");
    String encryptedId = sanitizeString(newId);
    // Encrypt the new ID
        if(withEncrypt){
      encryptedId = encrypt(newId, secretKey);
    }
    // Save the encrypted ID in Hive
    await box.put(idKey, encryptedId);

    return encryptedId;
  } finally {
    await box.close();
  }
}

String sanitizeString(String path) {
  return path.replaceAll(RegExp(r'[.#$[\]]'), '_');
}
Future<void> deleteUserStoredId() async {
  const boxName = "persistent_id_box"; // Hive box name
  const idKey = "persistent_id"; // Key for storing the ID in Hive

  // Secure storage for the encryption key
  final secureStorage = FlutterSecureStorage();

  // Open the Hive box
  final box = await Hive.openBox(boxName);
  try {
    // Remove the stored ID from Hive
    if (box.containsKey(idKey)) {
      await box.delete(idKey);
      print("## Deleted stored ID from Hive.");
    } else {
      print("## No stored ID found in Hive.");
    }

    // Remove the encryption key from Secure Storage
    final secretKey = await secureStorage.read(key: "encryption_key");
    if (secretKey != null) {
      await secureStorage.delete(key: "encryption_key");
      print("## Deleted encryption key from Secure Storage.");
    } else {
      print("## No encryption key found in Secure Storage.");
    }
  } finally {
    await box.close();
  }
}

//*************************************************
Future<String> getUserStoredId2({bool useUuid =false}) async {
  const secretKey = "my_super_secret_key"; // Use a securely generated key here
  const boxName = "persistent_id_box"; // Hive box name
  const idKey = "persistent_id"; // Key for storing the ID in Hive

  // Open a Hive box
  final box = await Hive.openBox(boxName);

  // Check if the ID exists
  final storedId = box.get(idKey);
  if (storedId != null) {
    return storedId; // Return the existing encrypted ID
  }
  String newId = const Uuid().v4();


  String encryptedId = encrypt(newId, secretKey);

  // Save the encrypted ID in Hive
  await box.put(idKey, encryptedId);

  return encryptedId;
}