import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signal.dart';

class SignalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les signaux (du plus récent au plus ancien)
  Stream<List<TradingSignal>> getSignals() {
    return _firestore
        .collection('signals')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TradingSignal.fromFirestore(doc))
            .toList());
  }

  // Récupérer uniquement le dernier signal actif
  Stream<TradingSignal?> getLatestActiveSignal() {
    return _firestore
        .collection('signals')
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return TradingSignal.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  // Obtenir les statistiques de performance
  Stream<Map<String, dynamic>> getPerformanceStats() {
    return _firestore.collection('signals').snapshots().map((snapshot) {
      int totalFinished = 0;
      int wins = 0;
      int losses = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        if (status == 'WIN') {
          wins++;
          totalFinished++;
        } else if (status == 'LOSS') {
          losses++;
          totalFinished++;
        }
      }

      double winRate = totalFinished > 0 ? (wins / totalFinished) * 100 : 0;

      return {
        'winRate': winRate.round(),
        'wins': wins,
        'losses': losses,
      };
    });
  }
}
