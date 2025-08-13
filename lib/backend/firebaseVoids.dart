import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onisan/onisan.dart';
import 'package:path/path.dart' as path;

CollectionReference collRef(collName) => FirebaseFirestore.instance.collection(collName);

/// ************************** INIT *************************************************

Future<void> tryInitFirebase2() async {
  try {
    //todo
    await Firebase.initializeApp(
      options: CustomVars.firebaseOptions, // Access firebaseOptions from CustomVars
    );
    print("## Firebase Initialized");
  } catch (e) {
    print("## Firebase initialization failed: $e");
  }
}

Future<void> tryInitFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    print("## Firebase is already initialized");
  } else {
    print("## Firebase is not initialized: INITIALIZE NOW");
    await Firebase.initializeApp(
      options: CustomVars.firebaseOptions, // Access firebaseOptions from CustomVars
    );
  }
}

/// **************************** REAL TIME***********************************************

Future<List<String>> getChildrenKeys(String ref) async {
  List<String> children = [];
  DatabaseReference serverData = database!.ref(ref); //'patients/sr1'
  final snapshot = await serverData.get();
  if (snapshot.exists) {
    snapshot.children.forEach((element) {
      children.add(element.key.toString());
    });
    //print('## <$ref> exists with [${children.length}] children');
  } else {
    //print('## <$ref> DONT exists');
  }
  return children;
}

Future<int> getChildrenNum(String ref) async {
  int childrennum = 0;
  DatabaseReference serverData = database!.ref(ref); //'patients/sr1'
  final snapshot = await serverData.get();
  if (snapshot.exists) {
    childrennum = snapshot.children.length;
    print('## <$ref> exists with [${childrennum}] children');
  } else {
    print('## <$ref> DONT exists');
  }
  //update(['chart']);
  return childrennum;
}

/// delete by url
Future<void> deleteFileByUrlFromStorage(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {
    print("## Error deleting file: $e");
  }
}

/// **************************** STORAGE***********************************************

Future<List<String>> uploadImagesToFirebase(
  List<XFile?> pickedImages, {
  String? subPath = 'uploads',
  void Function(String url)? onUploadSuccess,
}) async {
  List<String> downloadUrls = [];

  try {
    for (XFile? image in pickedImages) {
      if (image != null) {
        print("## Starting upload for image: ${image.name}");

        // Create a reference to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child('$subPath/${DateTime.now().millisecondsSinceEpoch}_${image.name}');

        // Upload the file to Firebase Storage
        UploadTask uploadTask = storageRef.putFile(File(image.path));

        // Wait until the upload is complete
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        print("## Successfully uploaded image: ${image.name}, URL: $downloadUrl");
        if (onUploadSuccess != null) {
          onUploadSuccess(downloadUrl);
        }
      }
    }

    // Print when all uploads are successful
    print("## Completed uploading ${downloadUrls.length} images.");
  } catch (e) {
    print("## Error uploading images to Firebase: $e");
  }

  return downloadUrls; // Return the list regardless of success or error
}

Future<String> uploadFileToFirebase(dynamic pickedFile, String? storagePath) async {
  String downloadUrl = "";

  if (pickedFile == null || storagePath == null) {
    print("## cant upload file : (pickedFile == null || storagePath == null)");
    return "";
  }

  try {
    // Convert XFile to File if necessary
    File file = pickedFile is XFile ? File(pickedFile.path) : pickedFile;

    String fileName = path.basename(pickedFile.path);

    String firebasePath = '$storagePath/${DateTime.now().millisecondsSinceEpoch}-${fileName}';

    final firebaseStorage = FirebaseStorage.instance;
    final storageRef = firebaseStorage.ref().child(firebasePath);

    await storageRef.putFile(file); // Upload the file to Firebase Storage
    downloadUrl = await storageRef.getDownloadURL(); // Return the download URL after upload

    if (downloadUrl.isEmpty) {
      throw Exception("## Error uploading file (downloadUrl is empty)");
    } else {
      print("## File uploaded ");
    }
  } catch (e, s) {
    print('## Error uploading file to Firebase: $e');
    debugPrintStack(stackTrace: s);
    rethrow; // Rethrow to pass the error up to the outer catch
  } finally {
    return downloadUrl;
  }
}

/// ***************************  GET ************************************************
Future<dynamic> getFieldFromFirestore(
  CollectionReference coll,
  String docId,
  String fieldName,
) async {
  try {
    // Debug: Print the Firestore path being accessed
    print('## Fetching field <$fieldName> from path <${coll.path}/$docId>');

    // Get the document snapshot
    DocumentSnapshot snapshot = await coll.doc(docId).get();

    if (snapshot.exists && snapshot.data() != null) {
      // Ensure snapshot data can be cast to a map
      Map<String, dynamic> docMap = snapshot.data() as Map<String, dynamic>;

      if (docMap.containsKey(fieldName)) {
        // Safely retrieve the field value
        dynamic fieldValue = docMap[fieldName];

        if (fieldValue is int) {
          return fieldValue.toDouble(); // Convert int to double
        } else {
          return fieldValue;
        }
      } else {
        print('## Field <$fieldName> not found in document <$docId>');
        return null;
      }
    } else {
      print('## Document not found <${coll.path}/$docId>');
      return null;
    }
  } catch (error) {
    print('## Error retrieving field <${coll.path}/$docId/$fieldName>: $error');
    throw Exception('## Error retrieving field: $error'); // Provide specific error details
  }
}

