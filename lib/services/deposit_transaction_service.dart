import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/deposit_transaction.dart';
import '../models/wallet_transaction.dart';

class DepositTransactionService {
  DepositTransactionService._();
  static final DepositTransactionService instance = DepositTransactionService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tx => _db.collection('deposit_transactions');

  Future<void> createPaidDeposit({
    required int montant,
    required String referenceRecu,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Utilisateur non connecte.');
    }
    if (montant <= 0) {
      throw ArgumentError('Montant invalide.');
    }

    final now = FieldValue.serverTimestamp();
    await _tx.add({
      'userId': user.uid,
      'montant': montant,
      'referenceRecu': referenceRecu.trim(),
      'statut': DepositTransactionStatus.paid.name,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Stream<List<DepositTransaction>> watchTransactionsByStatus(String status) {
    Query<Map<String, dynamic>> q = _tx.orderBy('createdAt', descending: true);
    if (status != 'all') {
      q = q.where('statut', isEqualTo: status);
    }
    return q.snapshots().map(
          (snap) => snap.docs.map(DepositTransaction.fromFirestore).toList(),
        );
  }

  Future<void> validateDeposit({
    required String transactionId,
    required DepositTransactionStatus status,
    String? adminNote,
  }) async {
    if (status == DepositTransactionStatus.pending || status == DepositTransactionStatus.paid) {
      throw Exception('Statut invalide pour validation.');
    }

    final admin = _auth.currentUser;
    if (admin == null) {
      throw Exception('Admin non connecte.');
    }

    final txRef = _tx.doc(transactionId);
    await _db.runTransaction((txn) async {
      final txDoc = await txn.get(txRef);
      if (!txDoc.exists) throw Exception('Transaction introuvable.');
      final data = txDoc.data() ?? <String, dynamic>{};
      final currentStatus = (data['statut'] as String?) ?? DepositTransactionStatus.pending.name;
      if (currentStatus == DepositTransactionStatus.success.name) return;
      if (currentStatus != DepositTransactionStatus.paid.name && currentStatus != DepositTransactionStatus.pending.name) {
        throw Exception('Transaction non traitable.');
      }

      final userId = (data['userId'] as String?) ?? '';
      final montant = (data['montant'] as num?)?.toInt() ?? 0;
      if (userId.isEmpty || montant <= 0) throw Exception('Transaction invalide.');

      final now = FieldValue.serverTimestamp();

      if (status == DepositTransactionStatus.success) {
        final userRef = _db.collection('users').doc(userId);
        final userDoc = await txn.get(userRef);
        final currentBalance = (userDoc.data()?['balance'] as num?)?.toInt() ?? 0;
        final nextBalance = currentBalance + montant;

        txn.set(
          userRef,
          {
            'balance': nextBalance,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );

        final walletTxRef = userRef.collection('transactions').doc();
        txn.set(walletTxRef, {
          'type': WalletTransactionType.deposit.name,
          'amount': montant,
          'signedAmount': montant,
          'balanceAfter': nextBalance,
          'createdAt': now,
          'source': 'manual_deposit',
          'depositTransactionId': transactionId,
        });
      }

      txn.update(txRef, {
        'statut': status.name,
        'adminNote': adminNote,
        'validatedBy': admin.uid,
        'validatedAt': now,
        'updatedAt': now,
      });
    });
  }
}
