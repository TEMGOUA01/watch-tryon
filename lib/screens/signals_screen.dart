import 'package:flutter/material.dart';
import '../models/signal.dart';
import '../services/signal_service.dart';
import '../widgets/signal_card.dart';
import '../theme/app_theme.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignalService signalService = SignalService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Signaux Premium'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<List<TradingSignal>>(
        stream: signalService.getSignals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Aucun signal disponible pour le moment.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final signals = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: signals.length,
            itemBuilder: (context, index) {
              return SignalCard(signal: signals[index]);
            },
          );
        },
      ),
    );
  }
}
