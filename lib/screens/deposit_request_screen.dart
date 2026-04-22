import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deposit_transaction_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class DepositRequestScreen extends StatefulWidget {
  const DepositRequestScreen({super.key});

  @override
  State<DepositRequestScreen> createState() => _DepositRequestScreenState();
}

class _DepositRequestScreenState extends State<DepositRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  bool _loading = false;

  static const String _depositNumber = '678749641';

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final ref = _refController.text.trim();

    setState(() => _loading = true);
    try {
      await DepositTransactionService.instance.createPaidDeposit(
        montant: amount,
        referenceRecu: ref,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depot declare. En attente de validation admin.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Depot (manuel)'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Numero de depot',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                _depositNumber,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copier',
                              onPressed: () async {
                                await Clipboard.setData(const ClipboardData(text: _depositNumber));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Numero copie.')),
                                );
                              },
                              icon: const Icon(Icons.copy, color: AppTheme.secondaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Faites le depot sur ce numero. Ensuite, remplissez le montant et la reference, puis appuyez sur "J\'ai paye (Paid)".',
                          style: TextStyle(color: Colors.white60, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Montant (FCFA)',
                      prefixIcon: Icon(Icons.payments_outlined, color: AppTheme.secondaryColor),
                    ),
                    validator: (v) {
                      final a = int.tryParse((v ?? '').trim());
                      if (a == null || a <= 0) return 'Montant invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _refController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Reference recu / transaction',
                      prefixIcon: Icon(Icons.receipt_long, color: AppTheme.secondaryColor),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Reference requise' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                            )
                          : const Text("J'ai paye (Paid)", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