Future<List<String>> getDocumentsIDsByFieldName(String fieldName, String filedValue, CollectionReference coll) async {
  QuerySnapshot snap = await coll
      .where(fieldName, isEqualTo: filedValue) //condition
      .get();

  List<String> docsIDs = [];
  final List<DocumentSnapshot> documentsFound = snap.docs;
  for (var doc in documentsFound) {
    docsIDs.add(doc.id);
  }
  print('## docs has [$fieldName=$filedValue] =>$docsIDs');

  return docsIDs;
}

// type DocumentSnapshot
Future<List<DocumentSnapshot>> getDocumentsByIDs(
  CollectionReference coll, {
  List<String> IDs = const [],
}) async {
  QuerySnapshot snap = (IDs != [] ? await coll.where('id', whereIn: IDs).get() : await coll.get());

  final documentsMap = snap.docs;

  print('## collection:<${coll.path}> docs length =(${documentsMap.length})');

  return documentsMap;
}

// type DocumentSnapshot
Future<List<DocumentSnapshot>> getDocumentsByColl(CollectionReference coll) async {
  List<DocumentSnapshot> documentsFound = [];

  try {
    QuerySnapshot snap = await coll.get();
    documentsFound = snap.docs; //return QueryDocumentSnapshot .data() to convert to json// or "userDoc.get('email')" for each field
  } catch (err) {
    print('## Failed to get docs in coll<${coll.path}>: $err');
    throw Exception('## Exception ');
  }
  return documentsFound;
}

// Option 1: Enhanced version with better type conversion
Future<List<T>> getAlldocsModelsFromFb<T>(
  CollectionReference coll,
  T Function(Map<String, dynamic>) fromJson,
) async {
  List<T> models = [];

  try {
    List<DocumentSnapshot> docs = await getDocumentsByColl(coll);
    for (var doc in docs) {
      try {
        // Get the document data safely
        final docData = doc.data();
        if (docData == null) {
          print('## Warning: Document ${doc.id} has null data, skipping');
          continue;
        }

        Map<String, dynamic> documentData = Map<String, dynamic>.from(docData as Map<String, dynamic>);

        // Enhanced normalization with type conversion
        Map<String, dynamic> normalizedData = _normalizeDocumentDataEnhanced(documentData);

        T model = fromJson(normalizedData);
        models.add(model);
      } catch (e) {
        print('## Error processing document ${doc.id}: $e');
        print('## Document data: ${doc.data()}'); // Debug info
        // Continue processing other documents instead of failing completely
        continue;
      }
    }
    print('## fetched (${models.length}) models; from collection <${coll.path}>');
  } catch (e) {
    print('## Error fetching models: $e');
    rethrow;
  }
  return models;
}

// Enhanced normalization function with type conversion
Map<String, dynamic> _normalizeDocumentDataEnhanced(Map<String, dynamic> data) {
  Map<String, dynamic> normalized = {};

  data.forEach((key, value) {
    if (value == null) {
      normalized[key] = null;
    } else if (value is int || value is double) {
      // Convert numbers to strings if needed (you can customize this logic)
      // Check if the field name suggests it should be a string
      if (_shouldConvertToString(key)) {
        normalized[key] = value.toString();
      } else {
        normalized[key] = value;
      }
    } else if (value is String) {
      // Try to convert string to number if it looks like a number and field expects it
      if (_shouldConvertToNumber(key) && _isNumeric(value)) {
        normalized[key] = int.tryParse(value) ?? double.tryParse(value) ?? value;
      } else {
        normalized[key] = value;
      }
    } else if (value is Map) {
      // Recursively normalize nested maps
      normalized[key] = _normalizeDocumentDataEnhanced(Map<String, dynamic>.from(value));
    } else if (value is List) {
      // Handle lists
      normalized[key] = value.map((item) {
        if (item is Map) {
          return _normalizeDocumentDataEnhanced(Map<String, dynamic>.from(item));
        }
        return item;
      }).toList();
    } else {
      normalized[key] = value;
    }
  });

  return normalized;
}

// Helper function to determine if a field should be converted to string
bool _shouldConvertToString(String fieldName) {
  // Add your field names that should be strings even if they come as numbers
  const stringFields = {'id', 'userId', 'phoneNumber', 'zipCode', 'code', 'reference'};
  return stringFields.contains(fieldName) || fieldName.toLowerCase().contains('id');
}

