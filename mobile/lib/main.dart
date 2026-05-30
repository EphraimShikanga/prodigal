import 'package:flutter/material.dart';
import 'theme/tactical_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/report_missing_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const ProdigalApp());
}

class ProdigalApp extends StatelessWidget {
  const ProdigalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARGUS-KE Recovery Ops',
      debugShowCheckedModeBanner: false,
      theme: TacticalTheme.themeData,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Screens corresponding to each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const RadarPlaceholder(),
      ReportMissingScreen(
        onBackToHome: () => _onTabTapped(0),
      ),
      const ReportsPlaceholder(),
      const ProfilePlaceholder(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: TacticalBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// Custom Tactical Placeholder for Radar View
class RadarPlaceholder extends StatelessWidget {
  const RadarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: TacticalTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TacticalTheme.primary.withOpacity(0.05),
                  border: Border.all(color: TacticalTheme.primary.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.radar,
                  size: 64,
                  color: TacticalTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'RADAR SCANNER ACTIVE',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: TacticalTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monitoring local edge cameras for face matches...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: TacticalTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Tactical Placeholder for Reports View
class ReportsPlaceholder extends StatelessWidget {
  const ReportsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: TacticalTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TacticalTheme.outline.withOpacity(0.05),
                  border: Border.all(color: TacticalTheme.outlineVariant.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.description,
                  size: 64,
                  color: TacticalTheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'INCIDENT LOGS & REPORTS',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: TacticalTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No pending high-integrity file logs.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: TacticalTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Tactical Placeholder for Profile View
class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: TacticalTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TacticalTheme.secondaryContainer.withOpacity(0.05),
                  border: Border.all(color: TacticalTheme.secondaryContainer.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.account_circle,
                  size: 64,
                  color: TacticalTheme.secondaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'OPERATOR PROFILE',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: TacticalTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Logged in as Operator #802 (Ephraim Shikanga)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: TacticalTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
