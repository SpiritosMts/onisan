import 'package:flutter/material.dart';

class NotifItem {
  String id;
  String title;
  String topic;
  String body;
  String status;
  String creationTime;  // ISO 8601 format: "2024-08-15T23:22:57.996Z"
  String priority;
  String senderId;
  String imageUrl;
  String iconUrl;
  String type;
  bool read;
  Map<String, dynamic> dataPayload;  // New field for additional data

  NotifItem({
    this.id = '',
    this.title = '',
    this.topic = '',
    this.body = '',
    this.status = '',
    this.creationTime = '',
    this.priority = '',
    this.senderId = '',
    this.imageUrl = '',
    this.iconUrl = '',
    this.type = '',
    this.read = false,
    this.dataPayload = const {},  // Initialize the data field
  });

  // Convert NotificationItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'body': body,
      'status': status,
      'iconUrl': iconUrl,
      'creationTime': creationTime,
      'priority': priority,
      'senderId': senderId,
      'imageUrl': imageUrl,
      'type': type,
      'read': read,
      'dataPayload': dataPayload,  // Include the data map in the conversion
    };
  }

  // Convert JSON to NotificationItem
  factory NotifItem.fromJson(Map<String, dynamic> json) {
    return NotifItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      topic: json['topic'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      body: json['body'] ?? '',
      status: json['status'] ?? '',
      creationTime: json['creationTime'] ?? '',
      priority: json['priority'] ?? '',
      senderId: json['senderId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: json['type'] ?? '',
      read: json['read'] ?? false,
      dataPayload: json['dataPayload'] ?? {},  // Handle the data map
    );
  }

  IconData getIcon() {
    switch (type) {
      case 'social':
        return Icons.person_add;
      case 'normal':
        return Icons.notifications;
      case 'reminder':
        return Icons.warning;
      case 'update':
        return Icons.new_releases;
      case 'message':
        return Icons.message_sharp;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }
}