// Helper function to determine if a field should be converted to number
bool _shouldConvertToNumber(String fieldName) {
  const numberFields = {'age', 'count', 'price', 'amount', 'quantity', 'score', 'rating'};
  return numberFields.contains(fieldName);
}

// Helper function to check if a string is numeric
bool _isNumeric(String str) {
  return double.tryParse(str) != null;
}

// Option 2: Safer version with try-catch for each field conversion
Future<List<T>> getAlldocsModelsFromFbSafe<T>(
  CollectionReference coll,
  T Function(Map<String, dynamic>) fromJson,
) async {
  List<T> models = [];

  try {
    List<DocumentSnapshot> docs = await getDocumentsByColl(coll);
    for (var doc in docs) {
      try {
        final docData = doc.data();
        if (docData == null) {
          print('## Warning: Document ${doc.id} has null data, skipping');
          continue;
        }

        Map<String, dynamic> documentData = Map<String, dynamic>.from(docData as Map<String, dynamic>);

        // Safe conversion with individual field error handling
        Map<String, dynamic> safeData = _safeDataConversion(documentData, doc.id);

        T model = fromJson(safeData);
        models.add(model);
      } catch (e, stackTrace) {
        print('## Error processing document ${doc.id}: $e');
        print('## Stack trace: $stackTrace');
        print('## Raw document data: ${doc.data()}');
        continue;
      }
    }
    print('## fetched (${models.length}) models; from collection <${coll.path}>');
  } catch (e) {
    print('## Error fetching models: $e');
    rethrow;
  }
  return models;
}

Map<String, dynamic> _safeDataConversion(Map<String, dynamic> data, String docId) {
  Map<String, dynamic> converted = {};

  data.forEach((key, value) {
    try {
      converted[key] = value;
    } catch (e) {
      print('## Warning: Error converting field "$key" in document $docId: $e');
      print('## Field value: $value (${value.runtimeType})');
      // You can set a default value or skip the field
      converted[key] = null; // or skip: return;
    }
  });

  return converted;
}

/// Helper function to normalize document data types
Map<String, dynamic> _normalizeDocumentData(Map<String, dynamic> data) {
  Map<String, dynamic> normalized = {};

  data.forEach((key, value) {
    if (value is String) {
      // Try to convert string to int first (preserve integers)
      final intValue = int.tryParse(value);
      if (intValue != null) {
        normalized[key] = intValue;
      } else {
        // Try to convert string to double if it's numeric but not an integer
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) {
          normalized[key] = doubleValue;
        } else {
          normalized[key] = value;
        }
      }
    } else if (value is int) {
      // Keep integers as integers (don't convert to double)
      normalized[key] = value;
    } else if (value is double) {
      // Keep doubles as doubles
      normalized[key] = value;
    } else if (value is Map) {
      // Recursively normalize nested maps
      normalized[key] = _normalizeDocumentData(Map<String, dynamic>.from(value));
    } else if (value is List) {
      // Handle lists by normalizing each element if it's a map
      normalized[key] = value.map((item) {
        if (item is Map<String, dynamic>) {
          return _normalizeDocumentData(item);
        }
        return item;
      }).toList();
    } else {
      // For all other types (bool, null, etc.), keep as is
      normalized[key] = value;
    }
  });

  return normalized;
}

// type T but from map of a doc

/// ***************************  ADD ************************************************
Future<void> addDocumentWithId({
  required CollectionReference coll,
  required String docID,
  required Map<String, dynamic> data,
}) async {
  try {
    await coll.doc(docID).set(data);
    Future.delayed(const Duration(milliseconds: 1000), () {});
    // Add the 'id' field to the document
    await coll.doc(docID).update({'id': docID});
    print("## ✔️ added doc with ID: <$docID> TO <${coll.path}>");
  } catch (e, s) {
    print("## ❌ Failed to add document: $e");
    debugPrintStack(stackTrace: s);
    rethrow; // Rethrow to pass the error up to the outer catch
  }
}

/// ************************** UPDATE *************************************************

Future<void> updateDoc({
  required CollectionReference coll,
  required String docID,
  required Map<String, dynamic> fieldsMap,
}) async {
  try {
    await coll.doc(docID).update(fieldsMap);

    print('## ✔️ updated doc <${coll.path}/$docID/> ');
  } catch (e, stackTrace) {
    print('## ❌ failed to update doc <${coll.path}/$docID/>: =$e');
    debugPrintStack(stackTrace: stackTrace);
    rethrow; // Rethrow to pass the error up to the outer catch
  }
}

