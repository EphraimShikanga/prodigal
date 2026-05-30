import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/mock_data.dart';
import '../widgets/amber_alert_card.dart';
import '../widgets/recent_sightings.dart';

class AlertDetailScreen extends StatelessWidget {
  final AmberAlertModel alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalTheme.background,
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
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: TacticalTheme.onSurfaceVariant,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'ALERT DETAILS: ${alert.id}',
              style: const TextStyle(
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Details Card for the specific child
              AmberAlertCard(alert: alert),
              
              const SizedBox(height: 24),
              
              // Dynamic linked sightings feed
              RecentSightingsFeed(sightings: alert.sightings),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
