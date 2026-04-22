import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signal.dart';
import '../services/signal_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class AdminSignalsScreen extends StatelessWidget {
  const AdminSignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Optionally add a check for Admin role here if you have a user model.
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin Signaux'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Deconnexion',
              onPressed: () => AuthService.instance.signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminStatsWidget(),
              const SizedBox(height: 30),
              const Text(
                "Créer un Signal",
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const CreateSignalForm(),
              const SizedBox(height: 30),
              const Text(
                "Liste des Signaux",
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const AdminSignalsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatsWidget extends StatelessWidget {
  const AdminStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final signalService = SignalService();
    
    return StreamBuilder<Map<String, dynamic>>(
      stream: signalService.getPerformanceStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final stats = snapshot.data!;
        final int totalFinished = stats['wins'] + stats['losses'];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(
            color: AppTheme.surfaceColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Statistiques Globales",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildStatInfo("Signaux terminés", "$totalFinished", Colors.white),
                  _buildStatInfo("WIN", "${stats['wins']}", AppTheme.successColor),
                  _buildStatInfo("LOSS", "${stats['losses']}", AppTheme.errorColor),
                  _buildStatInfo("Réussite", "${stats['winRate']}%", AppTheme.warningColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}

class CreateSignalForm extends StatefulWidget {
  const CreateSignalForm({super.key});

  @override
  State<CreateSignalForm> createState() => _CreateSignalFormState();
}

class _CreateSignalFormState extends State<CreateSignalForm> {
  String type = "BUY";

  final symbolController = TextEditingController(text: "XAUUSD");
  final entryController = TextEditingController();
  final tpController = TextEditingController();
  final slController = TextEditingController();
  final confidenceController = TextEditingController();
  final analysisController = TextEditingController();

  bool isLoading = false;

  Future<void> createSignal() async {
    if (entryController.text.isEmpty || tpController.text.isEmpty || slController.text.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('signals').add({
        "type": type,
        "symbol": symbolController.text,
        "entryPrice": entryController.text, // User may input double or string
        "takeProfit": tpController.text,
        "stopLoss": slController.text,
        "confidence": int.tryParse(confidenceController.text) ?? 80,
        "analysis": analysisController.text,
        "status": "ACTIVE",
        "timestamp": FieldValue.serverTimestamp(),
        "createdBy": "admin"
      });

      // Clear form
      entryController.clear();
      tpController.clear();
      slController.clear();
      confidenceController.clear();
      analysisController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signal publié avec succès', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.successColor));
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
       }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: AppTheme.surfaceColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Type"),
                  items: ["BUY", "SELL"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (val) => setState(() => type = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTextField(symbolController, "Symbole (ex: XAUUSD)", Icons.currency_exchange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(entryController, "Entrée", Icons.login, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(confidenceController, "Confiance %", Icons.psychology, isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(tpController, "Take Profit", Icons.arrow_upward, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(slController, "Stop Loss", Icons.arrow_downward, isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(analysisController, "Analyse (optionnel)", Icons.analytics),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : createSignal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : const Text("Publier Signal", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppTheme.secondaryColor, size: 18),
        filled: true,
        fillColor: AppTheme.inputBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class AdminSignalsList extends StatelessWidget {
  const AdminSignalsList({super.key});

  @override
  Widget build(BuildContext context) {
    final signalService = SignalService();

    return StreamBuilder<List<TradingSignal>>(
      stream: signalService.getSignals(),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun signal.", style: TextStyle(color: Colors.grey)));
          }

          final signals = snapshot.data!;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: signals.length,
            itemBuilder: (context, index) {
              final signal = signals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration(borderRadiusVal: 16).copyWith(
                  color: AppTheme.surfaceLightColor,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: signal.type == 'BUY' ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(signal.type, style: TextStyle(color: signal.type == 'BUY' ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(signal.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("Entrée: ${signal.entryPrice}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    _buildStatusDropdown(signal.id, signal.status),
                  ],
                ),
              );
            },
          );
      },
    );
  }

  Widget _buildStatusDropdown(String signalId, String currentStatus) {
    Color statusColor;
    if (currentStatus == "WIN") statusColor = AppTheme.successColor;
    else if (currentStatus == "LOSS") statusColor = AppTheme.errorColor;
    else statusColor = AppTheme.warningColor;

    return PopupMenuButton<String>(
      initialValue: currentStatus,
       child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: statusColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentStatus, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: statusColor, size: 16),
          ],
        ),
      ),
      onSelected: (value) {
        FirebaseFirestore.instance
            .collection('signals')
            .doc(signalId)
            .update({"status": value});
      },
      color: AppTheme.surfaceColor,
      itemBuilder: (context) => [
        const PopupMenuItem(value: "WIN", child: Text("WIN", style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold))),
        const PopupMenuItem(value: "LOSS", child: Text("LOSS", style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold))),
        const PopupMenuItem(value: "ACTIVE", child: Text("ACTIVE", style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
