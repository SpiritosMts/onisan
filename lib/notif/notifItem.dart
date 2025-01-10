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

//************************ tests *******************************************


NotifItem generalNotif = NotifItem(
  id: 'notif2',
  title: 'Your subscription is about to expire',
  topic: 'Subscription', // Updates, Social, Promotions

  body: 'Renew your subscription to continue enjoying premium features.',
  creationTime: DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
  priority: 'medium',// 'low', 'high'
  senderId: '',
  status: 'active',
  imageUrl: 'https://i.pinimg.com/originals/95/df/52/95df5222365d97eeedf029f4858d48ed.jpg',
  type: 'reminder',// update, promotion, social
  read: false,
);
final List<NotifItem> notifications = [
  NotifItem(
    id: 'notif1',
    title: 'Check out our new features!',
    topic: 'Updates',
    body: 'We’ve added some great new features that you’ll love. Come and explore now!',
    type: 'update',

    status: 'active',
    creationTime: DateTime.now().subtract(Duration(hours: 10)).toIso8601String(),
    priority: 'high',
    senderId: 'system',
    imageUrl: 'https://example.com/new_features.png',
    read: false,
  ),
  NotifItem(
    id: 'notif2',
    title: 'Your subscription is about to expire',
    topic: 'Subscription',
    body: 'Renew your subscription to continue enjoying premium features.',
    type: 'reminder',

    status: 'active',
    creationTime: DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
    priority: 'medium',
    senderId: 'billing',
    imageUrl: 'https://example.com/subscription.png',
    read: false,
  ),
  NotifItem(
    id: 'notif3',
    title: 'New friend request',
    topic: 'Social',
    body: 'You have a new friend request from John Doe.',
    type: 'social',

    status: 'active',
    creationTime: DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
    priority: 'low',
    senderId: 'john_doe',
    imageUrl: 'https://example.com/friend_request.png',
    read: false,
  ),
  NotifItem(
    id: 'notif4',
    title: 'Special offer just for you!',
    topic: 'Promotions',
    body: 'Get 50% off on your next purchase. Don’t miss out!',
    type: 'promotion',

    status: 'active',
    creationTime: DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
    priority: 'high',
    senderId: 'marketing',
    imageUrl: 'https://example.com/special_offer.png',
    read: false,
  ),
];