import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onFileReportTap;

  const QuickActions({
    super.key,
    required this.onScanTap,
    required this.onFileReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RAPID DEPLOYMENT ACTIONS',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            color: TacticalTheme.outline,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // AI Scan Button
            Expanded(
              child: GestureDetector(
                onTap: onScanTap,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(color: TacticalTheme.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 2,
                        child: Container(color: TacticalTheme.primary),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.document_scanner,
                              color: TacticalTheme.primary,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'SCAN NOW (AI CAM)',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: TacticalTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // File Report Button
            Expanded(
              child: GestureDetector(
                onTap: onFileReportTap,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.edit_note,
                          color: TacticalTheme.onSurfaceVariant,
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'FILE REPORT',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: TacticalTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
