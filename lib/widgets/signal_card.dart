import 'package:flutter/material.dart';
import '../models/signal.dart';
import '../theme/app_theme.dart';

class SignalCard extends StatelessWidget {
  final TradingSignal signal;

  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.type.toUpperCase() == "BUY";
    final isWin = signal.status == "WIN";
    final isLoss = signal.status == "LOSS";
    final isActive = signal.status == "ACTIVE";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(
        color: AppTheme.surfaceColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBuy ? AppTheme.successColor.withValues(alpha: 0.2) : AppTheme.errorColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBuy ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    child: Text(
                      signal.type.toUpperCase(),
                      style: TextStyle(
                        color: isBuy ? AppTheme.successColor : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    signal.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(isActive, isWin, isLoss),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSignalDetail("Entrée", signal.entryPrice),
              _buildSignalDetail("TP", signal.takeProfit, color: AppTheme.successColor),
              _buildSignalDetail("SL", signal.stopLoss, color: AppTheme.errorColor),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.secondaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                "Confiance : ${signal.confidence}%",
                style: const TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          if (signal.analysis.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.insights, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      signal.analysis,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignalDetail(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isWin, bool isLoss) {
    Color badgeColor;
    String badgeText;

    if (isActive) {
      badgeColor = AppTheme.warningColor;
      badgeText = "ACTIVE";
    } else if (isWin) {
      badgeColor = AppTheme.successColor;
      badgeText = "WIN";
    } else {
      badgeColor = AppTheme.errorColor;
      badgeText = "LOSS";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: badgeColor,
            size: 8,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