Future<void> updateDocMap({
  required CollectionReference coll,
  required String docID,
  required Map<String, dynamic> fieldsMap,
}) async {
  try {
    // Step 1: Get the existing document
    DocumentSnapshot docSnapshot = await coll.doc(docID).get();

    if (docSnapshot.exists) {
      // Step 2: Merge existing otherInfo with new data
      Map<String, dynamic> existingOtherInfo = docSnapshot.get('otherInfo') ?? {};
      Map<String, dynamic> newOtherInfo = fieldsMap['otherInfo'];

      existingOtherInfo.addAll(newOtherInfo);

      // Step 3: Update the fieldsMap with the merged otherInfo
      fieldsMap['otherInfo'] = existingOtherInfo;

      // Step 4: Update the document in Firestore
      await coll.doc(docID).update(fieldsMap);
      print('## doc <${coll.path}/$docID/> updated');
    } else {
      throw Exception('Document does not exist.');
    }
  } catch (error) {
    print('## doc <${coll.path}/$docID/> FAILED to update: err=$error');
    throw Exception('Failed to update document <$docID> in collection <${coll.path}>: $error');
  }
}

Future<void> updateFieldInFirestore(
  CollectionReference coll,
  String docId,
  String fieldName,
  dynamic fieldValue, {
  Function()? onSuccess,
  Function(String error)? onError,
}) async {
  try {
    // Validate inputs - handle empty docId gracefully
    if (docId.isEmpty) {
      final errorMsg = 'Cannot update field: User not authenticated or document ID is empty';
      print('## $errorMsg - Skipping update for <${coll.path}/$fieldName>');
      onError?.call(errorMsg);
      return; // Return gracefully instead of throwing
    }

    if (fieldName.isEmpty) {
      final errorMsg = 'Field name cannot be empty';
      print('## $errorMsg');
      onError?.call(errorMsg);
      return; // Return gracefully instead of throwing
    }

    await coll.doc(docId).update({
      fieldName: fieldValue,
    });

    print('## Field updated successfully <${coll.path}/$docId/$fieldName> = <$fieldValue>');

    // Call success callback if provided
    onSuccess?.call();
  } on FirebaseException catch (e) {
    final errorMsg = 'Firebase error updating field <${coll.path}/$docId/$fieldName>: ${e.message}';
    print('## $errorMsg');

    onError?.call(errorMsg);
    // Don't rethrow Firebase exceptions to prevent app crashes
  } catch (e) {
    final errorMsg = 'Error updating field <${coll.path}/$docId/$fieldName>: $e';
    print('## $errorMsg');

    onError?.call(errorMsg);
    // Don't rethrow general exceptions to prevent app crashes
  }
}

/// ************************* DELETE **************************************************

clearCollection(CollectionReference coll) async {
  var snapshots = await coll.get();
  for (var doc in snapshots.docs) {
    print('# delete doc<${doc.id}>');
    await doc.reference.delete();
  }
}

Future<void> deleteDoc({Function()? success, required String docID, required CollectionReference coll}) async {
  //if docID doesnt exist it will success to remove
  await coll.doc(docID).delete().then((value) async {
    print('## document<$docID> from <${coll.path}> deleted');
    if (success != null) success();
    //showGetXSnackBar('doc deleted'.tr, color: Colors.redAccent.withOpacity(0.8));
  }).catchError((error) async {
    print('## document<$docID> from <${coll.path}> deleting error = ${error}');
    showGetXSnackBar(snapshotErrorMsg);
    throw Exception('## Exception ');
  });
}

