// lib/presentation/applications/views/application_status_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/application_model.dart';
import '../../../data/models/enum.dart';
import '../controllers/applications.controller.dart';

class ApplicationStatusScreenView extends GetView<ApplicationsController> {
  const ApplicationStatusScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final Application application = Get.arguments['application'] as Application;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Application Status'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (application.canWithdraw)
            IconButton(
              onPressed: () => controller.withdrawApplication(application),
              icon: const Icon(Icons.undo),
              tooltip: 'Withdraw Application',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Info Card
            _buildJobInfoCard(application),
            const SizedBox(height: 16),

            // Status Timeline
            _buildStatusTimeline(application),
            const SizedBox(height: 16),

            // Application Details
            _buildApplicationDetails(application),
            const SizedBox(height: 16),

            // Group Access Card
            if (application.hasGroupAccess) _buildGroupAccessCard(application),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfoCard(Application application) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobDetails.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.jobDetails.companyName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.jobDetails.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: controller
                    .getStatusColor(application.status)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.getStatusIcon(application.status),
                    color: controller.getStatusColor(application.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          application.status.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.getStatusColor(
                              application.status,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (application.lastUpdatedAt != null)
                    Text(
                      'Updated ${controller.formatDate(application.lastUpdatedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(Application application) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Application Submitted',
              application.appliedAt,
              Icons.send,
              Colors.blue,
              isCompleted: true,
            ),
            if (application.roundHistory.isNotEmpty)
              ...application.roundHistory.map(
                (round) => _buildTimelineItem(
                  'Round ${round.round} - ${_getRoundStatusText(round.status)}',
                  round.updatedAt,
                  _getRoundStatusIcon(round.status),
                  _getRoundStatusColor(round.status),
                  isCompleted: true,
                  remarks: round.remarks,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime date,
    IconData icon,
    Color color, {
    bool isCompleted = false,
    String? remarks,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  controller.formatDate(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (remarks != null && remarks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    remarks,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationDetails(Application application) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Application ID', application.applicationId),
            _buildDetailRow(
              'Applied On',
              controller.formatDate(application.appliedAt),
            ),
            _buildDetailRow(
              'Current Round',
              'Round ${application.currentRound}',
            ),
            if (application.formAnswers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Form Responses',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...application.formAnswers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAccessCard(Application application) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.group, color: Colors.green.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Group Chat Available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join the recruitment group to communicate with other candidates',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/groups'),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoundStatusText(RoundStatus status) {
    switch (status) {
      case RoundStatus.SELECTED:
        return 'Selected';
      case RoundStatus.ELIMINATED:
        return 'Eliminated';
      case RoundStatus.PENDING:
        return 'Pending';
    }
  }

  IconData _getRoundStatusIcon(RoundStatus status) {
    switch (status) {
      case RoundStatus.SELECTED:
        return Icons.check_circle;
      case RoundStatus.ELIMINATED:
        return Icons.cancel;
      case RoundStatus.PENDING:
        return Icons.hourglass_empty;
    }
  }

  Color _getRoundStatusColor(RoundStatus status) {
    switch (status) {
      case RoundStatus.SELECTED:
        return Colors.green;
      case RoundStatus.ELIMINATED:
        return Colors.red;
      case RoundStatus.PENDING:
        return Colors.orange;
    }
  }
}
