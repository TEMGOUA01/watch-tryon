import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';
import '../models/signal.dart';
import '../services/signal_service.dart';
import '../services/ai_signal_service.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────
// ADMIN DASHBOARD (role-based guard)
// ─────────────────────────────────────────────
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<bool> _isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['role'] as String?) == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
          );
        }
        if (snapshot.data != true) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: AppTheme.secondaryColor, size: 60),
                  const SizedBox(height: 16),
                  const Text('Accès Refusé', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Réservé aux administrateurs.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }
        return const _AdminDashboardView();
      },
    );
  }
}

// ─────────────────────────────────────────────
// MAIN ADMIN VIEW
// ─────────────────────────────────────────────
class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
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
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsSection(),
              SizedBox(height: 28),
              _SectionHeader(label: 'IA — Génération Automatique'),
              SizedBox(height: 12),
              _AiSignalButton(),
              SizedBox(height: 28),
              _SectionHeader(label: 'Créer un Signal Manuellement'),
              SizedBox(height: 12),
              _CreateSignalForm(),
              SizedBox(height: 28),
              _SectionHeader(label: 'Signaux existants'),
              SizedBox(height: 12),
              _SignalList(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.4),
    );
  }
}

// ─────────────────────────────────────────────
// AI SIGNAL BUTTON
// ─────────────────────────────────────────────
class _AiSignalButton extends StatefulWidget {
  const _AiSignalButton();

  @override
  State<_AiSignalButton> createState() => _AiSignalButtonState();
}

class _AiSignalButtonState extends State<_AiSignalButton> {
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      await AiSignalService().generateAndSaveSignal();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🤖 Signal IA publié !', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.successColor,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _loading ? null : AppTheme.goldGradient,
        color: _loading ? AppTheme.surfaceColor : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.secondaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
            : const Text('🤖', style: TextStyle(fontSize: 20)),
        label: Text(
          _loading ? 'Génération en cours...' : 'Générer un Signal IA',
          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATS
// ─────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: SignalService().getPerformanceStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final s = snapshot.data!;
        final int total = s['wins'] + s['losses'];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(color: AppTheme.surfaceColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(label: 'Total', value: '$total', color: Colors.white),
              _StatChip(label: 'WIN', value: '${s['wins']}', color: AppTheme.successColor),
              _StatChip(label: 'LOSS', value: '${s['losses']}', color: AppTheme.errorColor),
              _StatChip(label: 'Réussite', value: '${s['winRate']}%', color: AppTheme.warningColor),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CREATE SIGNAL FORM
// ─────────────────────────────────────────────
class _CreateSignalForm extends StatefulWidget {
  const _CreateSignalForm();

  @override
  State<_CreateSignalForm> createState() => _CreateSignalFormState();
}

class _CreateSignalFormState extends State<_CreateSignalForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'BUY';
  final _entry = TextEditingController();
  final _tp = TextEditingController();
  final _sl = TextEditingController();
  final _conf = TextEditingController();
  final _analysis = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('signals').add({
        'type': _type,
        'symbol': 'XAUUSD',
        'entryPrice': _entry.text,
        'takeProfit': _tp.text,
        'stopLoss': _sl.text,
        'confidence': int.tryParse(_conf.text) ?? 80,
        'analysis': _analysis.text.trim(),
        'status': 'ACTIVE',
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': 'admin',
      });
      _entry.clear(); _tp.clear(); _sl.clear(); _conf.clear(); _analysis.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Signal publié ✅', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.successColor,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.25)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Type selector
            Row(
              children: ['BUY', 'SELL'].map((t) {
                final selected = _type == t;
                final col = t == 'BUY' ? AppTheme.successColor : AppTheme.errorColor;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: EdgeInsets.only(right: t == 'BUY' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? col.withValues(alpha: 0.2) : AppTheme.inputBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? col : Colors.transparent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(t, style: TextStyle(color: selected ? col : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _field(_entry, 'Entrée', Icons.login, isNum: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_conf, 'Confiance %', Icons.psychology, isNum: true)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field(_tp, 'Take Profit', Icons.arrow_upward, isNum: true, color: AppTheme.successColor)),
                const SizedBox(width: 10),
                Expanded(child: _field(_sl, 'Stop Loss', Icons.arrow_downward, isNum: true, color: AppTheme.errorColor)),
              ],
            ),
            const SizedBox(height: 10),
            _field(_analysis, 'Analyse (optionnel)', Icons.analytics, required: false),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                    : const Text('Publier Signal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool isNum = false, bool required = true, Color? color}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Requis' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color ?? Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: color ?? AppTheme.secondaryColor, size: 18),
        filled: true,
        fillColor: AppTheme.inputBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIGNAL LIST (ADMIN)
// ─────────────────────────────────────────────
class _SignalList extends StatelessWidget {
  const _SignalList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TradingSignal>>(
      stream: SignalService().getSignals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun signal.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) => _AdminSignalTile(signal: snapshot.data![i]),
        );
      },
    );
  }
}

class _AdminSignalTile extends StatelessWidget {
  final TradingSignal signal;
  const _AdminSignalTile({required this.signal});

  Color get _statusColor {
    switch (signal.status) {
      case 'WIN': return AppTheme.successColor;
      case 'LOSS': return AppTheme.errorColor;
      default: return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.type == 'BUY';
    final isAi = signal.createdBy == 'AI';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16).copyWith(color: AppTheme.surfaceLightColor),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isBuy ? AppTheme.successColor : AppTheme.errorColor).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(signal.type, style: TextStyle(color: isBuy ? AppTheme.successColor : AppTheme.errorColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(signal.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    if (isAi) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.4)),
                        ),
                        child: const Text('🤖 IA', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text('E:${signal.entryPrice} TP:${signal.takeProfit} SL:${signal.stopLoss}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) => FirebaseFirestore.instance.collection('signals').doc(signal.id).update({'status': val}),
            color: AppTheme.surfaceColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(border: Border.all(color: _statusColor), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(signal.status, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_drop_down, color: _statusColor, size: 16),
                ],
              ),
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'WIN', child: Text('✅ WIN', style: TextStyle(color: AppTheme.successColor))),
              const PopupMenuItem(value: 'LOSS', child: Text('❌ LOSS', style: TextStyle(color: AppTheme.errorColor))),
              const PopupMenuItem(value: 'ACTIVE', child: Text('🟡 ACTIVE', style: TextStyle(color: AppTheme.warningColor))),
            ],
          ),
        ],
      ),
    );
  }
}
