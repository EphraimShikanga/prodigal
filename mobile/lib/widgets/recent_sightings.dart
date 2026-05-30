import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class RecentSightingsFeed extends StatefulWidget {
  const RecentSightingsFeed({super.key});

  @override
  State<RecentSightingsFeed> createState() => _RecentSightingsFeedState();
}

class _RecentSightingsFeedState extends State<RecentSightingsFeed>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT SIGHTINGS FEED',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: TacticalTheme.outline,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseAnimation.value,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: TacticalTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TacticalTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildSightingItem(
                type: 'UNVERIFIED_MATCH',
                typeColor: TacticalTheme.secondaryContainer,
                time: 'T-14 MINS',
                description: 'Traffic Cam #402, Ngong Road. Partial facial match (62%).',
                borderColor: TacticalTheme.secondaryContainer,
              ),
              const SizedBox(height: 8),
              _buildSightingItem(
                type: 'USER_REPORT',
                typeColor: TacticalTheme.outline,
                time: 'T-38 MINS',
                description: 'Citizen reported seeing child matching description at local market.',
                borderColor: TacticalTheme.outlineVariant,
              ),
              const SizedBox(height: 8),
              _buildSightingItem(
                type: 'VERIFIED_TRACK',
                typeColor: TacticalTheme.primary,
                time: 'T-52 MINS',
                description: 'CCTV feed confirmed direction of travel North-West.',
                borderColor: TacticalTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSightingItem({
    required String type,
    required Color typeColor,
    required String time,
    required String description,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TacticalTheme.surfaceHigh,
        border: Border(
          left: BorderSide(color: borderColor, width: 2),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: TacticalTheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: TacticalTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
