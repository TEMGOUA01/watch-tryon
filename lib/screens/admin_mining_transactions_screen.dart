import 'package:flutter/material.dart';
import '../models/mining_transaction.dart';
import '../services/mining_transaction_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/aureus_background.dart';

class AdminMiningTransactionsScreen extends StatefulWidget {
  const AdminMiningTransactionsScreen({super.key});

  @override
  State<AdminMiningTransactionsScreen> createState() => _AdminMiningTransactionsScreenState();
}

class _AdminMiningTransactionsScreenState extends State<AdminMiningTransactionsScreen> {
  String _filter = 'paid';

  Stream<List<MiningTransaction>> _streamForFilter() {
    if (_filter == 'all') {
      return MiningTransactionService.instance.watchAllTransactions();
    }
    return MiningTransactionService.instance.watchTransactionsByStatus(_filter);
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Validation paiements mining'),
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
                    value: _filter,
                    dropdownColor: const Color(0xFF121826),
                    iconEnabledColor: Colors.white70,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'paid', child: Text('Payees (a valider)')),
                      DropdownMenuItem(value: 'success', child: Text('Approuvees')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejetees')),
                      DropdownMenuItem(value: 'all', child: Text('Toutes')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filter = v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<MiningTransaction>>(
                stream: _streamForFilter(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.secondaryColor),
                    );
                  }
                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune transaction.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = items[index];
                      final canValidate =
                          tx.statut == MiningTransactionStatus.paid || tx.statut == MiningTransactionStatus.pending;

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
                                    'Ref: ${tx.referenceRecu}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tx.statut.name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('User: ${tx.userId}', style: const TextStyle(color: Colors.white70)),
                            Text('Machine: ${tx.machineId}', style: const TextStyle(color: Colors.white70)),
                            Text(
                              'Montant: ${formatCfa(tx.montant)}',
                              style: const TextStyle(color: AppTheme.secondaryColor),
                            ),
                            Text(
                              'Telephone: ${tx.telephoneUtilisateur}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: canValidate
                                        ? () => _updateStatus(
                                              context,
                                              tx.id,
                                              MiningTransactionStatus.rejected,
                                            )
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                    ),
                                    child: const Text('Rejeter'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: canValidate
                                        ? () => _updateStatus(
                                              context,
                                              tx.id,
                                              MiningTransactionStatus.success,
                                            )
                                        : null,
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

  Future<void> _updateStatus(
    BuildContext context,
    String transactionId,
    MiningTransactionStatus status,
  ) async {
    try {
      await MiningTransactionService.instance.validateTransaction(
        transactionId: transactionId,
        status: status,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction ${status.name}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
