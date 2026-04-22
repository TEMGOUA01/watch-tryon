import 'package:flutter/material.dart';
import '../models/mining_machine.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/aureus_background.dart';

class MachineDetailScreen extends StatelessWidget {
  final MiningMachine machine;
  final bool isOwned;
  final DateTime? dateAchat;
  final bool? statutActif;

  const MachineDetailScreen({
    super.key,
    required this.machine,
    this.isOwned = false,
    this.dateAchat,
    this.statutActif,
  });

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(machine.nom),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildInfoGrid(),
              const SizedBox(height: 24),
              _buildInstructionsSection(),
              const SizedBox(height: 24),
              _buildWarningSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.goldGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: machine.icone != null
              ? ClipOval(
                  child: Image.network(
                    machine.icone!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                  ),
                )
              : _buildFallbackIcon(),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.memory, size: 60, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          'LVL ${machine.niveau}',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Caractéristiques Techniques',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _buildInfoTile('Prix d\'achat', formatCfa(machine.prixCfa), Icons.shopping_cart),
              _buildInfoTile('Rendement', '${formatCfa(machine.rendementJourCfa)}/j', Icons.auto_graph),
              _buildInfoTile('Temps de cycle', '${machine.cycleMinutes} min', Icons.timer),
              _buildInfoTile('Cycles / jour', '${machine.minesPerDay}', Icons.loop),
              _buildInfoTile('Gain / cycle', formatCfa(machine.rewardPerMineCfa), Icons.monetization_on),
              if (isOwned) ...[
                _buildInfoTile('Statut', (statutActif ?? false) ? 'Active' : 'Inactive', (statutActif ?? false) ? Icons.check_circle : Icons.error, color: (statutActif ?? false) ? AppTheme.successColor : Colors.grey),
                _buildInfoTile('Date d\'achat', dateAchat != null ? '${dateAchat!.day}/${dateAchat!.month}/${dateAchat!.year}' : 'N/A', Icons.calendar_today),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? AppTheme.secondaryColor, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment fonctionne le minage ?',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '1',
            'Minage Automatique',
            'La machine mine automatiquement 24h/24 sans que vous ayez besoin de laisser l\'application ouverte.',
          ),
          _buildInstructionStep(
            '2',
            'Cycles de Minage',
            'Chaque cycle dure ${machine.cycleMinutes} minutes et génère ${formatCfa(machine.rewardPerMineCfa)}.',
          ),
          _buildInstructionStep(
            '3',
            'Collecte des gains',
            'Vous pouvez collecter vos gains (Claim) à tout moment dès qu\'un cycle est complété.',
          ),
          _buildInstructionStep(
            '4',
            'Accumulation',
            'Les gains non collectés s\'accumulent sur un maximum de 7 jours. Pensez à réclamer régulièrement !',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Avertissement',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Une machine peut tomber en panne, bien que cela soit très rare. En cas de dysfonctionnement prolongé, veuillez contacter le service client via le bouton d\'aide.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
