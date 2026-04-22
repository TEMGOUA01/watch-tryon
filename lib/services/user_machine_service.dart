import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mining_machine.dart';
import '../models/user_machine.dart';
import '../models/wallet_transaction.dart';

class UserMachineService {
  UserMachineService._();
  static final UserMachineService instance = UserMachineService._();

  static const int _maxCarryDays = 7;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserMachine>> watchMyMachines() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('machines')
        .orderBy('dateAchat', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(UserMachine.fromFirestore).toList());
  }

  MiningClaimEstimate estimateClaim({
    required MiningMachine machine,
    required UserMachine userMachine,
    required DateTime now,
  }) {
    if (!userMachine.statutActif) {
      return const MiningClaimEstimate(
        claimableAmount: 0,
        claimableMines: 0,
        nextMineIn: null,
        nextLastCollectAt: null,
      );
    }

    final last = userMachine.lastCollectAt ?? userMachine.dateAchat ?? now;
    final elapsedMinutes = now.difference(last).inMinutes;

    if (elapsedMinutes < machine.cycleMinutes) {
      final nextIn = Duration(minutes: machine.cycleMinutes - elapsedMinutes);
      return MiningClaimEstimate(
        claimableAmount: 0,
        claimableMines: 0,
        nextMineIn: nextIn,
        nextLastCollectAt: last,
      );
    }

    final maxMinesCarry = machine.minesPerDay * _maxCarryDays;
    final mines = (elapsedMinutes ~/ machine.cycleMinutes).clamp(0, maxMinesCarry);
    final claimableAmount = mines * machine.rewardPerMineCfa;
    final nextLastCollectAt = last.add(Duration(minutes: mines * machine.cycleMinutes));
    final remainderMinutes = elapsedMinutes - (mines * machine.cycleMinutes);
    final nextMineIn = remainderMinutes >= machine.cycleMinutes
        ? null
        : Duration(minutes: machine.cycleMinutes - remainderMinutes);

    return MiningClaimEstimate(
      claimableAmount: claimableAmount,
      claimableMines: mines,
      nextMineIn: claimableAmount > 0 ? null : nextMineIn,
      nextLastCollectAt: nextLastCollectAt,
    );
  }

  Future<int> collectMiningRewards({
    required String userMachineId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Utilisateur non connecte.');
    }

    final userRef = _db.collection('users').doc(uid);
    final userMachineRef = userRef.collection('machines').doc(userMachineId);

    return _db.runTransaction<int>((txn) async {
      final userMachineDoc = await txn.get(userMachineRef);
      if (!userMachineDoc.exists) {
        throw StateError('Machine utilisateur introuvable.');
      }

      final userMachine = UserMachine.fromFirestore(userMachineDoc);
      if (!userMachine.statutActif) {
        throw StateError('Machine inactive.');
      }
      if (userMachine.machineId.isEmpty) {
        throw StateError('Machine invalide.');
      }

      final machineRef = _db.collection('machines').doc(userMachine.machineId);
      final machineDoc = await txn.get(machineRef);
      if (!machineDoc.exists) {
        throw StateError('Machine introuvable.');
      }
      final machine = MiningMachine.fromFirestore(machineDoc);

      final now = DateTime.now();
      final estimate = estimateClaim(machine: machine, userMachine: userMachine, now: now);
      final amount = estimate.claimableAmount;
      if (amount <= 0) {
        throw StateError('Aucun gain disponible.');
      }

      final nextLastCollectAt = estimate.nextLastCollectAt ?? now;

      final userDoc = await txn.get(userRef);
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toInt() ?? 0;
      final nextBalance = currentBalance + amount;

      txn.set(
        userRef,
        {
          'balance': nextBalance,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );

      txn.set(
        userMachineRef,
        {
          'lastCollectAt': Timestamp.fromDate(nextLastCollectAt),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = userRef.collection('transactions').doc();
      txn.set(txRef, {
        'type': WalletTransactionType.deposit.name,
        'amount': amount,
        'signedAmount': amount,
        'balanceAfter': nextBalance,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'mining',
        'userMachineId': userMachineId,
        'machineId': machine.id,
      });

      return amount;
    });
  }
}

class MiningClaimEstimate {
  final int claimableAmount;
  final int claimableMines;
  final Duration? nextMineIn;
  final DateTime? nextLastCollectAt;

  const MiningClaimEstimate({
    required this.claimableAmount,
    required this.claimableMines,
    required this.nextMineIn,
    required this.nextLastCollectAt,
  });
}