/// ************************* DOCUMENT MAP OPERATIONs **************************************************
/// Deletes an item from a map field in a Firestore document
Future<void> deleteFromMap({
  required dynamic coll, // Can be CollectionReference or String
  required String docID,
  required String fieldMapName,
  String mapKeyToDelete = '',
  String targetInvID = '',
  bool withBackDialog = false,
  VoidCallback? addSuccess,
}) async {
  // Validation
  if (mapKeyToDelete.isEmpty && targetInvID.isEmpty) {
    debugPrint('## Error: Either mapKeyToDelete or targetInvID must be provided');
    return;
  }

  if (docID.isEmpty) {
    debugPrint('## Error: Document ID cannot be empty');
    return;
  }

  // Handle collection reference
  CollectionReference collection;
  try {
    if (coll is String) {
      collection = FirebaseFirestore.instance.collection(coll);
      debugPrint('## Using collection path: $coll');
    } else if (coll is CollectionReference) {
      collection = coll;
      debugPrint('## Using CollectionReference: ${coll.path}');
    } else {
      debugPrint('## Error: Invalid collection type. Expected String or CollectionReference');
      return;
    }
  } catch (error) {
    debugPrint('## Error: Failed to get collection reference: $error');
    return;
  }

  debugPrint('## Attempting to delete from map: ${collection.path}/$docID/$fieldMapName');
  if (targetInvID.isNotEmpty) debugPrint('## Searching by targetInvID: $targetInvID');
  if (mapKeyToDelete.isNotEmpty) debugPrint('## Direct key to delete: $mapKeyToDelete');

  try {
    final DocumentSnapshot documentSnapshot = await collection.doc(docID).get();

    if (!documentSnapshot.exists) {
      debugPrint('## Error: Document "$docID" does not exist');
      return;
    }

    // Get the field map data
    final data = documentSnapshot.data() as Map<String, dynamic>?;
    if (data == null || !data.containsKey(fieldMapName)) {
      debugPrint('## Error: Field "$fieldMapName" not found in document');
      return;
    }

    Map<String, dynamic> fieldMap = Map<String, dynamic>.from(data[fieldMapName] ?? {});
    String keyToDelete = mapKeyToDelete;

    // If targetInvID is provided, search for the key by invID value
    if (targetInvID.isNotEmpty) {
      String? foundKey;
      for (var entry in fieldMap.entries) {
        if (entry.value is Map<String, dynamic>) {
          final entryMap = entry.value as Map<String, dynamic>;
          if (entryMap['invID'] == targetInvID) {
            foundKey = entry.key;
            break;
          }
        }
      }

      if (foundKey != null) {
        keyToDelete = foundKey;
        debugPrint('## Found key by invID: $keyToDelete');
      } else {
        debugPrint('## Warning: No entry found with invID: $targetInvID');
        return;
      }
    }

    // Check if key exists and remove it
    if (fieldMap.containsKey(keyToDelete)) {
      fieldMap.remove(keyToDelete);
      debugPrint('## Key "$keyToDelete" removed from local map');
    } else {
      debugPrint('## Warning: Key "$keyToDelete" not found or already deleted');
      return;
    }

    // Update Firestore document
    await collection.doc(docID).update({fieldMapName: fieldMap});

    debugPrint('## Success: Item deleted from fieldMap "$fieldMapName"');

    if (withBackDialog) Get.back();
    addSuccess?.call();
  } catch (error) {
    debugPrint('## Error: Failed to delete from fieldMap "$fieldMapName": $error');
    _showErrorMessage('Failed to delete item');
    rethrow;
  }
}

/// Deletes an item from a local map (without Firestore interaction)
Map<String, dynamic> deleteFromMapLocal({
  required Map<String, dynamic> mapInitial,
  String mapKeyToDelete = '',
  String targetInvID = '',
  VoidCallback? addSuccess,
}) {
  // Validation
  if (mapKeyToDelete.isEmpty && targetInvID.isEmpty) {
    debugPrint('## Error: Either mapKeyToDelete or targetInvID must be provided');
    return Map<String, dynamic>.from(mapInitial);
  }

  if (targetInvID.isNotEmpty) debugPrint('## Searching by targetInvID: $targetInvID');
  if (mapKeyToDelete.isNotEmpty) debugPrint('## Direct key to delete: $mapKeyToDelete');

  try {
    Map<String, dynamic> fieldMap = Map<String, dynamic>.from(mapInitial);
    String keyToDelete = mapKeyToDelete;

    // If targetInvID is provided, search for the key by invID value
    if (targetInvID.isNotEmpty) {
      String? foundKey;
      for (var entry in fieldMap.entries) {
        if (entry.value is Map<String, dynamic>) {
          final entryMap = entry.value as Map<String, dynamic>;
          if (entryMap['invID'] == targetInvID) {
            foundKey = entry.key;
            break;
          }
        }
      }

      if (foundKey != null) {
        keyToDelete = foundKey;
        debugPrint('## Found key by invID: $keyToDelete');
      } else {
        debugPrint('## Warning: No entry found with invID: $targetInvID');
        return fieldMap;
      }
    }

    debugPrint('## Key to delete: $keyToDelete');

    // Check if key exists and remove it
    if (fieldMap.containsKey(keyToDelete)) {
      fieldMap.remove(keyToDelete);
      addSuccess?.call();
      debugPrint('## Success: Key "$keyToDelete" removed from local map');
    } else {
      debugPrint('## Warning: Key "$keyToDelete" not found or already deleted');
    }

    return fieldMap;
  } catch (error) {
    debugPrint('## Error: Failed to remove key "$mapKeyToDelete" from local map: $error');
    return Map<String, dynamic>.from(mapInitial);
  }
}

