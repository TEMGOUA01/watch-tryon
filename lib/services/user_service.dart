import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/profile_avatars.dart';
import '../models/user_profile.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserProfile?> fetchCurrentUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(user.uid, doc.data()!);
  }

  Stream<UserProfile?> watchCurrentUserProfile() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);
    return _users.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(user.uid, doc.data()!);
    });
  }

  Future<bool> profileExists(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists;
  }

  Future<bool> checkUserExists(String email) async {
    try {
      final query = await _users.where('email', isEqualTo: email).get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> ensureCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final existing = UserProfile.fromMap(user.uid, data);
      if (!data.containsKey('avatar')) {
        await docRef.set({
          'avatar': ProfileAvatars.defaultForUid(user.uid),
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
      return existing;
    }

    final now = DateTime.now();
    final defaultAvatar = ProfileAvatars.defaultForUid(user.uid);
    final profile = UserProfile(
      uid: user.uid,
      name: (user.displayName ?? '').trim().isNotEmpty
          ? user.displayName!.trim()
          : 'Utilisateur',
      avatar: defaultAvatar,
      age: 0,
      balance: 0,
      email: (user.email ?? '').trim(),
      phone: '',
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(profile.toMap(), SetOptions(merge: true));
    return profile;
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    if (data.containsKey('avatar')) {
      data['avatar'] = ProfileAvatars.sanitize(data['avatar'] as String?);
    }
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final email = (user.email ?? '').trim().toLowerCase();
    if (email == 'tem@gmail.com') return true;

    final doc = await _users.doc(user.uid).get();
    final role = (doc.data()?['role'] as String?)?.trim().toLowerCase();
    return role == 'admin';
  }
}
