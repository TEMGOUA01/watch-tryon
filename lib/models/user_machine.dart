import 'package:cloud_firestore/cloud_firestore.dart';

class UserMachine {
  final String id;
  final String machineId;
  final int niveau;
  final bool statutActif;
  final DateTime? dateAchat;
  final DateTime? lastCollectAt;
  final String? sourceTransactionId;

  const UserMachine({
    required this.id,
    required this.machineId,
    required this.niveau,
    required this.statutActif,
    required this.dateAchat,
    required this.lastCollectAt,
    required this.sourceTransactionId,
  });

  factory UserMachine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final dateRaw = data['dateAchat'];
    DateTime? dateAchat;
    if (dateRaw is Timestamp) {
      dateAchat = dateRaw.toDate();
    }

    final lastCollectRaw = data['lastCollectAt'];
    DateTime? lastCollectAt;
    if (lastCollectRaw is Timestamp) {
      lastCollectAt = lastCollectRaw.toDate();
    }

    return UserMachine(
      id: doc.id,
      machineId: (data['machineId'] as String?) ?? '',
      niveau: (data['niveau'] as num?)?.toInt() ?? 0,
      statutActif: data['statutActif'] as bool? ?? true,
      dateAchat: dateAchat,
      lastCollectAt: lastCollectAt,
      sourceTransactionId: data['sourceTransactionId'] as String?,
    );
  }
}
