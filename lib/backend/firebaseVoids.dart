import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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

    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw Exception("## Error uploading file (downloadUrl == null or empty)");
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
  // List userStoresIDs = authCtr.cUser.stores!;
  List userStoresIDs = [];
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

//type T dynamic List<Post>, List<User> ....
Future<List<T>> getAlldocsModelsFromFb<T>(
  CollectionReference coll,
  T Function(Map<String, dynamic>) fromJson,
) async {
  List<T> models = [];

  try {
    List<DocumentSnapshot> docs = await getDocumentsByColl(coll);
    for (var doc in docs) {
      T model = fromJson(doc.data() as Map<String, dynamic>);
      models.add(model);
    }
    print('## fetched (${models.length}) models; from collection <${coll.path}>');
  } catch (e) {
    print('## Error fetching models: $e');
  }
  return models;
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
  //use aawait with it
  CollectionReference coll,
  String docId,
  String fieldName,
  dynamic fieldValue, {
  Function()? addSuccess,
}) async {
  try {
    await coll.doc(docId).update({
      fieldName: fieldValue,
    });
    print('## Field updated successfully <${coll.path}/$docId/$fieldName> = <$fieldValue>');
    if (addSuccess != null) addSuccess();
  } catch (e) {
    print('## Error updating field <${coll.path}/$docId/$fieldName> = <$fieldValue>  /ERROR : $e ///');
    throw Exception('## Exception updateFieldInFirestore');
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

deleteFromMap({
  coll,
  docID,
  fieldMapName,
  String mapKeyToDelete = '',
  bool withBackDialog = false,
  String targetInvID = '',
  Function()? addSuccess,
}) {
  //we need either targetInvID or mapKeyToDelete to delete item from map
  print('## try deleting map in ${coll}/$docID/$fieldMapName/$mapKeyToDelete');
  if (targetInvID != '') print('## targetInvID = <$targetInvID> '); // delete map B in map A by ""value"" in map B,
  if (mapKeyToDelete != '') print('## mapKeyToDelete = <$mapKeyToDelete>'); // delete map B in map A by ""key"" of map B,

  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      try {
        Map<String, dynamic> fieldMap = documentSnapshot.get(fieldMapName);
        String keyToDelete = mapKeyToDelete;
        //search map key depending on specific value
        if (targetInvID != '') {
          for (var entry in fieldMap.entries) {
            if (entry.value['invID'] == targetInvID) {
              keyToDelete = entry.key;
            }
          }
        }

        if (fieldMap.containsKey(keyToDelete)) {
          fieldMap.remove(keyToDelete);
          if (addSuccess != null) addSuccess();
        } else {
          print('## hisTr not found or already deleted');
          return;
        }

        await coll.doc(docID).update({
          '${fieldMapName}': fieldMap,
        });

        //------- success

        print('## item from fieldMap<$fieldMapName> deleted');
      } catch (error) {
        print('## ERROR: item from fieldMap <$fieldMapName> FAILED to deleted: $error');
        throw Exception('## Exception ');
      }
    } else {
      print('## doc<$docID> dont exist');
    }
  }).catchError((error) async {
    print('## ERROR: FAILED to even get  ${coll}/$docID/ : $error');
  });
}

Map<String, dynamic> deleteFromMapLocal({
  mapInitial,
  String mapKeyToDelete = '',
  String targetInvID = '',
  Function()? addSuccess,
}) {
  Map<String, dynamic> fieldMap = {};
  //we need either targetInvID or mapKeyToDelete to delete item from map
  if (targetInvID != '') print('## targetInvID = <$targetInvID> '); // delete map B in map A by ""value"" in map B,
  if (mapKeyToDelete != '') print('## mapKeyToDelete = <$mapKeyToDelete>'); // delete map B in map A by ""key"" of map B,

  try {
    fieldMap = mapInitial;
    String keyToDelete = mapKeyToDelete;
    //search map key depending on specific value
    if (targetInvID != '') {
      for (var entry in fieldMap.entries) {
        if (entry.value['invID'] == targetInvID) {
          keyToDelete = entry.key;
        }
      }
    }

    print('## key To Delete = ${keyToDelete} ');

    if (fieldMap.containsKey(keyToDelete)) {
      fieldMap.remove(keyToDelete);
      if (addSuccess != null) addSuccess();
    } else {
      print('## hisTr not found or already deleted');
    }
  } catch (error) {
    print('## ERROR: FAILED to remove key="$mapKeyToDelete" : $error');
    throw Exception('## Exception ');
  }
  ;
  return fieldMap;
}

Future<void> addToMap({coll, docID, fieldMapName, mapToAdd, Function()? addSuccess, bool withBackDialog = false}) async {
  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      Map<String, dynamic> fieldMap = documentSnapshot.get(fieldMapName);

      fieldMap[getLastIndex(fieldMap, afterLast: true)] = mapToAdd;

      await coll.doc(docID).update({
        '${fieldMapName}': fieldMap,
      }).then((value) async {
        if (withBackDialog) Get.back();
        print('## item to fieldMap added');
        //showGetXSnackBar('item added', color: Colors.black54);
        if (addSuccess != null) addSuccess();
      }).catchError((error) async {
        print('## item to fieldMap FAILED to added');
        showGetXSnackBar(snapshotErrorMsg);

        //showGetXSnackBar('item failed to be added', color: Colors.redAccent.withOpacity(0.8));
      });
    } else {
      print('## doc<$docID> dont exist');
    }
  });
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
    final elementsToAdd = canAddExistingElements 
        ? List<dynamic>.from(newElements)
        : newElements.where((element) => !oldElements.contains(element)).toList();

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
      await user.updateEmail(newEmail).then((value) {
        coll.doc(ccUser.id).get().then((DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            await coll.doc(ccUser.id).update({
              'email': newEmail, // turn verified to true in  db
            }).then((value) async {
              print('## email firestore updated');
              showGetXSnackBar('email updated');
              //refreshUser(_emailController.text);
            }).catchError((error) async {});
          }
        });
      });
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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool conditionToAdd = !data.containsKey('deliveryMatFis') || !data.containsKey('index');
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
