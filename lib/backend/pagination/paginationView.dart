import 'package:onisan/onisan.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// *****************************  list with pagination  ***********************************************************

class PaginationListView extends StatefulWidget {
  final String keyName;
  final Function(String key) onLoadData;
  final ScrollController scrollController;
  final Widget Function(dynamic user) buildWidget;  // New parameter

  PaginationListView({
    required this.keyName,
    required this.onLoadData,
    required this.scrollController,
    required this.buildWidget,  // Pass custom widget
  });

  @override
  _PaginationListViewState createState() => _PaginationListViewState();
}

class _PaginationListViewState extends State<PaginationListView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    widget.onLoadData(widget.keyName); // Only pass the key once
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent) {
      widget.onLoadData(widget.keyName); // Pass the keyName here once
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = pagCtr.paginationState[widget.keyName];
    if (state == null) return Center(child: Text('"${widget.keyName}" state not found'));

    return Obx(() {
      if (state['isLoading'].value && state['items'].isEmpty) {
        return _buildLoadingIndicator();
      }

      // Show "No posts found" only if not loading and items is empty
      if (!state['isLoading'].value && state['items'].isEmpty) {
        return Center(child: Text('No posts found.'));
      }

      if (state['errorMsg'].value.isNotEmpty && state['items'].isEmpty) {
        return _buildErrorMessage(state['errorMsg'].value);
      }

      return _buildListView(state);
    });
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator(color: Cm.primaryColor));
  }

  Widget _buildErrorMessage(String message) {
    return Center(child: Text(message));
  }

  Widget _buildListView(dynamic state) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: state['items'].length + (state['isLoadingMore'].value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state['items'].length && state['isLoadingMore'].value) {
          return _buildLoadingIndicator();
        }
        return widget.buildWidget(state['items'][index]); // Use the custom widget
      },
    );
  }
}


/// ********************** EXAMPLE *************************************
// class UsersListTab extends StatefulWidget {
//
//
//   @override
//   State<UsersListTab> createState() => _UsersListTabState();
// }
// class _UsersListTabState extends State<UsersListTab> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     pagCtr.initPagination<ScUser>('users'); /// Initializes only if not already initialized ("blocked_users"...)
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return   PaginationListView(
//         scrollController: _scrollController,
//         keyName: 'users',
//         buildWidget: (user) => UserCardAdmin(user: user),  // Pass your widget here
//
//         onLoadData: (key) => pagCtr.loadItems(
//           key: key,
//           collectionRef: usersColl, // Example: you can dynamically change this
//           mapToItems: (snapshot) => snapshot.docs.map((doc) => ScUser.fromJson(doc.data() as Map<String, dynamic>)).toList(),
//           queryBuilder: (query) => query,
//         )
//     );
//   }
// }
//
