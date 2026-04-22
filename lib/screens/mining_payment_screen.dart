import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/mining_machine.dart';
import '../services/mining_transaction_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/aureus_background.dart';

class MiningPaymentScreen extends StatefulWidget {
  final MiningMachine machine;

  const MiningPaymentScreen({
    super.key,
    required this.machine,
  });

  @override
  State<MiningPaymentScreen> createState() => _MiningPaymentScreenState();
}

class _MiningPaymentScreenState extends State<MiningPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _refController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await MiningTransactionService.instance.createPendingTransaction(
        machine: widget.machine,
        telephone: _phoneController.text,
        referenceRecu: _refController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement soumis avec succes. En attente de validation.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mtnPhone = dotenv.env['MTN_RECEIVER_PHONE'] ?? '+237 6XX XX XX XX';
    final mtnName = dotenv.env['MTN_RECEIVER_NAME'] ?? 'AureusGold';

    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Paiement manuel MTN'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.machine.nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Montant: ${formatCfa(widget.machine.prixCfa)}',
                        style: const TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.glassDecoration(borderRadiusVal: 14).copyWith(
                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Veuillez effectuer le depot de ${formatCfa(widget.machine.prixCfa)} '
                    'sur le numero MTN suivant : $mtnPhone (Nom : $mtnName).',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Numero de telephone',
                    prefixIcon: Icon(Icons.phone, color: AppTheme.secondaryColor),
                  ),
                  validator: (value) {
                    final input = (value ?? '').trim();
                    if (input.isEmpty) return 'Numero obligatoire';
                    if (input.length < 8) return 'Numero invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _refController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Reference du recu MTN',
                    prefixIcon: Icon(Icons.receipt_long, color: AppTheme.secondaryColor),
                  ),
                  validator: (value) {
                    final input = (value ?? '').trim();
                    if (input.isEmpty) return 'Reference obligatoire';
                    if (input.length < 4) return 'Reference trop courte';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmer le paiement'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
