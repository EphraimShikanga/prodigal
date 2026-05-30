import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../widgets/amber_alert_card.dart';
import '../widgets/recent_sightings.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: const [
              // 1. HERO AMBER ALERT CARD
              AmberAlertCard(),
              SizedBox(height: 20),

              // 2. SIGHTINGS FEED
              RecentSightingsFeed(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
