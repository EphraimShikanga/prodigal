import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/mock_data.dart';
import '../widgets/amber_alert_card.dart';
import '../widgets/recent_sightings.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onViewAllAlertsTap;

  const DashboardScreen({
    super.key,
    this.onViewAllAlertsTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentAlertIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = MockData.activeAlerts;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: TacticalTheme.background,
            border: Border(
              bottom: BorderSide(
                color: TacticalTheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(
                Icons.security,
                color: TacticalTheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            title: const Text(
              'RECOVERY_OPS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: TacticalTheme.primary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: TacticalTheme.onSurfaceVariant,
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: TacticalTheme.secondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TacticalTheme.background,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new alerts. Network status nominal.'),
                      backgroundColor: TacticalTheme.surfaceContainer,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CAROUSEL SECTION HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE AMBER ALERTS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: TacticalTheme.outline,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (alerts.isNotEmpty)
                    GestureDetector(
                      onTap: widget.onViewAllAlertsTap,
                      child: Row(
                        children: [
                          Text(
                            'VIEW ALL (${alerts.length} ACTIVE)',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: TacticalTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 10, color: TacticalTheme.primary),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. SWIPABLE AMBER ALERTS CAROUSEL
              if (alerts.isEmpty)
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NO ACTIVE AMBER ALERTS',
                    style: TextStyle(fontFamily: 'JetBrains Mono', color: TacticalTheme.outline),
                  ),
                )
              else ...[
                SizedBox(
                  height: 380, // Safe height to prevent clipping
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: alerts.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentAlertIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return AmberAlertCard(alert: alerts[index]);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Dot Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(alerts.length, (index) {
                    final isSelected = index == _currentAlertIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? TacticalTheme.primary : TacticalTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),

              // 3. SIGHTINGS FEED
              RecentSightingsFeed(
                sightings: alerts.isNotEmpty && _currentAlertIndex < alerts.length
                    ? alerts[_currentAlertIndex].sightings
                    : const [],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
