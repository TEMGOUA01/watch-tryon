import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class ForumService {
  ForumService._();
  static final ForumService instance = ForumService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _supportThreads =>
      _db.collection('support_threads');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String threadId) {
    return _supportThreads
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportThreads() {
    return _supportThreads.orderBy('updatedAt', descending: true).snapshots();
  }

  Future<void> postMessage(
    String text, {
    required String threadId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final profile = await UserService.instance.fetchCurrentUserProfile();
    final isAdmin = await UserService.instance.isCurrentUserAdmin();
    final now = DateTime.now().toIso8601String();
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _supportThreads.doc(threadId).set({
      'threadId': threadId,
      'userUid': isAdmin ? (threadId == user.uid ? user.uid : threadId) : user.uid,
      'updatedAt': now,
      'lastMessage': cleanText,
      'lastMessageBy': user.uid,
      'lastMessageByName': profile?.name ?? user.displayName ?? user.email ?? 'Utilisateur',
      'participants': [user.uid, 'admin'],
    }, SetOptions(merge: true));

    await _supportThreads.doc(threadId).collection('messages').add({
      'uid': user.uid,
      'displayName': profile?.name ?? user.displayName ?? user.email ?? 'Utilisateur',
      'avatar': profile?.avatar ?? '🦁',
      'isAdmin': isAdmin,
      'text': cleanText,
      'createdAt': now,
    });
  }

  Future<String> getCurrentThreadId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final isAdmin = await UserService.instance.isCurrentUserAdmin();
    return isAdmin ? 'admin' : user.uid;
  }
}