/// Adds an item to a map field in a Firestore document
Future<void> addToMap({
  required dynamic coll, // Can be CollectionReference or String
  required String docID,
  required String fieldMapName,
  required Map<String, dynamic> mapToAdd,
  VoidCallback? addSuccess,
  bool withBackDialog = false,
}) async {
  // Validation
  if (docID.isEmpty) {
    debugPrint('## Error: Document ID cannot be empty');
    return;
  }

  if (fieldMapName.isEmpty) {
    debugPrint('## Error: Field map name cannot be empty');
    return;
  }

  if (mapToAdd.isEmpty) {
    debugPrint('## Error: Map to add cannot be empty');
    return;
  }

  // Handle collection reference
  CollectionReference collection;
  try {
    if (coll is String) {
      collection = FirebaseFirestore.instance.collection(coll);
      debugPrint('## Using collection path: $coll');
    } else if (coll is CollectionReference) {
      collection = coll;
      debugPrint('## Using CollectionReference: ${coll.path}');
    } else {
      debugPrint('## Error: Invalid collection type. Expected String or CollectionReference');
      return;
    }
  } catch (error) {
    debugPrint('## Error: Failed to get collection reference: $error');
    return;
  }

  debugPrint('## Attempting to add to map: ${collection.path}/$docID/$fieldMapName');

  try {
    final DocumentSnapshot documentSnapshot = await collection.doc(docID).get();

    if (!documentSnapshot.exists) {
      debugPrint('## Error: Document "$docID" does not exist');
      return;
    }

    // Get existing field map or initialize empty map
    final data = documentSnapshot.data() as Map<String, dynamic>?;
    Map<String, dynamic> fieldMap = {};

    if (data != null && data.containsKey(fieldMapName)) {
      fieldMap = Map<String, dynamic>.from(data[fieldMapName] ?? {});
    }

    // Generate next available key
    String newKey = _getNextMapKey(fieldMap);
    fieldMap[newKey] = mapToAdd;

    debugPrint('## Adding item with key: $newKey');

    // Update Firestore document
    await collection.doc(docID).update({fieldMapName: fieldMap});

    debugPrint('## Success: Item added to fieldMap "$fieldMapName"');

    if (withBackDialog) Get.back();
    addSuccess?.call();
  } catch (error) {
    debugPrint('## Error: Failed to add item to fieldMap "$fieldMapName": $error');
    _showErrorMessage('Failed to add item');
    rethrow;
  }
}

// Helper functions

/// Generates the next available key for a map
String _getNextMapKey(Map<String, dynamic> fieldMap) {
  if (fieldMap.isEmpty) {
    return '0';
  }

  try {
    // Get all numeric keys and find the maximum
    final numericKeys = fieldMap.keys.map((key) => int.tryParse(key.toString())).where((key) => key != null).cast<int>().toList();

    if (numericKeys.isEmpty) {
      return fieldMap.length.toString();
    }

    final maxKey = numericKeys.reduce((a, b) => a > b ? a : b);
    return (maxKey + 1).toString();
  } catch (error) {
    debugPrint('## Warning: Error generating numeric key, using length: $error');
    return fieldMap.length.toString();
  }
}

/// Shows error message using GetX snackbar
void _showErrorMessage(String message) {
  try {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  } catch (error) {
    debugPrint('## Error showing snackbar: $error');
  }
}

/// ************************* DOCUMENT LIST OPERATIONS **************************************************

/// Add elements to a list field in a Firestore document
Future<void> addElementsToList(
  List newElements,
  String fieldName,
  String docID,
  CollectionReference coll, {
  bool canAddExistingElements = true,
}) async {
  print('## Adding list <$newElements> to <${coll.path}/$docID/$fieldName>');

  try {
    final doc = await coll.doc(docID).get();

    if (!doc.exists) {
      throw Exception('Document $docID does not exist in collection ${coll.path}');
    }

    // Get existing elements or empty list if field doesn't exist
    final oldElements = List<dynamic>.from(doc.get(fieldName) ?? []);
    print('## Existing elements: $oldElements');

    // Determine elements to add
    final elementsToAdd = canAddExistingElements ? List<dynamic>.from(newElements) : newElements.where((element) => !oldElements.contains(element)).toList();

    if (elementsToAdd.isEmpty) {
      print('## No new elements to add');
      return;
    }

    print('## Elements to add: $elementsToAdd');

    // Create merged list and update document
    final updatedList = [...oldElements, ...elementsToAdd];
    await coll.doc(docID).set({fieldName: updatedList}, SetOptions(merge: true));

    print('## Successfully added ${elementsToAdd.length} elements to <${coll.path}/$docID/$fieldName>');
  } catch (error) {
    print('## Failed to add elements to <${coll.path}/$docID/$fieldName>: $error');
    rethrow;
  }
}

/// Remove elements from a list field in a Firestore document
Future<void> removeElementsFromList(
  List elements,
  String fieldName,
  String docID,
  String collName,
) async {
  print('## Removing list <$elements> from <$collName/$docID/$fieldName>');

  try {
    final coll = FirebaseFirestore.instance.collection(collName);
    final doc = await coll.doc(docID).get();

    if (!doc.exists) {
      throw Exception('Document $docID does not exist in collection $collName');
    }

    // Get existing elements or return early if field doesn't exist
    List<dynamic> oldElements;
    try {
      oldElements = List<dynamic>.from(doc.get(fieldName) ?? []);
    } catch (e) {
      print('## Field $fieldName does not exist, nothing to remove');
      return;
    }

    if (oldElements.isEmpty) {
      print('## List is already empty, nothing to remove');
      return;
    }

    print('## Elements before removal: $oldElements');

    // Remove specified elements
    final updatedList = oldElements.where((element) => !elements.contains(element)).toList();
    final removedElements = oldElements.where((element) => elements.contains(element)).toList();

    if (removedElements.isEmpty) {
      print('## No matching elements found to remove');
      return;
    }

    print('## Elements after removal: $updatedList');

    // Update document with new list
    await coll.doc(docID).set({fieldName: updatedList}, SetOptions(merge: true));

    print('## Successfully removed ${removedElements.length} elements from <$collName/$docID/$fieldName>');
  } catch (error) {
    print('## Failed to remove elements from <$collName/$docID/$fieldName>: $error');
    rethrow;
  }
}

