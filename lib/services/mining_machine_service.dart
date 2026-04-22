import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mining_machine.dart';

class MiningMachineService {
  MiningMachineService._();
  static final MiningMachineService instance = MiningMachineService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _machines =>
      _db.collection('machines');

  Stream<List<MiningMachine>> watchActiveMachines() {
    return _machines
        .orderBy('niveau')
        .snapshots()
        .map((snapshot) {
          final all = snapshot.docs.map(MiningMachine.fromFirestore).toList();
          return all.where((m) => m.isActive).toList();
        });
  }

  Future<MiningMachine?> getMachineById(String id) async {
    final doc = await _machines.doc(id).get();
    if (!doc.exists) return null;
    return MiningMachine.fromFirestore(doc);
  }

  Future<void> seedDefaultMachinesIfEmpty() async {
    final snapshot = await _machines.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    final data = <Map<String, dynamic>>[
      {
        'niveau': 1,
        'prixCfa': 5000,
        'rendementJourCfa': 300,
        'cycleMinutes': 240,
        'minesPerDay': 6,
      },
      {
        'niveau': 2,
        'prixCfa': 10000,
        'rendementJourCfa': 650,
        'cycleMinutes': 180,
        'minesPerDay': 8,
      },
      {
        'niveau': 3,
        'prixCfa': 20000,
        'rendementJourCfa': 1700,
        'cycleMinutes': 120,
        'minesPerDay': 12,
      },
      {
        'niveau': 4,
        'prixCfa': 35000,
        'rendementJourCfa': 3200,
        'cycleMinutes': 90,
        'minesPerDay': 16,
      },
      {
        'niveau': 5,
        'prixCfa': 50000,
        'rendementJourCfa': 3900,
        'cycleMinutes': 72,
        'minesPerDay': 20,
      },
      {
        'niveau': 6,
        'prixCfa': 75000,
        'rendementJourCfa': 6000,
        'cycleMinutes': 60,
        'minesPerDay': 24,
      },
      {
        'niveau': 7,
        'prixCfa': 100000,
        'rendementJourCfa': 8200,
        'cycleMinutes': 45,
        'minesPerDay': 32,
      },
      {
        'niveau': 8,
        'prixCfa': 150000,
        'rendementJourCfa': 12500,
        'cycleMinutes': 30,
        'minesPerDay': 48,
      },
    ];

    final now = FieldValue.serverTimestamp();
    for (final item in data) {
      final doc = _machines.doc();
      final rendementJourCfa = (item['rendementJourCfa'] as num?)?.toInt() ?? 0;
      final minesPerDay = (item['minesPerDay'] as num?)?.toInt() ?? 1;
      final rewardPerMineCfa = (rendementJourCfa ~/ minesPerDay).clamp(0, rendementJourCfa);
      batch.set(doc, {
        ...item,
        'nom': 'Machine Niveau ${item['niveau']}',
        'rewardPerMineCfa': rewardPerMineCfa,
        'icone': null,
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
      });
    }
    await batch.commit();
  }
}
