import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';


class PaginationCtr extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('## ## onInit PaginationCtr');

  }

  @override
  void onClose() {
    print('## ## onClose PaginationCtr');
    super.onClose();
  }

  /// ************************* Pagination State *************************
  final Map<String, Map<String, dynamic>> paginationState = {};

  void initPagination<T>(String key) {
    // Check if pagination state for the given key already exists
    if (paginationState.containsKey(key)) {
      print('## Pagination state for "$key" already exists.');
      return;
    }

    // Initialize pagination state for the given key
    paginationState[key] = {
      'hasMore': true.obs,
      'isLoading': false.obs,
      'isLoadingMore': false.obs,
      'errorMsg': ''.obs,
      'lastDoc': null,
      'items': <T>[].obs,
    };
    print('## Pagination state for "$key" initialized.');
  }
  Future<void> loadItems<T>({
    required String key,
    required CollectionReference collectionRef,
    required List<T> Function(QuerySnapshot) mapToItems,
    required Query Function(Query baseQuery) queryBuilder,
    int limit = 15,
  }) async {
    final state = paginationState[key];
    if (state == null) return; // If pagination is not initialized for the key

    final isLoading = state['isLoading'] as RxBool;
    final isLoadingMore = state['isLoadingMore'] as RxBool;
    final lastDoc = state['lastDoc'];
    final items = state['items'] as RxList<T>; // Use RxList<T> directly
    final hasMore = state['hasMore'] as RxBool;
    final errorMsg = state['errorMsg'] as RxString;

    // Detect whether this is an initial load or a "load more" based on whether items are empty
    final loadMore = items.isNotEmpty;

    // Prevent loading if already in progress or no more items to load
    if ((loadMore ? isLoadingMore.value : isLoading.value) || !hasMore.value) return;

    // Set loading state
    (loadMore ? isLoadingMore : isLoading).value = true;
    errorMsg.value = '';

    try {
      Query query = queryBuilder(collectionRef.limit(limit));

      // Apply pagination if loading more and there is a last document
      if (loadMore && lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      // Fetch data
      QuerySnapshot querySnapshot = await query.get();
      final newItems = mapToItems(querySnapshot);

      // Add new items to the observable list
      items.addAll(newItems);
      if (items.isEmpty) {
        errorMsg.value = 'Empty data list';
      }

      // Check if we've reached the last page
      if (querySnapshot.docs.length < limit) {
        hasMore.value = false;
      }

      // Update last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        state['lastDoc'] = querySnapshot.docs.last;
      }
    } catch (e) {
      print("## Data failed to load: $e");
      errorMsg.value = 'Data failed to load';
    } finally {
      (loadMore ? isLoadingMore : isLoading).value = false;
    }
  }

  void removeItemFromList<T>(String itemId, String key) {
    final state = paginationState[key];
    if (state != null) {
      final items = state['items'] as RxList<T>;
      items.removeWhere((item) => (item as dynamic).id == itemId);
    }
  }
}
