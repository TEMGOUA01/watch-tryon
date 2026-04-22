import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';
import 'admin_dashboard_screen.dart';
import 'admin_formations_screen.dart';
import 'admin_signals_screen.dart';
import 'admin_mining_transactions_screen.dart';
import 'admin_deposit_transactions_screen.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Espace Administrateur'),
          centerTitle: true,
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
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _AdminBalancePanel(),
            const SizedBox(height: 14),
            const _AdminStatsPanel(),
            const SizedBox(height: 14),
            const _AdminActionsPanel(),
            const SizedBox(height: 14),
            const _UsersManagementPanel(),
          ],
        ),
      ),
    );
  }
}

class _AdminBalancePanel extends StatelessWidget {
  const _AdminBalancePanel();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final balance = (snapshot.data?.data()?['balance'] as num?)?.toInt() ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: AppTheme.secondaryColor),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Solde Admin',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$balance FCFA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminStatsPanel extends StatelessWidget {
  const _AdminStatsPanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, txSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnapshot) {
            final usersCount = usersSnapshot.data?.docs.length ?? 0;
            final txs = txSnapshot.data?.docs ?? const [];
            int pending = 0;
            int success = 0;
            int rejected = 0;
            for (final doc in txs) {
              final status = (doc.data()['statut'] as String?) ?? 'pending';
              if (status == 'success') {
                success++;
              } else if (status == 'rejected') {
                rejected++;
              } else {
                pending++;
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('Clients', '$usersCount', Colors.white),
                  _statItem('Pending', '$pending', Colors.orangeAccent),
                  _statItem('Success', '$success', Colors.green),
                  _statItem('Rejected', '$rejected', Colors.redAccent),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _AdminActionsPanel extends StatelessWidget {
  const _AdminActionsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
      child: Column(
        children: [
          _actionTile(
            context,
            icon: Icons.payments_outlined,
            title: 'Transactions mining',
            subtitle: 'Valider / rejeter les paiements',
            target: const AdminMiningTransactionsScreen(),
          ),
          _actionTile(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Depots',
            subtitle: 'Valider / rejeter les depots',
            target: const AdminDepositTransactionsScreen(),
          ),
          _actionTile(
            context,
            icon: Icons.signal_cellular_alt,
            title: 'Gestion signaux',
            subtitle: 'Créer et gérer les signaux',
            target: const AdminSignalsScreen(),
          ),
          _actionTile(
            context,
            icon: Icons.school_outlined,
            title: 'Gestion formations',
            subtitle: 'Ajouter et supprimer les formations',
            target: const AdminFormationsScreen(),
          ),
          _actionTile(
            context,
            icon: Icons.dashboard_customize,
            title: 'Dashboard avancé',
            subtitle: 'Vue d’ensemble administrateur',
            target: const AdminDashboardScreen(),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget target,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => target));
      },
    );
  }
}

class _UsersManagementPanel extends StatelessWidget {
  const _UsersManagementPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clients utilisateurs',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('updatedAt', descending: true)
                .limit(25)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(color: AppTheme.secondaryColor),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Erreur utilisateurs: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                );
              }

              final docs = snapshot.data?.docs ?? const [];
              if (docs.isEmpty) {
                return const Text(
                  'Aucun client trouve.',
                  style: TextStyle(color: Colors.white70),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final name = (data['name'] as String?)?.trim();
                  final email = (data['email'] as String?)?.trim() ?? 'Email inconnu';
                  final role = ((data['role'] as String?)?.trim().toLowerCase() ?? 'user');
                  final balance = (data['balance'] as num?)?.toInt() ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: role == 'admin'
                          ? AppTheme.secondaryColor
                          : Colors.grey.shade800,
                      child: Text(
                        (name?.isNotEmpty == true ? name![0] : email[0]).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name?.isNotEmpty == true ? name! : 'Utilisateur',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '$email\nRole: $role | Balance: $balance FCFA',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    isThreeLine: true,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
