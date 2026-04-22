import 'package:flutter/material.dart';
import '../models/mining_machine.dart';
import '../services/mining_machine_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/aureus_background.dart';
import 'mining_payment_screen.dart';
import 'machine_detail_screen.dart';

class MiningMachinesScreen extends StatefulWidget {
  const MiningMachinesScreen({super.key});

  @override
  State<MiningMachinesScreen> createState() => _MiningMachinesScreenState();
}

class _MiningMachinesScreenState extends State<MiningMachinesScreen> {
  @override
  void initState() {
    super.initState();
    MiningMachineService.instance.seedDefaultMachinesIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Machines de mining'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder<List<MiningMachine>>(
          stream: MiningMachineService.instance.watchActiveMachines(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Erreur de chargement des machines.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () async {
                          await MiningMachineService.instance.seedDefaultMachinesIfEmpty();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nouvelle tentative de chargement.')),
                          );
                        },
                        child: const Text('Reessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.secondaryColor),
              );
            }
            final machines = snapshot.data ?? const [];
            if (machines.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune machine disponible pour le moment.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: machines.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) => _MachineCard(machine: machines[index]),
            );
          },
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final MiningMachine machine;

  const _MachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineDetailScreen(
              machine: machine,
              isOwned: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.glassDecoration(borderRadiusVal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.memory, color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Niveau ${machine.niveau}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            machine.nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Prix: ${formatCfa(machine.prixCfa)}',
            style: const TextStyle(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rendement: ${formatCfa(machine.rendementJourCfa)} / jour',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MiningPaymentScreen(machine: machine),
                  ),
                );
              },
              child: const Text('Acheter'),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
