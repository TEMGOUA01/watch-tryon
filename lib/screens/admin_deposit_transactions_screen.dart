import 'package:flutter/material.dart';
import '../models/deposit_transaction.dart';
import '../services/deposit_transaction_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class AdminDepositTransactionsScreen extends StatefulWidget {
  const AdminDepositTransactionsScreen({super.key});

  @override
  State<AdminDepositTransactionsScreen> createState() => _AdminDepositTransactionsScreenState();
}

class _AdminDepositTransactionsScreenState extends State<AdminDepositTransactionsScreen> {
  String _status = 'paid';
  bool _loadingAction = false;

  Future<void> _validate(String id, DepositTransactionStatus status) async {
    setState(() => _loadingAction = true);
    try {
      await DepositTransactionService.instance.validateDeposit(
        transactionId: id,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction mise a jour: ${status.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _loadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Depots - Validation'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Deconnexion',
              onPressed: () => AuthService.instance.signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: AppTheme.glassDecoration(borderRadiusVal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    dropdownColor: AppTheme.surfaceColor,
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'paid', child: Text('Payes (a valider)')),
                      DropdownMenuItem(value: 'success', child: Text('Succes')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejetes')),
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'paid'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<DepositTransaction>>(
                stream: DepositTransactionService.instance.watchTransactionsByStatus(_status),
                builder: (context, snapshot) {
                  final txs = snapshot.data ?? const [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.secondaryColor),
                    );
                  }
                  if (txs.isEmpty) {
                    return const Center(
                      child: Text('Aucune transaction.', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final tx = txs[i];
                      final canAct = !_loadingAction && (tx.statut == 'paid' || tx.statut == 'pending');
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${tx.montant} FCFA',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(tx.statut, style: const TextStyle(color: AppTheme.secondaryColor)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('User: ${tx.userId}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            if ((tx.referenceRecu ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Ref: ${tx.referenceRecu}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: canAct ? () => _validate(tx.id, DepositTransactionStatus.rejected) : null,
                                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
                                    child: const Text('Rejeter'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: canAct ? () => _validate(tx.id, DepositTransactionStatus.success) : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Approuver'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
