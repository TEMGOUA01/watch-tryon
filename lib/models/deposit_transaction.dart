import 'package:cloud_firestore/cloud_firestore.dart';

enum DepositTransactionStatus {
  pending,
  paid,
  success,
  rejected,
}

class DepositTransaction {
  final String id;
  final String userId;
  final int montant;
  final String statut;
  final String? referenceRecu;
  final DateTime? createdAt;

  const DepositTransaction({
    required this.id,
    required this.userId,
    required this.montant,
    required this.statut,
    required this.referenceRecu,
    required this.createdAt,
  });

  factory DepositTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdRaw is Timestamp) createdAt = createdRaw.toDate();

    return DepositTransaction(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      montant: (data['montant'] as num?)?.toInt() ?? 0,
      statut: (data['statut'] as String?) ?? DepositTransactionStatus.pending.name,
      referenceRecu: (data['referenceRecu'] as String?)?.trim(),
      createdAt: createdAt,
    );
  }
}
