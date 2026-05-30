import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class VerificationMatrix extends StatelessWidget {
  const VerificationMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERIFICATION MATRIX',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            color: TacticalTheme.outline,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Large Percentage Success Rate
              const Center(
                child: Column(
                  children: [
                    Text(
                      '84.2%',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'SUCCESS RATE (30D)',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        color: TacticalTheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress bars
              _buildProgressRow(
                label: 'VERIFIED CASES',
                value: '1,204',
                percentage: 0.75,
                color: TacticalTheme.primary,
              ),
              const SizedBox(height: 12),
              _buildProgressRow(
                label: 'RECOVERED',
                value: '1,014',
                percentage: 0.842,
                color: TacticalTheme.successGreen,
              ),
              const SizedBox(height: 12),
              _buildProgressRow(
                label: 'ACTIVE SEARCHES',
                value: '12',
                percentage: 0.05,
                color: TacticalTheme.secondaryContainer,
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFF222222)),
              const SizedBox(height: 8),

              // Footnote
              const Center(
                child: Text(
                  '"Data density prioritized. Trust verified."',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: TacticalTheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow({
    required String label,
    required String value,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: TacticalTheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: TacticalTheme.surfaceHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
