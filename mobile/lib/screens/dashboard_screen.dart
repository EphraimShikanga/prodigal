import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../widgets/amber_alert_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_sightings.dart';
import '../widgets/verification_matrix.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onFileReportTap;

  const DashboardScreen({
    super.key,
    this.onFileReportTap,
  });

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
            children: [
              // 1. HERO AMBER ALERT CARD
              const AmberAlertCard(),
              const SizedBox(height: 20),

              // 2. QUICK ACTIONS
              QuickActions(
                onScanTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Camera scanner launching...'),
                      backgroundColor: TacticalTheme.surfaceContainer,
                    ),
                  );
                },
                onFileReportTap: onFileReportTap ?? () {},
              ),
              const SizedBox(height: 20),

              // 3. SIGHTINGS FEED
              const RecentSightingsFeed(),
              const SizedBox(height: 20),

              // 4. METRICS / STATS
              const VerificationMatrix(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
