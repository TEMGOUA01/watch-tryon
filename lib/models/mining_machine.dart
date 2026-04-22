import 'package:cloud_firestore/cloud_firestore.dart';

class MiningMachine {
  final String id;
  final int niveau;
  final String nom;
  final int prixCfa;
  final int rendementJourCfa;
  final int minesPerDay;
  final int cycleMinutes;
  final int rewardPerMineCfa;
  final String? icone;
  final bool isActive;

  const MiningMachine({
    required this.id,
    required this.niveau,
    required this.nom,
    required this.prixCfa,
    required this.rendementJourCfa,
    required this.minesPerDay,
    required this.cycleMinutes,
    required this.rewardPerMineCfa,
    required this.icone,
    required this.isActive,
  });

  factory MiningMachine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final rendementJourCfa = (data['rendementJourCfa'] as num?)?.toInt() ?? 0;
    final cycleMinutes = (data['cycleMinutes'] as num?)?.toInt();
    final minesPerDay = (data['minesPerDay'] as num?)?.toInt();

    final effectiveCycleMinutes =
        (cycleMinutes != null && cycleMinutes > 0) ? cycleMinutes : 240;
    final effectiveMinesPerDay =
        (minesPerDay != null && minesPerDay > 0) ? minesPerDay : (1440 ~/ effectiveCycleMinutes).clamp(1, 1440);
    final rewardPerMineCfa = (data['rewardPerMineCfa'] as num?)?.toInt() ??
        (effectiveMinesPerDay > 0 ? (rendementJourCfa ~/ effectiveMinesPerDay) : 0);

    return MiningMachine(
      id: doc.id,
      niveau: (data['niveau'] as num?)?.toInt() ?? 0,
      nom: (data['nom'] as String?)?.trim().isNotEmpty == true
          ? (data['nom'] as String).trim()
          : 'Machine ${((data['niveau'] as num?)?.toInt() ?? 0)}',
      prixCfa: (data['prixCfa'] as num?)?.toInt() ?? 0,
      rendementJourCfa: rendementJourCfa,
      minesPerDay: effectiveMinesPerDay,
      cycleMinutes: effectiveCycleMinutes,
      rewardPerMineCfa: rewardPerMineCfa,
      icone: (data['icone'] as String?)?.trim(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
