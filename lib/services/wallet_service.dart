import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _txRef(String uid) =>
      _db.collection('users').doc(uid).collection('transactions');

  Future<void> applyTransaction({
    required WalletTransactionType type,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Le montant doit etre superieur a 0.');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Utilisateur non connecte.');
    }

    final userRef = _userRef(uid);
    final txCollection = _txRef(uid);

    await _db.runTransaction((txn) async {
      final userDoc = await txn.get(userRef);
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toInt() ?? 0;
      final signedAmount = _signedAmount(type, amount);
      final nextBalance = currentBalance + signedAmount;

      if (nextBalance < 0) {
        throw StateError('Solde insuffisant pour cette operation.');
      }

      final txDoc = txCollection.doc();
      txn.set(
        userRef,
        {
          'balance': nextBalance,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      txn.set(txDoc, {
        'type': type.name,
        'amount': amount,
        'signedAmount': signedAmount,
        'balanceAfter': nextBalance,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<WalletTransaction>> watchRecentTransactions({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _txRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WalletTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  int _signedAmount(WalletTransactionType type, int amount) {
    switch (type) {
      case WalletTransactionType.deposit:
      case WalletTransactionType.sell:
        return amount;
      case WalletTransactionType.buy:
      case WalletTransactionType.swap:
        return -amount;
    }
  }
}
