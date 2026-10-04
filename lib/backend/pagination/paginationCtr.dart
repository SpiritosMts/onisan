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

  /// Pages through documents by id ([ids] can be any length; each page is one
  /// `whereIn` query of at most 30 ids). Missing documents are skipped.
  Future<void> loadItemsByIds<T>({
    required String key,
    required CollectionReference collectionRef,
    required List<String> ids,
    required T Function(DocumentSnapshot doc) mapDoc,
    int limit = 15,
  }) async {
    final state = paginationState[key];
    if (state == null) return;

    final isLoading = state['isLoading'] as RxBool;
    final isLoadingMore = state['isLoadingMore'] as RxBool;
    final items = state['items'] as RxList<T>;
    final hasMore = state['hasMore'] as RxBool;
    final errorMsg = state['errorMsg'] as RxString;
    final int offset = (state['offset'] as int?) ?? 0;
    final loadMore = items.isNotEmpty;

    if ((loadMore ? isLoadingMore.value : isLoading.value) || !hasMore.value) return;

    final uniqueIds = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (offset >= uniqueIds.length) {
      hasMore.value = false;
      return;
    }

    (loadMore ? isLoadingMore : isLoading).value = true;
    errorMsg.value = '';
    try {
      final pageSize = limit.clamp(1, 30);
      final slice = uniqueIds.skip(offset).take(pageSize).toList();
      final snap = await collectionRef.where(FieldPath.documentId, whereIn: slice).get();
      items.addAll(snap.docs.where((d) => d.exists).map(mapDoc));
      state['offset'] = offset + slice.length;
      hasMore.value = offset + slice.length < uniqueIds.length;
    } catch (e) {
      print("## Data failed to load: $e");
      errorMsg.value = 'Data failed to load';
    } finally {
      (loadMore ? isLoadingMore : isLoading).value = false;
    }
  }

  /// Clears a list so the next load starts from the beginning.
  void resetPagination<T>(String key) {
    paginationState.remove(key);
    initPagination<T>(key);
  }

  void removeItemFromList<T>(String itemId, String key) {
    final state = paginationState[key];
    if (state != null) {
      final items = state['items'] as RxList<T>;
      items.removeWhere((item) => (item as dynamic).id == itemId);
    }
  }
}
