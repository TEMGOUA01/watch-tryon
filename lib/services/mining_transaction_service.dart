import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mining_machine.dart';
import '../models/mining_transaction.dart';

class MiningTransactionService {
  MiningTransactionService._();
  static final MiningTransactionService instance = MiningTransactionService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tx =>
      _db.collection('transactions');

  Future<void> createPendingTransaction({
    required MiningMachine machine,
    required String telephone,
    required String referenceRecu,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecte.');
    }

    final phone = telephone.trim();
    final reference = referenceRecu.trim();
    if (phone.isEmpty || phone.length < 8) {
      throw Exception('Numero de telephone invalide.');
    }
    if (reference.isEmpty || reference.length < 4) {
      throw Exception('Reference de recu invalide.');
    }

    final duplicate = await _tx.where('referenceRecu', isEqualTo: reference).limit(1).get();
    if (duplicate.docs.isNotEmpty) {
      throw Exception('Cette reference est deja utilisee.');
    }

    final now = FieldValue.serverTimestamp();
    await _tx.add({
      'userId': user.uid,
      'machineId': machine.id,
      'telephoneUtilisateur': phone,
      'referenceRecu': reference,
      'montant': machine.prixCfa,
      'statut': 'paid',
      'adminNote': null,
      'validatedBy': null,
      'validatedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Stream<List<MiningTransaction>> watchMyTransactions() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _tx
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MiningTransaction.fromFirestore).toList());
  }

  Stream<List<MiningTransaction>> watchAllTransactions() {
    return _tx
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MiningTransaction.fromFirestore).toList());
  }

  Stream<List<MiningTransaction>> watchTransactionsByStatus(String status) {
    return _tx
        .where('statut', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MiningTransaction.fromFirestore).toList());
  }

  Future<void> validateTransaction({
    required String transactionId,
    required MiningTransactionStatus status,
    String? adminNote,
  }) async {
    if (status == MiningTransactionStatus.pending || status == MiningTransactionStatus.paid) {
      throw Exception('Statut invalide pour validation.');
    }

    final admin = _auth.currentUser;
    if (admin == null) {
      throw Exception('Admin non connecte.');
    }

    final txRef = _tx.doc(transactionId);
    final txDoc = await txRef.get();
    if (!txDoc.exists) {
      throw Exception('Transaction introuvable.');
    }
    final data = txDoc.data() ?? <String, dynamic>{};
    final currentStatus = (data['statut'] as String?) ?? 'pending';
    if (currentStatus == 'success') return;
    if (currentStatus != 'paid' && currentStatus != 'pending') {
      throw Exception('Transaction non traitable.');
    }

    final userId = (data['userId'] as String?) ?? '';
    final machineId = (data['machineId'] as String?) ?? '';
    final montant = (data['montant'] as num?)?.toInt() ?? 0;
    if (userId.isEmpty || machineId.isEmpty) {
      throw Exception('Transaction invalide.');
    }

    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    if (status == MiningTransactionStatus.success) {
      final machineDoc = await _db.collection('machines').doc(machineId).get();
      if (!machineDoc.exists) {
        throw Exception('Machine introuvable.');
      }
      final machineData = machineDoc.data() ?? <String, dynamic>{};

      final userMachineRef = _db
          .collection('users')
          .doc(userId)
          .collection('machines')
          .doc(transactionId);

      batch.set(
        userMachineRef,
        {
          'machineId': machineId,
          'niveau': (machineData['niveau'] as num?)?.toInt() ?? 0,
          'dateAchat': now,
          'statutActif': true,
          'sourceTransactionId': transactionId,
          'createdAt': now,
          'lastCollectAt': now,
        },
        SetOptions(merge: true),
      );

      if (montant > 0) {
        final adminRef = _db.collection('users').doc(admin.uid);
        batch.set(
          adminRef,
          {
            'balance': FieldValue.increment(montant),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
      }
    }

    batch.update(txRef, {
      'statut': status.name,
      'adminNote': adminNote,
      'validatedBy': admin.uid,
      'validatedAt': now,
      'updatedAt': now,
    });

    await batch.commit();
  }
}
