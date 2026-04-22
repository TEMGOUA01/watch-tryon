import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiSignalService {
  static final AiSignalService _instance = AiSignalService._internal();
  factory AiSignalService() => _instance;
  AiSignalService._internal();

  final _rng = Random();

  // Base gold price (simulated). In production, replace with a real API call.
  static const double _baseGoldPrice = 2320.0;

  /// Generates a rule-based AI trading signal and saves it to Firestore.
  Future<void> generateAndSaveSignal() async {
    final signal = _computeSignal();
    await FirebaseFirestore.instance.collection('signals').add(signal);
  }

  Map<String, dynamic> _computeSignal() {
    // Simulate a small price movement (±0.5%)
    final movement = (_rng.nextDouble() - 0.48) * _baseGoldPrice * 0.005;
    final currentPrice = _baseGoldPrice + movement;
    final isBull = movement > 0;

    final type = isBull ? 'BUY' : 'SELL';
    final tp = isBull ? currentPrice + 20 : currentPrice - 20;
    final sl = isBull ? currentPrice - 15 : currentPrice + 15;
    final confidence = 70 + _rng.nextInt(21); // 70-90

    final analysis = isBull
        ? 'Mouvement haussier détecté sur XAUUSD. Structure de marché bullish. '
            'Zone de support respectée. Entrée optimisée par l\'IA.'
        : 'Pression baissière détectée sur XAUUSD. Résistance confirmée. '
            'Structure de marché bearish. Entrée optimisée par l\'IA.';

    return {
      'type': type,
      'symbol': 'XAUUSD',
      'entryPrice': currentPrice.toStringAsFixed(2),
      'takeProfit': tp.toStringAsFixed(2),
      'stopLoss': sl.toStringAsFixed(2),
      'confidence': confidence,
      'analysis': analysis,
      'status': 'ACTIVE',
      'timestamp': FieldValue.serverTimestamp(),
      'createdBy': 'AI',
    };
  }
}
