import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class TacticalBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TacticalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: TacticalTheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: TacticalTheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.dashboard,
              label: 'Dashboard',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.radar,
              label: 'Radar',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.add_box,
              label: 'Report',
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.campaign,
              label: 'Alerts',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.account_circle,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? TacticalTheme.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? TacticalTheme.onSecondary
                  : TacticalTheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
