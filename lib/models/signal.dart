import 'package:cloud_firestore/cloud_firestore.dart';

class TradingSignal {
  final String id;
  final String type;
  final String symbol;
  final String entryPrice;
  final String takeProfit;
  final String stopLoss;
  final int confidence;
  final String analysis;
  final String status; // 'ACTIVE', 'WIN', 'LOSS'
  final String createdBy; // 'admin' or 'AI'
  final DateTime timestamp;

  TradingSignal({
    required this.id,
    required this.type,
    required this.symbol,
    required this.entryPrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.confidence,
    required this.analysis,
    required this.status,
    required this.createdBy,
    required this.timestamp,
  });

  factory TradingSignal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradingSignal(
      id: doc.id,
      type: data['type'] ?? 'BUY',
      symbol: data['symbol'] ?? 'XAUUSD',
      entryPrice: data['entryPrice']?.toString() ?? '',
      takeProfit: data['takeProfit']?.toString() ?? '',
      stopLoss: data['stopLoss']?.toString() ?? '',
      confidence: data['confidence'] ?? 0,
      analysis: data['analysis'] ?? '',
      status: data['status'] ?? 'ACTIVE',
      createdBy: data['createdBy'] ?? 'admin',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'symbol': symbol,
      'entryPrice': entryPrice,
      'takeProfit': takeProfit,
      'stopLoss': stopLoss,
      'confidence': confidence,
      'analysis': analysis,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
