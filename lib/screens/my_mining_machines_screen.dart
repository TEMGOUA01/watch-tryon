import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mining_machine.dart';
import '../models/user_machine.dart';
import '../services/mining_machine_service.dart';
import '../services/user_machine_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';
import 'machine_detail_screen.dart';

class MyMiningMachinesScreen extends StatelessWidget {
  const MyMiningMachinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mes Machines'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder<List<UserMachine>>(
          stream: UserMachineService.instance.watchMyMachines(),
          builder: (context, snapshot) {
            final machines = snapshot.data ?? const [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.secondaryColor),
              );
            }

            if (machines.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune machine achetée.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: machines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final userMachine = machines[index];
                return _UserMachineCard(userMachine: userMachine);
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserMachineCard extends StatelessWidget {
  final UserMachine userMachine;
  const _UserMachineCard({required this.userMachine});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MiningMachine?>(
      future: MiningMachineService.instance.getMachineById(userMachine.machineId),
      builder: (context, snapshot) {
        final machine = snapshot.data;
        final isActive = userMachine.statutActif;

        return GestureDetector(
          onTap: () {
            if (machine != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MachineDetailScreen(
                    machine: machine,
                    isOwned: true,
                    dateAchat: userMachine.dateAchat,
                    statutActif: userMachine.statutActif,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(borderRadiusVal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(Icons.memory, color: AppTheme.secondaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machine?.nom ?? 'Machine niveau ${userMachine.niveau}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? AppTheme.successColor : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (machine != null)
                    Text(
                      '${machine.rendementJourCfa} / jour',
                      style: const TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (machine == null)
                const Text(
                  'Chargement de la machine...',
                  style: TextStyle(color: Colors.white70),
                )
              else
                _ClaimSection(machine: machine, userMachine: userMachine),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _ClaimSection extends StatefulWidget {
  final MiningMachine machine;
  final UserMachine userMachine;
  const _ClaimSection({required this.machine, required this.userMachine});

  @override
  State<_ClaimSection> createState() => _ClaimSectionState();
}

class _ClaimSectionState extends State<_ClaimSection> with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estimate = UserMachineService.instance.estimateClaim(
      machine: widget.machine,
      userMachine: widget.userMachine,
      now: DateTime.now(),
    );

    final claimable = estimate.claimableAmount;
    final nextIn = estimate.nextMineIn;
    final isMining = widget.userMachine.statutActif && claimable <= 0 && nextIn != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMining) ...[
          Row(
            children: [
              FadeTransition(
                opacity: _pulseAnimation,
                child: const Text('⛏️ ', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _pulseAnimation,
                  child: const Text(
                    'Minage en cours...',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Text(
                _formatDuration(nextIn),
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Disponible: $claimable FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                nextIn == null ? 'Prêt' : 'Prochain minage: ${_formatDuration(nextIn)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _loading || claimable <= 0 || !widget.userMachine.statutActif
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      final amount = await UserMachineService.instance.collectMiningRewards(
                        userMachineId: widget.userMachine.id,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Collecté: $amount FCFA'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : Text(
                    isMining ? 'En minage...' : 'Claim / Collecter',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    if (totalSeconds <= 0) return '0s';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}
