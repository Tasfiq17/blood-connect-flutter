import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class RareBloodSection extends StatelessWidget {
  final Map<String, int> bloodStats;

  const RareBloodSection({super.key, required this.bloodStats});

  static const List<String> rareGroups = ['AB-', 'O-', 'B-', 'A-'];
  static const int shortageThreshold = 5;
  static const int criticalThreshold = 2;

  Color _badgeColor(int count) {
    if (count == 0) return AppColors.danger;
    if (count <= criticalThreshold) return AppColors.warning;
    if (count <= shortageThreshold) return AppColors.rare;
    return AppColors.success;
  }

  String _statusLabel(int count) {
    if (count == 0) return "⚠ None Available";
    if (count <= criticalThreshold) return "⚠ Critical";
    if (count <= shortageThreshold) return "Low Stock";
    return "Available";
  }

  bool get hasCriticalShortage =>
      rareGroups.any((g) => (bloodStats[g] ?? 0) == 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.rare.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.rare, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Rare Blood Groups",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Donors with rare blood types — always in high demand.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          /// Critical Shortage Banner
          if (hasCriticalShortage) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency, color: AppColors.danger, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Critical Shortage! Some rare blood groups have 0 donors. Register as a donor now.",
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          /// Rare Blood Group Cards
          ...rareGroups.map((group) {
            final count = bloodStats[group] ?? 0;
            final color = _badgeColor(count);
            final status = _statusLabel(count);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// Blood Group Badge
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        group,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: color,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// Donor count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$count ${count == 1 ? 'Donor' : 'Donors'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Rare blood type · always needed",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
