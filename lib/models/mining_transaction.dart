import 'package:cloud_firestore/cloud_firestore.dart';

enum MiningTransactionStatus { pending, paid, success, rejected }

MiningTransactionStatus miningTransactionStatusFromString(String raw) {
  switch (raw.toLowerCase()) {
    case 'paid':
      return MiningTransactionStatus.paid;
    case 'success':
      return MiningTransactionStatus.success;
    case 'rejected':
      return MiningTransactionStatus.rejected;
    case 'pending':
    default:
      return MiningTransactionStatus.pending;
  }
}

class MiningTransaction {
  final String id;
  final String userId;
  final String machineId;
  final String telephoneUtilisateur;
  final String referenceRecu;
  final int montant;
  final MiningTransactionStatus statut;
  final DateTime? createdAt;

  const MiningTransaction({
    required this.id,
    required this.userId,
    required this.machineId,
    required this.telephoneUtilisateur,
    required this.referenceRecu,
    required this.montant,
    required this.statut,
    required this.createdAt,
  });

  factory MiningTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    }
    return MiningTransaction(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      machineId: (data['machineId'] as String?) ?? '',
      telephoneUtilisateur: (data['telephoneUtilisateur'] as String?) ?? '',
      referenceRecu: (data['referenceRecu'] as String?) ?? '',
      montant: (data['montant'] as num?)?.toInt() ?? 0,
      statut: miningTransactionStatusFromString((data['statut'] as String?) ?? 'pending'),
      createdAt: createdAt,
    );
  }
}