/// ********************* USER *************************************

acceptUser(String userID, coll) {
  coll.doc(userID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      await coll.doc(userID).update({
        'accepted': true, // turn verified to true in  db
      }).then((value) async {
        //addFirstServer(userID);
        print('## user request accepted');
        showGetXSnackBar('doctor request accepted'.tr);
      }).catchError((error) async {
        print('## user request accepted accepting error =${error}');
        //toastShow('user request accepted accepting error');
      });
    }
  });
}

changeUserName(newName, coll) async {
  await coll.doc(ccUser.id).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      await coll.doc(ccUser.id).update({
        'name': newName, // turn verified to true in  db
      }).then((value) async {
        showGetXSnackBar('name updated'.tr);
        //refreshUser(currentUser.email);
        //Get.back();//cz it in dialog
      }).catchError((error) async {
        //print('## user request accepted accepting error =${error}');
        //toastShow('user request accepted accepting error');
      });
    }
  });
}

changeUserEmail(newEmail, coll) async {
  User? user = fAuth.currentUser;
  if (user != null) {
    try {
      // Change email
      // await user.updateEmail(newEmail).then((value) {
      //   coll.doc(ccUser.id).get().then((DocumentSnapshot documentSnapshot) async {
      //     if (documentSnapshot.exists) {
      //       await coll.doc(ccUser.id).update({
      //         'email': newEmail, // turn verified to true in  db
      //       }).then((value) async {
      //         print('## email firestore updated');
      //         showGetXSnackBar('email updated');
      //         //refreshUser(_emailController.text);
      //       }).catchError((error) async {});
      //     }
      //   });
      // });
    } catch (e) {
      showGetXSnackBar(
        'This operation is sensitive and requires recent authentication.\n Log in again before retrying this request',
      );
      print('## Failed 4to update email:===> $e');
    }
  }
}

changeUserPassword(newPassword, coll) async {
  User? user = fAuth.currentUser;

  if (user != null) {
    try {
      // Change password
      await user.updatePassword(newPassword).then((value) {
        coll.doc(ccUser.id).get().then((DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            await coll.doc(ccUser.id).update({
              'pwd': newPassword, // turn verified to true in  db
            }).then((value) async {
              showGetXSnackBar('password updated');
              //refreshUser(currentUser.email);
            }).catchError((error) async {});
          }
        });
      });
    } catch (e) {
      showGetXSnackBar(
        'This operation is sensitive and requires recent authentication.\n Log in again before retrying this request',
      );

      print('## Failed to update password:===> $e');
    }
  }
}

deleteUserFromAuth(email, pwd) async {
  // sign in with user auth to delete
  await fAuth
      .signInWithEmailAndPassword(
    email: email,
    password: pwd,
  )
      .then((value) async {
    print('## account: <${fAuthcUser!.email}> deleted');
    //delete current  user
    fAuthcUser!.delete();
    //admin signIn again
    await fAuth.signInWithEmailAndPassword(
      email: "authCtr.cUser.email!",
      password: "authCtr.cUser.pwd!",
    );
    print('## admin: <${fAuthcUser!.email}> reSigned in');
  });
}

/// *********************** OTHER

Future<bool> checkIfDocExists(String collName, String docId) async {
  try {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(collName);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    throw e;
  }
}

/// //////////////////////////////////////// MANUAL CHNAGES TEST ////////////////////////////////////////////

changeAllDocsManual() async {
  String collectionName = 'invoices';

  /// <<<<<<< changeable for test

  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  QuerySnapshot querySnapshot = await collection.get();

  int i = 1;

  /// Loop through each document
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // bool conditionToAdd = !data.containsKey('deliveryMatFis') || !data.containsKey('index');
    if (true) {
      print('## change ( $i )<${doc.id}>');
      await collection.doc(doc.id).update({
        'isBuy': false,
        //'index': i.toString(),
      });
    }

    i++; //last
  }
}

Future<void> removeFieldFromAllDocs() async {
  String collectionName = 'invoices';

  /// <<<<<<< changeable for test

  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  QuerySnapshot querySnapshot = await collection.get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    await collection.doc(doc.id).update({
      //'matriculeFis': FieldValue.delete(),
    });
  }
}

