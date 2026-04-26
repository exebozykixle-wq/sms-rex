import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Yeh service Auto Mode mein phone ke notifications sunti hai
/// aur whitelisted apps ke notifications forward karti hai
class NotificationForwardService {
  static final NotificationForwardService _instance = NotificationForwardService._internal();
  factory NotificationForwardService() => _instance;
  NotificationForwardService._internal();

  /// Check karo ki Auto Mode ON hai ya nahi
  Future<bool> isAutoModeEnabled() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['autoMode'] ?? false;
  }

  /// Forward karo notification
  Future<void> forwardNotification({
    required String appName,
    required String appPackage,
    required String title,
    required String body,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data()!;

    // Auto mode check
    if (!(userData['autoMode'] ?? false)) return;

    // Whitelist check
    final whitelist = List<String>.from(userData['whitelistedApps'] ?? []);
    if (whitelist.isNotEmpty && !whitelist.contains(appPackage)) return;

    final isGlobal = userData['globalMode'] ?? true;
    final senderName = userData['name'] ?? 'Unknown';
    final channels = ['app']; // default app notification

    final msgBody = '[$appName] $title: $body';
    final List<String> targetPhones = [];

    if (isGlobal) {
      final allUsers = await FirebaseFirestore.instance.collection('users').get();
      for (final u in allUsers.docs) {
        if (u.id != uid) {
          final phone = u.data()['phone'];
          if (phone != null) targetPhones.add(phone);
        }
      }
    } else {
      final privateIds = List<String>.from(userData['privateUsers'] ?? []);
      for (final pid in privateIds) {
        final u = await FirebaseFirestore.instance.collection('users').doc(pid).get();
        if (u.exists) {
          final phone = u.data()?['phone'];
          if (phone != null) targetPhones.add(phone);
        }
      }
    }

    // Firestore mein save karo
    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': uid,
      'senderName': senderName,
      'body': msgBody,
      'type': isGlobal ? 'global' : 'private',
      'channels': channels,
      'sourceApp': appName,
      'sourcePackage': appPackage,
      'timestamp': FieldValue.serverTimestamp(),
      'recipients': targetPhones.length,
      'autoForwarded': true,
    });
  }
}
