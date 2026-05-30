import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/mock_data.dart';

class RecentSightingsFeed extends StatefulWidget {
  final List<SightingModel> sightings;

  const RecentSightingsFeed({
    super.key,
    required this.sightings,
  });

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
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(12),
          child: widget.sightings.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'NO ACTIVE SIGHTINGS LOGGED',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: TacticalTheme.outline,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.sightings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sighting = widget.sightings[index];
                    Color severityColor;
                    Color borderColor;

                    if (sighting.severity == 'VERIFIED') {
                      severityColor = TacticalTheme.primary;
                      borderColor = TacticalTheme.primary;
                    } else if (sighting.severity == 'USER_REPORT') {
                      severityColor = TacticalTheme.outline;
                      borderColor = TacticalTheme.outlineVariant;
                    } else {
                      severityColor = TacticalTheme.secondaryContainer;
                      borderColor = TacticalTheme.secondaryContainer;
                    }

                    return _buildSightingItem(
                      type: sighting.type,
                      typeColor: severityColor,
                      time: sighting.time,
                      description: sighting.description,
                      borderColor: borderColor,
                    );
                  },
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
