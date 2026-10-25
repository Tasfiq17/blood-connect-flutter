import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class DonorCard extends StatelessWidget {
  final Map<String, dynamic> donor;

  const DonorCard({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    final name = donor['fullName'] ?? 'Unknown';
    final blood = donor['bloodGroup'] ?? '?';
    final district = donor['district'] ?? '';
    final address = donor['address'] ?? '';
    final phone = donor['phone'] ?? '';
    final gender = donor['gender'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Blood Group Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffE53935), Color(0xffC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                blood,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (address.toString().trim().isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                ],
                Row(
                  children: [
                    Icon(Icons.map_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Text(
                      district,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (gender.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.person_outline,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        gender,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          /// Call Button
          if (phone.isNotEmpty)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Call $name: $phone")),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call,
                    color: AppColors.primary, size: 22),
              ),
            ),
        ],
      ),
    );
  }
}
