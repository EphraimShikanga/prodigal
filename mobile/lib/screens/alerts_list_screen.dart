import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/mock_data.dart';
import '../widgets/amber_alert_card.dart';
import 'alert_detail_screen.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

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
                Icons.warning,
                color: TacticalTheme.secondaryContainer,
                size: 20,
              ),
            ),
            title: const Text(
              'ACTIVE AMBER ALERTS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: TacticalTheme.primary,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Text(
                'NO ACTIVE ALERTS IN GEOFENCE',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  color: TacticalTheme.outline,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AlertDetailScreen(alert: alert),
                      ),
                    );
                  },
                  child: AmberAlertCard(alert: alert),
                );
              },
            ),
    );
  }
}
