import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/mock_data.dart';
import '../screens/report_sighting_screen.dart';

class AmberAlertCard extends StatelessWidget {
  final AmberAlertModel alert;

  const AmberAlertCard({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Amber side border
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: TacticalTheme.secondaryContainer),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActiveAlertBadge(),
                    Text(
                      '#${alert.id}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: TacticalTheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Layout changes for mobile view
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: TacticalTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Age: ${alert.age}   •   Ht: ${alert.height}   •   Wt: ${alert.weight}',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: TacticalTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            alert.description,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              height: 1.4,
                              color: TacticalTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Grayscale Image Component (Fixed size to prevent wide screen scaling overflows)
                    Container(
                      width: 100,
                      height: 110,
                      decoration: BoxDecoration(
                        color: TacticalTheme.surfaceHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: TacticalTheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, -20,
                          0.2126, 0.7152, 0.0722, 0, 10,
                          0.2126, 0.7152, 0.0722, 0, 40,
                          0,      0,      0,      0.8, 0,
                        ]),
                        child: Image.network(
                          alert.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.portrait, size: 40, color: TacticalTheme.outline),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFF222222)),

                // Location and Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAST KNOWN LOCATION',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: TacticalTheme.outline,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: TacticalTheme.secondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert.lastSeenLocation,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: TacticalTheme.onSurface.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.coordinates,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            color: TacticalTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TIME ELAPSED',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: TacticalTheme.outline,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: TacticalTheme.secondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert.timeElapsed,
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: TacticalTheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Report Sighting Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalTheme.secondaryContainer,
                      foregroundColor: TacticalTheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      elevation: 4,
                      shadowColor: TacticalTheme.secondaryContainer.withOpacity(0.3),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReportSightingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_location_alt, size: 16),
                    label: const Text(
                      'REPORT SIGHTING',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalTheme.secondaryContainer.withOpacity(0.15),
        border: Border.all(color: TacticalTheme.secondaryContainer.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: TacticalTheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'ACTIVE AMBER ALERT',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: TacticalTheme.secondaryContainer,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