//add randoms
/*
Future<void> addRandomUsers(int numberOfUsers) async {
  final faker = fkr.Faker();
  final Random random = Random();
  // final geo = GeoFlutterFire();

  List<String> randomImageUrls = [
    'https://randomuser.me/api/portraits/men/1.jpg',
    'https://randomuser.me/api/portraits/men/2.jpg',
    'https://randomuser.me/api/portraits/men/3.jpg',
    'https://randomuser.me/api/portraits/men/4.jpg',
    'https://randomuser.me/api/portraits/men/5.jpg',
    'https://randomuser.me/api/portraits/men/6.jpg',
    'https://randomuser.me/api/portraits/men/7.jpg',
    'https://randomuser.me/api/portraits/men/8.jpg',
    'https://randomuser.me/api/portraits/men/9.jpg',
    'https://randomuser.me/api/portraits/men/10.jpg',
    'https://randomuser.me/api/portraits/women/1.jpg',
    'https://randomuser.me/api/portraits/women/2.jpg',
    'https://randomuser.me/api/portraits/women/3.jpg',
    'https://randomuser.me/api/portraits/women/4.jpg',
    'https://randomuser.me/api/portraits/women/5.jpg',
    'https://randomuser.me/api/portraits/women/6.jpg',
    'https://randomuser.me/api/portraits/women/7.jpg',
    'https://randomuser.me/api/portraits/women/8.jpg',
    'https://randomuser.me/api/portraits/women/9.jpg',
    'https://randomuser.me/api/portraits/women/10.jpg',
  ];

  for (int i = 0; i < numberOfUsers; i++) {
    double randomLatRandom = 20 + random.nextDouble() * (40 - 20); // Latitude range from 33 to 37
    double randomLngRandom = 2 + random.nextDouble() * (20 - 2);   // Longitude range from 6 to 13

    GeoFirePoint userPosition = GeoFirePoint(GeoPoint(randomLatRandom, randomLngRandom));



    // Generate random data
    String randomName = faker.person.name();
    String randomEmail = faker.internet.email();
    String randomGender = random.nextBool() ? 'Male' : 'Female';
    int randomAge = random.nextInt(30) + 18; // Random age between 18 and 47
    double randomLat = randomLatRandom;
    double randomLng = randomLngRandom;
    String randomPhone = faker.phoneNumber.us();
    String randomCountry = faker.address.country();
    String randomCity = faker.address.city();
    String randomStreet = faker.address.streetName();
    String randomZodiac = list_zodiac[random.nextInt(list_zodiac.length)];

    List<String> randomImages = List.generate(
      random.nextInt(3) + 1,
          (index) => randomImageUrls[random.nextInt(randomImageUrls.length)],
    );

    OtherInfo randomOtherInfo = OtherInfo(
      about: faker.lorem.sentence(),
      jobTitle: faker.job.title(),
      schoolUniv: faker.company.name(),
      zodiac: [randomZodiac],
      relationshipGoals: [relationshipGoal.value],
      personalityType: [list_personalityType[random.nextInt(list_personalityType.length)]],
      hobbies: List.generate(3, (index) => list_hobbies[random.nextInt(list_hobbies.length)]),
      languages: List.generate(2, (index) => list_languages[random.nextInt(list_languages.length)]),
      interests: List.generate(3, (index) => list_interests[random.nextInt(list_interests.length)]),
      educationLevels: [list_educationLevels[random.nextInt(list_educationLevels.length)]],
      sleepingHabits: [list_sleepingHabits[random.nextInt(list_sleepingHabits.length)]],
      pets: [list_pets[random.nextInt(list_pets.length)]],
      dietaryPreferences: [list_dietaryPreferences[random.nextInt(list_dietaryPreferences.length)]],
      socialMediaStatus: [list_socialMediaStatus[random.nextInt(list_socialMediaStatus.length)]],
      smokingFrequency: [list_smokingFrequency[random.nextInt(list_smokingFrequency.length)]],
      sports: List.generate(2, (index) => list_sports[random.nextInt(list_sports.length)]),
      disabilities: List.generate(2, (index) => list_disabilities[random.nextInt(list_disabilities.length)]),
    );
    String specificID = Uuid().v1();

    Map<String, dynamic> userInput = {

      'id': specificID,
      'name': randomName,
      'email': randomEmail,
      'gender': randomGender,
      'age': randomAge,
      // 'lat': randomLat,
      //'lng': randomLng,
      'position': userPosition.data,

      'phone': randomPhone,
      'country': randomCountry,
      'city': randomCity,
      'street': randomStreet,
      'images': randomImages,
      'signUpInfoCompleted': false,
      'signUpPicsCompleted': false,
      'joinDetailsTime': DateTime.now().toUtc().toIso8601String(),
      'otherInfo': randomOtherInfo.toJson(),
    };

    // Add to Firestore
    await usersColl
        .doc(specificID) // Replace 'specificId' with your desired document ID
        .set(userInput);
  }
}

*/

///
