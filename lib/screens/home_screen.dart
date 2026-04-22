import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/wallet_transaction.dart';
import '../services/signal_service.dart';
import '../services/user_service.dart';
import '../services/wallet_service.dart';
import '../services/user_machine_service.dart';
import '../models/signal.dart';
import '../models/user_machine.dart';
import '../widgets/signal_card.dart';
import 'signals_screen.dart';
import 'mining_machines_screen.dart';
import 'my_mining_machines_screen.dart';
import 'deposit_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class FictivePerformanceSection extends StatefulWidget {
  const FictivePerformanceSection({super.key});

  @override
  State<FictivePerformanceSection> createState() => _FictivePerformanceSectionState();
}

class _FictivePerformanceSectionState extends State<FictivePerformanceSection> {
  final math.Random _rng = math.Random();
  late int _winRate;
  late int _wins;
  late int _losses;

  @override
  void initState() {
    super.initState();
    _wins = 120 + _rng.nextInt(60);
    _losses = 30 + _rng.nextInt(30);
    _winRate = ((_wins / (_wins + _losses)) * 100).round();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 4));
      if (!mounted) break;
      setState(() {
        final d = _rng.nextInt(5) - 2;
        _winRate = (_winRate + d).clamp(45, 92);
        _wins += _rng.nextInt(3);
        _losses += _rng.nextInt(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Signaux',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Taux de réussite', '$_winRate%', Colors.white),
              _buildStatItem('Gagnants', '$_wins', Colors.green),
              _buildStatItem('Perdants', '$_losses', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: UserService.instance.watchCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        final displayName = (profile?.name.isNotEmpty ?? false)
            ? profile!.name
            : 'Utilisateur';
        final avatar = (profile?.avatar.isNotEmpty ?? false) ? profile!.avatar : '🦁';
        final balance = profile?.balance ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFF0B0F1A),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Header(userName: displayName, avatar: avatar),
                  const SizedBox(height: 30),
                  PortfolioCard(balanceFcfa: balance),
                  const SizedBox(height: 30),
                  const GoldChartSection(),
                  const SizedBox(height: 30),
                  const QuickActions(),
                  const SizedBox(height: 30),
                  const FictivePerformanceSection(),
                  const SizedBox(height: 30),
                  const SignalDuMomentSection(),
                  const SizedBox(height: 30),
                  const MiningAccessSection(),
                  const SizedBox(height: 30),
                  const TransactionListSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  final String userName;
  final String avatar;

  const Header({
    super.key,
    required this.userName,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1A2235),
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue,',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.notifications_none, color: Colors.white),
            SizedBox(width: 16),
            Icon(Icons.settings, color: Colors.white),
          ],
        )
      ],
    );
  }
}

class PortfolioCard extends StatelessWidget {
  final int balanceFcfa;

  const PortfolioCard({
    super.key,
    required this.balanceFcfa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2235),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            "$balanceFcfa FCFA",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "0 operation enregistree",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ChartPlaceholder extends StatelessWidget {
  const ChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Graphique indisponible",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ActionButton(
          icon: Icons.add,
          label: "Buy",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiningMachinesScreen()),
            );
          },
        ),
        ActionButton(
          icon: Icons.arrow_upward,
          label: "Sell",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyMiningMachinesScreen()),
            );
          },
        ),
        ActionButton(
          icon: Icons.account_balance_wallet,
          label: "Deposit",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DepositRequestScreen()),
            );
          },
        ),
        ActionButton(
          icon: Icons.swap_horiz,
          label: "Swap",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Swap: bientot disponible.')),
            );
          },
        ),
      ],
    );
  }
}

class GoldChartSection extends StatefulWidget {
  const GoldChartSection({super.key});

  @override
  State<GoldChartSection> createState() => _GoldChartSectionState();
}

class _GoldChartSectionState extends State<GoldChartSection> {
  final math.Random _rng = math.Random();
  late List<double> _points;
  late double _last;

