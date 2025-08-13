// import 'package:cloud_firestore/cloud_firestore.dart';

// class FeedbackModel {
//   final String id;
//   final String imageUrl;
//   final String comment;
//   final String createdTime;
//   final String senderId;

//   FeedbackModel({
//     required this.id,
//     required this.imageUrl,
//     required this.comment,
//     required this.createdTime,
//     required this.senderId,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'imageUrl': imageUrl,
//       'comment': comment,
//       'createdTime': createdTime,
//       'senderId': senderId,
//     };
//   }

//   factory FeedbackModel.fromMap(Map<String, dynamic> map) {
//     return FeedbackModel(
//       id: map['id'],
//       imageUrl: map['imageUrl'],
//       comment: map['comment'],
//       createdTime: map['createdTime'],
//       senderId: map['senderId'],
//     );
//   }
// }
