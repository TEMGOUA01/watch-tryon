import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../models/formationt.dart';
import '../services/formation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class FormationsScreen extends StatelessWidget {
  const FormationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(LanguageService().getText('nos_formations')),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<List<Formation>>(
          stream: FormationService.watchFormations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune formation disponible.', style: TextStyle(color: Colors.white70)));
            }

            final formations = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.only(
                left: isTablet ? 24.0 : 16.0,
                right: isTablet ? 24.0 : 16.0,
                top: 8.0,
                bottom: 16.0,
              ),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                return _buildFormationCard(formations[index], isTablet);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormationCard(Formation formation, bool isTablet) {
    final cardHeight = isTablet ? 160.0 : 140.0;
    final imageSize = isTablet ? 120.0 : 90.0;

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec cadre doré
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.network(
                    formation.imageUrl,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, p) {
                      if (p == null) return child;
                      return Container(color: AppTheme.surfaceColor, child: const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor, strokeWidth: 2)));
                    },
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceColor, child: const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formation.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    formation.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formation.price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryColor.withValues(alpha: 0.7)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