  @override
  void initState() {
    super.initState();
    _last = 2360 + _rng.nextDouble() * 40;
    _points = List.generate(24, (_) {
      _last += (_rng.nextDouble() - 0.5) * 8;
      return _last;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) break;
      setState(() {
        _last += (_rng.nextDouble() - 0.5) * 10;
        _points = [..._points.skip(1), _last];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _points.isNotEmpty ? _points.last : 0;
    final prev = _points.length > 1 ? _points[_points.length - 2] : last;
    final delta = last - prev;
    final up = delta >= 0;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cours de l\'or (XAUUSD)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                '${last.toStringAsFixed(2)}  ${up ? '+' : ''}${delta.toStringAsFixed(2)}',
                style: TextStyle(
                  color: up ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: CustomPaint(
              painter: _BalanceChartPainter(points: _points),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2235),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }
}

class TransactionListSection extends StatelessWidget {
  const TransactionListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalletTransaction>>(
      stream: WalletService.instance.watchRecentTransactions(limit: 8),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? const [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121826),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transactions recentes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                const Text(
                  "Aucune transaction pour le moment.",
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...transactions.map((tx) {
                  final positive = tx.signedAmount >= 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          positive ? Icons.call_received : Icons.call_made,
                          color: positive ? Colors.green : Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _txLabel(tx.type),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          '${positive ? '+' : ''}${tx.signedAmount} FCFA',
                          style: TextStyle(
                            color: positive ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  String _txLabel(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.deposit:
        return 'Depot';
      case WalletTransactionType.buy:
        return 'Achat';
      case WalletTransactionType.sell:
        return 'Vente';
      case WalletTransactionType.swap:
        return 'Swap';
    }
  }
}

class MiningAccessSection extends StatelessWidget {
  const MiningAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserMachine>>(
      stream: UserMachineService.instance.watchMyMachines(),
      builder: (context, snapshot) {
        final machines = snapshot.data ?? const [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121826),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Machines de mining',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Machines actives: ${machines.where((m) => m.statutActif).length}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyMiningMachinesScreen()),
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Mes machines / Claim'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MiningMachinesScreen()),
                    );
                  },
                  icon: const Icon(Icons.memory),
                  label: const Text('Acheter une machine'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WalletChartSection extends StatelessWidget {
  const WalletChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder<List<WalletTransaction>>(
        stream: WalletService.instance.watchRecentTransactions(limit: 20),
        builder: (context, snapshot) {
          final raw = snapshot.data ?? const [];
          final points = raw.reversed.map((e) => e.balanceAfter.toDouble()).toList();

          if (points.length < 2) {
            return const Center(
              child: Text(
                "Graphique disponible apres 2 transactions",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evolution du solde',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  painter: _BalanceChartPainter(points: points),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceChartPainter extends CustomPainter {
  final List<double> points;

  _BalanceChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x55D4AF37), Color(0x000B0F1A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = points.reduce(math.max);
    final minValue = points.reduce(math.min);
    final range = (maxValue - minValue).abs() < 1 ? 1.0 : (maxValue - minValue);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final dx = (i / (points.length - 1)) * size.width;
      final normalized = (points[i] - minValue) / range;
      final dy = size.height - (normalized * (size.height - 6)) - 3;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(area, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BalanceChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class PerformanceSection extends StatelessWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final signalService = SignalService();
    
    return StreamBuilder<Map<String, dynamic>>(
      stream: signalService.getPerformanceStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final stats = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2235),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Performance Signaux",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem("Taux de réussite", "${stats['winRate']}%", Colors.white),
                  _buildStatItem("Gagnants", "${stats['wins']}", Colors.green),
                  _buildStatItem("Perdants", "${stats['losses']}", Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class SignalDuMomentSection extends StatelessWidget {
  const SignalDuMomentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final signalService = SignalService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Signal du moment",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignalsScreen()),
                );
              },
              child: const Text(
                "Voir tous",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<TradingSignal?>(
          stream: signalService.getLatestActiveSignal(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121826),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Aucun signal actif pour le moment",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return SignalCard(signal: snapshot.data!);
          },
        ),
      ],
    );
  }
}
