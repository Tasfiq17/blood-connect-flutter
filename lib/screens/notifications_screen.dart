import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../services/dashboard_service.dart';

class NotificationsScreen extends StatelessWidget {
  final String bloodGroup;

  const NotificationsScreen({super.key, required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    final DashboardService service = DashboardService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Alerts"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.matchingRequestsStream(bloodGroup),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty || bloodGroup.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    bloodGroup.isEmpty 
                      ? "Set your blood group in profile to get alerts"
                      : "No new alerts for $bloodGroup",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data();
              final name = data['patientName'] ?? 'Unknown Patient';
              final hospital = data['hospital'] ?? 'Unknown Location';
              final phone = data['contact'] ?? 'No contact';
              final urgency = data['urgency'] ?? 'Normal';
              final time = (data['createdAt'] as Timestamp?)?.toDate();
              
              String timeStr = "Recently";
              if (time != null) {
                final diff = DateTime.now().difference(time);
                if (diff.inHours < 1) {
                  timeStr = "${diff.inMinutes} mins ago";
                } else if (diff.inDays < 1) {
                  timeStr = "${diff.inHours} hours ago";
                } else {
                  timeStr = "${diff.inDays} days ago";
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Urgent: $bloodGroup Needed",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$name ($urgency priority) is requesting blood at $hospital. Contact: $phone",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
