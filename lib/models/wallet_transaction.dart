import 'package:cloud_firestore/cloud_firestore.dart';

enum WalletTransactionType { deposit, buy, sell, swap }

WalletTransactionType walletTransactionTypeFromString(String raw) {
  switch (raw.toLowerCase()) {
    case 'deposit':
      return WalletTransactionType.deposit;
    case 'buy':
      return WalletTransactionType.buy;
    case 'sell':
      return WalletTransactionType.sell;
    case 'swap':
      return WalletTransactionType.swap;
    default:
      return WalletTransactionType.deposit;
  }
}

class WalletTransaction {
  final String id;
  final WalletTransactionType type;
  final int amount;
  final int signedAmount;
  final int balanceAfter;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.signedAmount,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return WalletTransaction(
      id: doc.id,
      type: walletTransactionTypeFromString(
        (data['type'] as String?) ?? 'deposit',
      ),
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      signedAmount: (data['signedAmount'] as num?)?.toInt() ?? 0,
      balanceAfter: (data['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
    );
  }
}
