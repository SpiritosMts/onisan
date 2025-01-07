import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/components/dialog/bottomSheet.dart';
import 'package:onisan/refs/refs.dart';

import '../../components/snackbar/topAnimated.dart';



/// Generic List Page to display any model from Firestore
class ModelListPage<T> extends StatefulWidget {
  final CollectionReference collection;
  final T Function(Map<String, dynamic>) fromJson;
  final Widget Function(T model) itemBuilder;

  ModelListPage({
    required this.collection,
    required this.fromJson,
    required this.itemBuilder,
  });

  @override
  _ModelListPageState<T> createState() => _ModelListPageState<T>();
}

class _ModelListPageState<T> extends State<ModelListPage<T>> {
  List<T> items = [];
  bool isLoading = true;
  String errorMessage = '';
  Set<T> selectedItems = {};

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      List<DocumentSnapshot> docs = await widget.collection.get().then((snap) => snap.docs);
      items = docs.map((doc) => widget.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      errorMessage = '## Error loading data: ${e.toString()}';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteSelectedItems() async {
    bool delete = await showBottomSheetDialog(description: 'Are you sure you want to delete these items ?');
    if (!delete) return;

    try {
      ldCtr.show(loadingMessage: "deleting...");
      for (T item in selectedItems) {
        DocumentReference docRef = widget.collection.doc((item as dynamic).id);
        await docRef.delete();
      }
      setState(() {
        items.removeWhere((item) => selectedItems.contains(item));
        selectedItems.clear();
      });
      print('## Selected items deleted successfully');
      animatedSnack(message: "Selected items deleted successfully", type: "succ");
    } catch (e) {
      print('## Failed to delete items: $e');
      animatedSnack(message: "Failed to delete items: $e");
    }finally{
      ldCtr.hide();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items List (${items.length})'),
        actions: [
          if (selectedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                if (selectedItems.isNotEmpty) {
                  await deleteSelectedItems();

                }
              },
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchItems,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        errorMessage.isEmpty ? 'No items available.' : errorMessage,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                itemBuilder: (context, index) {
                  T model = items[index];
                  bool isSelected = selectedItems.contains(model);

                  //return widget.itemBuilder(model);

                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedItems.remove(model);
                        } else {
                          selectedItems.add(model);
                        }
                      });
                    },
                    leading: Checkbox(

                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedItems.add(model);
                          } else {
                            selectedItems.remove(model);
                          }
                        });
                      },
                    ),
                    title: widget.itemBuilder(model),
                  );
                },
              ),
            ),
    );
  }
}

/// Generic Item Card for displaying any model with JSON format
class ModelCard<T> extends StatefulWidget {
  final T model;
  final Map<String, dynamic> Function(T model) toJson;
  final String Function(T model) titleGetter; // Function to get the title

  ModelCard({
    required this.model,
    required this.toJson,
    required this.titleGetter,
  });

  @override
  _ModelCardState<T> createState() => _ModelCardState<T>();
}

class _ModelCardState<T> extends State<ModelCard<T>> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titleGetter(widget.model), // Use the dynamic title function
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildJsonView(widget.toJson(widget.model)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJsonView(Map<String, dynamic> json) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: json.entries.map((entry) {
        if (entry.value is Map<String, dynamic>) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: {',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                _buildJsonView(entry.value),
                Text(
                  '}',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        } else if (entry.value is List) {
          String formattedList = entry.value.map((e) => '"$e"').join(', ');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key}: ',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '[$formattedList]',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key}: ',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: entry.value is String ? '"${entry.value}"' : '${entry.value}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}

void navigateToModelListPage<T>({
  required CollectionReference collection,
  required T Function(Map<String, dynamic>) fromJson,
  required String Function(T model) titleGetter, // Function to get title dynamically
}) {
  Get.to(() => ModelListPage<T>(
        collection: collection,
        fromJson: fromJson,
        itemBuilder: (model) => ModelCard<T>(
          model: model,
          toJson: (model) => (model as dynamic).toJson(),
          titleGetter: titleGetter, // Pass the titleGetter function
        ),
      ));
}
